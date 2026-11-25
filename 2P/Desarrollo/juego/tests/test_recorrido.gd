extends GutTest
## I5, primer tramo del mapa: entrada → vestíbulo → pasillo del Custodio → mesa. El primer
## sello abre el pasillo del Recaudador y su tienda; los regresos dejan frente a cada puerta.

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

func _con_invitacion():
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	return juego

func test_cada_pasillo_tiene_su_mesa_al_norte_y_las_salas_al_sur() -> void:
	assert_true(PlanoGaleria.norte("pasillo_custodio", "custodio"))
	assert_eq(PlanoGaleria.lado("pasillo_custodio", "vestibulo"), "oeste", "El recorrido avanza de oeste a este desde el vestíbulo")
	assert_eq(PlanoGaleria.lado("pasillo_custodio", "pasillo_recaudador"), "este")
	assert_true(PlanoGaleria.norte("pasillo_recaudador", "recaudador"))
	assert_eq(PlanoGaleria.lado("pasillo_recaudador", "tienda"), "sur")
	assert_eq(PlanoGaleria.lado("pasillo_recaudador", "pasillo_custodio"), "oeste")
	assert_true(PlanoGaleria.norte("pasillo_coleccionista", "coleccionista"))
	for sala: String in PlanoGaleria.PADRE:
		assert_true(PlanoGaleria.puertas(PlanoGaleria.PADRE[sala]).has(sala), "%s sale a su pasillo" % sala)
	assert_false(PlanoGaleria.puertas("pasillo_custodio").has("tienda"), "Sin tienda antes del Custodio")

func test_el_intento_empieza_en_la_entrada_y_se_recorre_con_e() -> void:
	var juego = _casino()
	assert_eq(juego.sala, "entrada")
	juego.interactuar(_punto(juego, "vestibulo"))
	assert_eq(juego.sala, "vestibulo")
	juego.interactuar(_punto(juego, "pasillo_custodio"))
	assert_eq(juego.sala, "vestibulo", "Sin invitación el pasillo sigue cerrado")
	assert_string_contains(juego.libro.cuerpo.text, "Habla con la anfitriona")
	juego._cerrar()
	juego._entregar()
	juego.interactuar(_punto(juego, "pasillo_custodio"))
	assert_eq(juego.sala, "pasillo_custodio")
	assert_eq(juego.visitante.position, PlanoGaleria.entrada("pasillo_custodio", "vestibulo"))
	assert_eq(juego.cercano().get("destino", ""), "vestibulo", "La primera E vuelve por donde entró")
	juego.interactuar(_punto(juego, "custodio"))
	assert_eq(juego.sala, "custodio")
	juego.interactuar(_punto(juego, "pasillo_custodio"))
	assert_eq(juego.sala, "pasillo_custodio")
	assert_eq(juego.cercano().get("destino", ""), "custodio")

func test_volver_de_una_sala_deja_al_visitante_frente_a_su_puerta() -> void:
	var juego = _con_invitacion()
	juego.campana.superadas = 2
	for pareja in [["pasillo_custodio", "vestibulo"], ["pasillo_custodio", "custodio"], ["pasillo_recaudador", "tienda"], ["pasillo_recaudador", "pasillo_custodio"], ["pasillo_custodio", "pasillo_recaudador"], ["pasillo_coleccionista", "pasillo_recaudador"]]:
		juego.entrar(pareja[0], pareja[1])
		var puerta := PlanoGaleria.punto(pareja[0], pareja[1])
		var distancia: float = juego.visitante.position.distance_to(puerta)
		assert_between(distancia, 40.0, 90.0, "Cerca de la puerta de %s y con espacio para caminar" % pareja[1])
		assert_eq(juego.cercano().get("destino", ""), pareja[1], "La primera E vuelve a %s" % pareja[1])

func test_el_primer_sello_abre_el_pasillo_del_recaudador_y_su_tienda() -> void:
	var juego = _con_invitacion()
	juego.entrar("pasillo_custodio", "vestibulo")
	assert_eq(_punto(juego, "pasillo_recaudador").accion, "Falta el primer sello")
	assert_eq(PlanoGaleria.estado("pasillo_recaudador", juego.campana, "pasillo_custodio"), "Cerrada")
	assert_eq(PlanoGaleria.estado("custodio", juego.campana, "pasillo_custodio"), "Siguiente")
	juego.interactuar(_punto(juego, "pasillo_recaudador"))
	assert_eq(juego.sala, "pasillo_custodio", "Una puerta cerrada no deja pasar")
	assert_string_contains(juego.libro.cuerpo.text, "Falta el primer sello")
	juego._cerrar()
	juego.entrar("tienda")
	assert_eq(juego.sala, "pasillo_custodio", "La tienda no se abre antes del Custodio")
	juego.campana.superadas = 1
	juego.entrar("pasillo_custodio", "custodio")
	assert_eq(PlanoGaleria.estado("custodio", juego.campana, "pasillo_custodio"), "Superada")
	assert_eq(PlanoGaleria.estado("pasillo_recaudador", juego.campana, "pasillo_custodio"), "Siguiente")
	juego.interactuar(_punto(juego, "pasillo_recaudador"))
	assert_eq(juego.sala, "pasillo_recaudador")
	assert_eq(PlanoGaleria.estado("recaudador", juego.campana, "pasillo_recaudador"), "Siguiente")
	assert_eq(_punto(juego, "pasillo_coleccionista").accion, "Falta el segundo sello")
	juego.interactuar(_punto(juego, "tienda"))
	assert_eq(juego.sala, "tienda")
	juego.interactuar(_punto(juego, "pasillo_recaudador"))
	assert_eq(juego.sala, "pasillo_recaudador")
	juego.interactuar(_punto(juego, "recaudador"))
	assert_eq(juego.sala, "recaudador")

func test_la_placa_cercana_muestra_el_requisito_solo_al_acercarse() -> void:
	var juego = _con_invitacion()
	juego.entrar("pasillo_custodio", "vestibulo")
	var galeria = juego.exploracion.galeria
	assert_not_null(galeria)
	juego.visitante.position = PlanoGaleria.punto("pasillo_custodio", "pasillo_recaudador") + Vector2(-20, 0)
	juego.exploracion.marcar(juego.cercano())
	assert_eq(galeria._cercana, "pasillo_recaudador")
	juego.visitante.position = Vector2(640, 450)
	juego.exploracion.marcar(juego.cercano())
	assert_eq(galeria._cercana, "")

func test_la_puerta_que_se_ilumina_acerca_al_siguiente_paso() -> void:
	var campana := CampanaCasino.new()
	assert_eq(PlanoGaleria.siguiente(campana, "pasillo_custodio"), "vestibulo")
	campana.recibir_invitacion()
	var esperadas := [
		["custodio", "pasillo_custodio", "pasillo_recaudador"],
		["pasillo_recaudador", "recaudador", "pasillo_recaudador"],
		["pasillo_recaudador", "pasillo_coleccionista", "coleccionista"],
		["pasillo_recaudador", "pasillo_coleccionista", "dueno"],
		["pasillo_recaudador", "pasillo_coleccionista", "dueno"],
	]
	for superadas in range(5):
		campana.superadas = superadas
		for indice in PlanoGaleria.ORDEN.size():
			assert_eq(PlanoGaleria.siguiente(campana, PlanoGaleria.ORDEN[indice]), esperadas[superadas][indice], "%s sellos · %s" % [superadas, PlanoGaleria.ORDEN[indice]])

func test_el_dueno_se_alcanza_desde_el_ultimo_pasillo_con_tres_sellos() -> void:
	var juego = _con_invitacion()
	juego.campana.superadas = 2
	juego.entrar("pasillo_coleccionista", "pasillo_recaudador")
	assert_eq(_punto(juego, "dueno").accion, "Falta el tercer sello")
	juego.campana.superadas = 3
	juego.entrar("pasillo_coleccionista", "coleccionista")
	juego.interactuar(_punto(juego, "dueno"))
	assert_eq(juego.sala, "dueno")
	juego.interactuar(_punto(juego, "pasillo_coleccionista"))
	assert_eq(juego.sala, "pasillo_coleccionista")
	assert_eq(juego.cercano().get("destino", ""), "dueno")

func test_desde_el_vestibulo_se_sigue_hacia_delante() -> void:
	var juego = _casino()
	juego.interactuar(_punto(juego, "vestibulo"))
	var llegada: Vector2 = juego.visitante.position
	var hacia_pasillo: Vector2 = _punto(juego, "pasillo_custodio").pos
	var calle: Vector2 = _punto(juego, "entrada").pos
	assert_gt(llegada.distance_to(hacia_pasillo), 300.0, "La salida al pasillo no es la puerta por la que se entra")
	assert_lt(llegada.distance_to(calle), 150.0, "Se llega por la puerta de la calle")
	assert_gt(hacia_pasillo.x, 1000.0, "La salida está al este")
	juego._entregar()
	juego.interactuar(_punto(juego, "pasillo_custodio"))
	assert_eq(juego.sala, "pasillo_custodio")
	juego.interactuar(_punto(juego, "vestibulo"))
	assert_eq(juego.sala, "vestibulo")
	assert_lt(juego.visitante.position.distance_to(hacia_pasillo), 100.0, "Al volver aparece junto a la puerta del este")

func test_la_puerta_de_la_calle_se_cierra_al_entregar_la_invitacion() -> void:
	var juego = _casino()
	juego.entrar("vestibulo", "entrada")
	juego.interactuar(_punto(juego, "entrada"))
	assert_eq(juego.sala, "entrada", "Antes de entregar la invitación se puede volver a la calle")
	juego.entrar("vestibulo", "entrada")
	juego._entregar()
	juego._cerrar()
	juego.interactuar(_punto(juego, "entrada"))
	assert_eq(juego.sala, "vestibulo")
	assert_string_contains(juego.libro.cuerpo.text, "contorno")
