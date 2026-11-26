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
	assert_true(PlanoGaleria.norte("pasillo_dueno", "dueno"))
	assert_eq(PlanoGaleria.puertas("pasillo_dueno").size(), 2, "La última galería tiene solo dos accesos")
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
	assert_string_contains(juego.dialogo.texto.text, "Habla con la anfitriona")
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
	assert_eq(PlanoGaleria.estado("pasillo_recaudador", juego.campana, "pasillo_custodio"), "Cerrada")
	assert_eq(PlanoGaleria.estado("custodio", juego.campana, "pasillo_custodio"), "Siguiente")
	juego.interactuar(_punto(juego, "pasillo_recaudador"))
	assert_eq(juego.sala, "pasillo_custodio", "Una puerta cerrada no deja pasar")
	assert_true(juego.dialogo.visible)
	assert_eq(juego.dialogo.texto.text, "No tienes el sello necesario para abrir esta puerta.")
	assert_false(juego.dialogo.barra.visible, "El aviso es de una sola línea")
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
	juego.interactuar(_punto(juego, "pasillo_coleccionista"))
	assert_eq(juego.dialogo.texto.text, "No tienes los sellos necesarios para abrir esta puerta.")
	juego._cerrar()
	juego.interactuar(_punto(juego, "tienda"))
	assert_eq(juego.sala, "tienda")
	juego.interactuar(_punto(juego, "pasillo_recaudador"))
	assert_eq(juego.sala, "pasillo_recaudador")
	juego.interactuar(_punto(juego, "recaudador"))
	assert_eq(juego.sala, "recaudador")

func test_m_se_abre_el_plano_y_escape_devuelve_el_control() -> void:
	var juego = _con_invitacion()
	juego.entrar("pasillo_custodio", "vestibulo")
	juego.visitante.position = Vector2(640, 450)
	juego._process(0.0)
	assert_eq(juego.minimapa._sala, "pasillo_custodio")
	assert_eq(juego.minimapa._posicion, juego.visitante.position)
	var tecla := InputEventKey.new()
	tecla.keycode = KEY_M
	tecla.pressed = true
	juego._unhandled_key_input(tecla)
	assert_true(juego.minimapa.ampliado)
	assert_true(juego.visitante.bloqueado)
	tecla.keycode = KEY_ESCAPE
	juego._unhandled_key_input(tecla)
	assert_false(juego.minimapa.ampliado)
	assert_false(juego.visitante.bloqueado)
	assert_false(juego.menu.visible)

func test_la_puerta_que_se_ilumina_acerca_al_siguiente_paso() -> void:
	var campana := CampanaCasino.new()
	assert_eq(PlanoGaleria.siguiente(campana, "pasillo_custodio"), "vestibulo")
	campana.recibir_invitacion()
	var esperadas := [
		["custodio", "pasillo_custodio", "pasillo_recaudador", "pasillo_coleccionista"],
		["pasillo_recaudador", "recaudador", "pasillo_recaudador", "pasillo_coleccionista"],
		["pasillo_recaudador", "pasillo_coleccionista", "coleccionista", "pasillo_coleccionista"],
		["pasillo_recaudador", "pasillo_coleccionista", "pasillo_dueno", "dueno"],
		["pasillo_recaudador", "pasillo_coleccionista", "pasillo_dueno", "dueno"],
	]
	for superadas in range(5):
		campana.superadas = superadas
		for indice in PlanoGaleria.ORDEN.size():
			assert_eq(PlanoGaleria.siguiente(campana, PlanoGaleria.ORDEN[indice]), esperadas[superadas][indice], "%s sellos · %s" % [superadas, PlanoGaleria.ORDEN[indice]])

func test_el_dueno_se_alcanza_desde_el_ultimo_pasillo_con_tres_sellos() -> void:
	var juego = _con_invitacion()
	juego.campana.superadas = 2
	juego.entrar("pasillo_coleccionista", "pasillo_recaudador")
	juego.interactuar(_punto(juego, "pasillo_dueno"))
	assert_eq(juego.sala, "pasillo_coleccionista")
	assert_eq(juego.dialogo.texto.text, "No tienes los sellos necesarios para abrir esta puerta.")
	juego._cerrar()
	juego.campana.superadas = 3
	juego.entrar("pasillo_coleccionista", "coleccionista")
	juego.interactuar(_punto(juego, "pasillo_dueno"))
	assert_eq(juego.sala, "pasillo_dueno")
	assert_eq(juego.cercano().get("destino", ""), "pasillo_coleccionista")
	juego.interactuar(_punto(juego, "dueno"))
	assert_eq(juego.sala, "dueno")
	juego.interactuar(_punto(juego, "pasillo_dueno"))
	assert_eq(juego.sala, "pasillo_dueno")
	assert_eq(juego.cercano().get("destino", ""), "dueno")
	juego.interactuar(_punto(juego, "pasillo_coleccionista"))
	assert_eq(juego.sala, "pasillo_coleccionista")

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
	assert_string_contains(juego.dialogo.texto.text, "contorno")
