extends GutTest
## Fallos de la auditoría de pantallas (26 nov 2026), antes del piloto I6-07:
## F1, el bocadillo del crupier muestra entera cada línea del guion;
## F2, la derrota o la victoria no se acompañan de la reacción a la última mano;
## F3, una mano resuelta enseña todas sus cartas, sin desplazamiento.

var _ruta_original := ""

func before_each() -> void:
	_ruta_original = AjustesJuego.ruta
	AjustesJuego.ruta = "user://ajustes_prueba_auditoria.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(AjustesJuego.ruta))

func after_each() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(AjustesJuego.ruta))
	AjustesJuego.ruta = _ruta_original
	await get_tree().process_frame

func _mesa_del_custodio():
	var juego = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	juego.mesa.movimiento_reducido = true
	return juego

func _cartas(juego, datos: Array) -> void:
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.mazo.clear()
	for d in datos:
		m.partida.mazo.append(FabricaCartas.crear_carta(d[0], d[1]))

func test_f1_cada_linea_del_guion_se_ve_entera_en_el_bocadillo() -> void:
	var juego = _mesa_del_custodio()
	var bocadillo: Control = juego.mesa.bocadillo
	var reacciones: ReaccionesCrupier = load("res://datos/reacciones/reacciones.tres")
	var cortadas: Array[String] = []
	for jefe in reacciones.lineas:
		for id in reacciones.lineas[jefe]:
			for linea in reacciones.lineas[jefe][id]:
				bocadillo.mostrar(CampanaCasino.NOMBRES.get(jefe, ""), str(linea).format({"umbral": 17, "usadas": 10}))
				await get_tree().process_frame
				var texto: Label = bocadillo.texto
				if texto.get_visible_line_count() < texto.get_line_count() or bocadillo.size.y < texto.position.y + texto.size.y:
					cortadas.append("%s · %s · %d de %d líneas" % [jefe, id, texto.get_visible_line_count(), texto.get_line_count()])
	assert_eq(cortadas, [] as Array[String], "Ninguna línea queda cortada")

func test_f1_las_dos_lineas_largas_de_la_auditoria() -> void:
	var juego = _mesa_del_custodio()
	var bocadillo: Control = juego.mesa.bocadillo
	for linea in ["«Diecisiete justos. Así suena un mecanismo bien ajustado.»", "«Te pasaste. La mano se pierde; el año, también.»"]:
		bocadillo.mostrar("El Custodio", linea)
		await get_tree().process_frame
		assert_gt(bocadillo.texto.get_line_count(), 1, "La línea necesita más de un renglón")
		assert_eq(bocadillo.texto.get_visible_line_count(), bocadillo.texto.get_line_count(), "y se ven todos")

func test_f2_la_derrota_no_celebra_la_ultima_mano() -> void:
	var juego = _mesa_del_custodio()
	var mesa = juego.mesa
	mesa.controlador.partida.campanadas = 1
	_cartas(juego, [["llaves", 10], ["velas", 7]])
	mesa.boton_iniciar_pedir.pressed.emit()
	mesa.boton_plantarse.pressed.emit()
	await get_tree().process_frame
	assert_true(mesa.vista.get("terminado", false), "Se acabó el intento")
	assert_false(mesa.vista.get("victoria", true), "sin llegar a la meta")
	var exacto: Array = load("res://datos/reacciones/reacciones.tres").lineas.custodio.punto_exacto
	assert_false(mesa.bocadillo.visible and exacto.has(mesa.bocadillo.texto.text), "El Custodio no festeja el Punto exacto sobre la derrota")

func test_f2_ninguna_reaccion_de_mano_acompana_el_fin_del_intento() -> void:
	var previa := {"fase": "decision", "puntos": 100, "meta": 200, "campanadas": 0, "intervalo": {"ocultas": 1}}
	for victoria in [true, false]:
		var nueva := {"fase": "resuelta", "terminado": true, "victoria": victoria, "puntos": 250 if victoria else 150, "meta": 200,
			"ultima_mano": {"quiebra": false, "patrones": ["Punto exacto", "Racha"]}, "campanadas": 0, "intervalo": {"ocultas": 0}}
		assert_eq(ReaccionesCrupier.disparadores(previa, nueva), ["victoria" if victoria else "derrota"] as Array[String])

func test_f3_la_mano_resuelta_ensena_sus_seis_cartas() -> void:
	var juego = _mesa_del_custodio()
	var mesa = juego.mesa
	_cartas(juego, [["velas", 1], ["llaves", 2], ["relojes", 1], ["velas", 2], ["llaves", 1], ["relojes", 2]])
	mesa.boton_iniciar_pedir.pressed.emit()
	for i in range(4):
		mesa.boton_iniciar_pedir.pressed.emit()
	await get_tree().process_frame
	assert_eq(mesa.mano.fila.get_child_count(), 6)
	mesa.boton_plantarse.pressed.emit()
	for i in range(3):
		await get_tree().process_frame
	var scroll: ScrollContainer = mesa.mano.scroll
	assert_lte(mesa.mano.fila.size.x, scroll.size.x + 0.5, "Las seis cartas caben en el tapete")
	assert_eq(scroll.scroll_horizontal, 0, "sin desplazamiento")
	assert_false(scroll.get_h_scroll_bar().visible, "ni barra")

func test_f3_durante_la_mano_la_barra_lleva_el_estilo_de_la_mesa() -> void:
	var juego = _mesa_del_custodio()
	var barra: HScrollBar = juego.mesa.mano.scroll.get_h_scroll_bar()
	assert_true(barra.has_theme_stylebox_override("grabber"), "La barra no usa el gris por defecto de Godot")
	assert_true(barra.has_theme_stylebox_override("scroll"))

func test_levantarse_con_p_tras_ganar_no_falla() -> void:
	var juego = _mesa_del_custodio()
	var mesa = juego.mesa
	mesa.vista["terminado"] = true
	mesa.vista["victoria"] = true
	mesa.boton_iniciar_pedir.disabled = false
	var tecla := InputEventKey.new()
	tecla.keycode = KEY_P
	tecla.physical_keycode = KEY_P
	tecla.pressed = true
	mesa._unhandled_key_input(tecla)
	assert_null(juego.mesa, "Klein se levanta de la mesa")
	assert_eq(juego.campana.superadas, 1, "con el sello del Custodio")
	assert_engine_error_count(0, "sin el error de set_input_as_handled sobre null")
