extends GutTest
## I4-02: corredor según el plano, regresos frente a cada puerta y cerrojos en orden.

func after_each() -> void:
	await get_tree().process_frame

func _casino():
	var juego = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	return juego

func _punto(juego, destino: String) -> Dictionary:
	for punto: Dictionary in juego.exploracion.puntos:
		if punto.get("destino", "") == destino: return punto
	return {}

func test_las_mesas_quedan_al_norte_en_orden_y_vestibulo_y_tienda_al_sur() -> void:
	var x_previa := -1.0
	for mesa: String in CampanaCasino.MESAS:
		var puerta: Dictionary = PlanoGaleria.PUERTAS[mesa]
		assert_eq(puerta.lado, "norte", mesa)
		assert_gt(puerta.x, x_previa, "%s queda a la derecha de la anterior" % mesa)
		x_previa = puerta.x
	for sala in ["vestibulo", "tienda"]:
		assert_eq(PlanoGaleria.PUERTAS[sala].lado, "sur", sala)

func test_volver_de_una_sala_deja_al_visitante_frente_a_su_puerta() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	for origen in ["vestibulo", "tienda", "custodio"]:
		juego.entrar("corredor", origen)
		var puerta := PlanoGaleria.punto(origen)
		assert_eq(juego.visitante.position.x, puerta.x, "Frente a la puerta de %s" % origen)
		var distancia: float = absf(juego.visitante.position.y - puerta.y)
		assert_between(distancia, 40.0, 90.0, "Cerca de la puerta y con espacio para caminar")
		assert_eq(juego.cercano().get("destino", ""), origen, "La primera E vuelve a entrar por donde salió")

func test_las_puertas_cerradas_muestran_su_requisito_y_se_abren_en_orden() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.entrar("corredor", "vestibulo")
	assert_eq(_punto(juego, "recaudador").accion, "Falta el primer sello")
	assert_eq(PlanoGaleria.estado("recaudador", juego.campana), "Cerrada")
	assert_eq(PlanoGaleria.estado("custodio", juego.campana), "Siguiente")
	juego.interactuar(_punto(juego, "dueno"))
	assert_eq(juego.sala, "corredor", "Una puerta cerrada no deja pasar")
	assert_string_contains(juego.libro.cuerpo.text, "Falta el tercer sello")
	juego._cerrar()
	juego.campana.superadas = 1
	juego.entrar("corredor", "custodio")
	assert_eq(PlanoGaleria.estado("custodio", juego.campana), "Superada")
	assert_eq(PlanoGaleria.estado("recaudador", juego.campana), "Siguiente")
	assert_eq(_punto(juego, "recaudador").accion, "Entrar · El Recaudador")
	juego.interactuar(_punto(juego, "recaudador"))
	assert_eq(juego.sala, "recaudador")

func test_la_placa_cercana_muestra_el_requisito_solo_al_acercarse() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.entrar("corredor", "vestibulo")
	var galeria = juego.exploracion.galeria
	assert_not_null(galeria)
	juego.visitante.position = PlanoGaleria.punto("coleccionista") + Vector2(0, 20)
	juego.exploracion.marcar(juego.cercano())
	assert_eq(galeria._cercana, "coleccionista")
	juego.visitante.position = Vector2(640, 450)
	juego.exploracion.marcar(juego.cercano())
	assert_eq(galeria._cercana, "")

func test_la_puerta_siguiente_acompana_el_progreso() -> void:
	var campana := CampanaCasino.new()
	assert_eq(PlanoGaleria.siguiente(campana), "vestibulo")
	campana.recibir_invitacion()
	var esperadas := ["custodio", "recaudador", "coleccionista", "dueno", "dueno"]
	for superadas in range(5):
		campana.superadas = superadas
		assert_eq(PlanoGaleria.siguiente(campana), esperadas[superadas], "Tras vencer al Dueño, su sala lleva a la salida")

func test_ruta_del_plano_vestibulo_tienda_y_mesa_con_e() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.interactuar(_punto(juego, "corredor"))
	assert_eq(juego.sala, "corredor")
	juego.interactuar(_punto(juego, "tienda"))
	assert_eq(juego.sala, "tienda")
	juego.interactuar(_punto(juego, "corredor"))
	assert_eq(juego.sala, "corredor")
	assert_eq(juego.visitante.position, PlanoGaleria.entrada("tienda"))
	juego.interactuar(_punto(juego, "custodio"))
	assert_eq(juego.sala, "custodio")
