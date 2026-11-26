extends GutTest
## I6-10: reacciones del Custodio durante la mano (guion §9). Punto exacto, Al filo, Quiebra y
## cercanía a la meta, junto al retrato, sin pausar la mano, quitar el foco ni revelar Máscaras.

const IniciarMano = preload("res://dominio/comandos/iniciar_mano.gd")
var _ruta_original := ""

func before_each() -> void:
	_ruta_original = AjustesJuego.ruta
	AjustesJuego.ruta = "user://ajustes_prueba_reacciones.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(AjustesJuego.ruta))

func after_each() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(AjustesJuego.ruta))
	AjustesJuego.ruta = _ruta_original
	await get_tree().process_frame

func _vista(fase: String, puntos: int, mano := {}, meta := 200) -> Dictionary:
	return {"fase": fase, "puntos": puntos, "meta": meta, "ultima_mano": mano}

func test_el_disparador_solo_aparece_al_resolver_la_mano() -> void:
	var exacta := {"quiebra": false, "patrones": ["Punto exacto"]}
	assert_eq(ReaccionesCrupier.disparador(_vista("decision", 0), _vista("preparado", 50, exacta)), "punto_exacto")
	assert_eq(ReaccionesCrupier.disparador(_vista("preparado", 0), _vista("decision", 0)), "", "Iniciar la mano no comenta en este tramo")
	assert_eq(ReaccionesCrupier.disparador(_vista("decision", 0), _vista("decision", 0)), "", "Pedir tampoco")

func test_quiebra_al_filo_y_meta_cerca() -> void:
	assert_eq(ReaccionesCrupier.disparador(_vista("decision", 0), _vista("preparado", 0, {"quiebra": true, "patrones": []})), "quiebra")
	assert_eq(ReaccionesCrupier.disparador(_vista("decision", 0), _vista("preparado", 30, {"quiebra": false, "patrones": ["Al filo"]})), "al_filo")
	var normal := {"quiebra": false, "patrones": []}
	assert_eq(ReaccionesCrupier.disparador(_vista("decision", 150), _vista("preparado", 175, normal)), "meta_cerca", "Falta menos del 15 %")
	assert_eq(ReaccionesCrupier.disparador(_vista("decision", 175), _vista("preparado", 180, normal)), "", "Solo al cruzar el umbral del 85 %")
	var con_victoria := _vista("preparado", 205, normal)
	con_victoria.victoria = true
	assert_eq(ReaccionesCrupier.disparador(_vista("decision", 150), con_victoria), "", "La victoria tiene su propio cierre")

func test_si_coinciden_gana_la_mayor_prioridad() -> void:
	var exacta := {"quiebra": false, "patrones": ["Punto exacto"]}
	assert_eq(ReaccionesCrupier.disparador(_vista("decision", 150), _vista("preparado", 175, exacta)), "punto_exacto", "Punto exacto (8) gana a meta_cerca (6)")
	var filo := {"quiebra": false, "patrones": ["Al filo"]}
	var empate := ReaccionesCrupier.disparador(_vista("decision", 150), _vista("preparado", 175, filo))
	assert_eq(empate, "al_filo", "Con la misma prioridad, el primero del guion")

func test_las_lineas_del_custodio_caben_y_no_se_repiten_seguidas() -> void:
	var reacciones: ReaccionesCrupier = load("res://datos/reacciones/reacciones.tres")
	assert_eq(reacciones.largas(), PackedStringArray(), "Todas caben en 90 caracteres")
	for id in ["punto_exacto", "al_filo", "quiebra", "meta_cerca"]:
		assert_false(reacciones.linea("custodio", id).is_empty(), id)
	var azar := RandomNumberGenerator.new()
	azar.seed = 4
	var anterior := reacciones.linea("custodio", "quiebra", "", azar)
	for i in range(10):
		var nueva := reacciones.linea("custodio", "quiebra", anterior, azar)
		assert_ne(nueva, anterior, "Sin repetir la última")
		anterior = nueva

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

func test_punto_exacto_en_la_mesa_comenta_sin_quitar_el_foco() -> void:
	var juego = _mesa_del_custodio()
	var mesa = juego.mesa
	_cartas(juego, [["llaves", 10], ["velas", 7]])
	mesa.boton_iniciar_pedir.pressed.emit()
	assert_false(mesa.bocadillo.visible, "Durante la decisión, nada")
	mesa.boton_plantarse.grab_focus()
	mesa.boton_plantarse.pressed.emit()
	await get_tree().process_frame
	assert_true(mesa.bocadillo.visible, "Tras resolver con Punto exacto, el Custodio comenta")
	assert_true(["«Diecisiete justos. Así suena un mecanismo bien ajustado.»", "«Exacto. Ni un diente de más.»"].has(mesa.bocadillo.texto.text))
	assert_eq(mesa.bocadillo.nombre.text, "EL CUSTODIO")
	assert_eq(mesa.bocadillo.mouse_filter, Control.MOUSE_FILTER_IGNORE, "No recibe clics")
	var foco: Control = juego.get_viewport().gui_get_focus_owner()
	assert_true(foco is Button and foco != mesa.bocadillo and not mesa.bocadillo.is_ancestor_of(foco), "El foco sigue en una acción de la mesa")
	assert_false(mesa.boton_iniciar_pedir.disabled, "La mano no se pausa: se puede seguir jugando")

func test_quiebra_en_la_mesa_y_se_retira_al_actuar() -> void:
	var juego = _mesa_del_custodio()
	var mesa = juego.mesa
	_cartas(juego, [["llaves", 10], ["velas", 9], ["llaves", 2], ["velas", 3]])
	mesa.boton_iniciar_pedir.pressed.emit()
	mesa.boton_plantarse.pressed.emit()
	await get_tree().process_frame
	assert_true(mesa.bocadillo.visible)
	assert_true(mesa.bocadillo.texto.text.contains("Quiebra") or mesa.bocadillo.texto.text.contains("Te pasaste"))
	mesa.boton_iniciar_pedir.pressed.emit()
	assert_false(mesa.bocadillo.visible, "La siguiente acción retira el comentario")

func test_el_comentario_desaparece_a_los_tres_segundos() -> void:
	var juego = _mesa_del_custodio()
	var mesa = juego.mesa
	mesa.bocadillo.mostrar("El Custodio", "«Prueba.»")
	assert_true(mesa.bocadillo.visible)
	mesa.bocadillo._process(2.0)
	assert_true(mesa.bocadillo.visible)
	mesa.bocadillo._process(1.1)
	assert_false(mesa.bocadillo.visible)

func test_con_una_mascara_oculta_no_hay_comentario_antes_de_plantarse() -> void:
	var juego = _mesa_del_custodio()
	var mesa = juego.mesa
	_cartas(juego, [["mascaras", 9], ["velas", 8], ["llaves", 2]])
	mesa.boton_iniciar_pedir.pressed.emit()
	mesa.boton_iniciar_pedir.pressed.emit()
	assert_false(mesa.bocadillo.visible, "Pedir con una Máscara oculta no comenta: no puede anticipar su valor")

func test_los_comentarios_se_pueden_desactivar() -> void:
	AjustesJuego.guardar_comentarios_crupieres(false)
	var juego = _mesa_del_custodio()
	assert_false(juego.mesa.comentarios)
	_cartas(juego, [["llaves", 10], ["velas", 7]])
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	juego.mesa.boton_plantarse.pressed.emit()
	await get_tree().process_frame
	assert_false(juego.mesa.bocadillo.visible, "Con los comentarios desactivados, el Custodio calla")

func test_el_ajuste_esta_en_opciones() -> void:
	var juego = load("res://casino/casino.tscn").instantiate()
	add_child_autofree(juego)
	juego.abrir_inicio()
	juego.menu.abrir("opciones")
	var panel = juego.menu._contenido.get_child(1)
	assert_true(panel.comentarios.button_pressed, "Activados por defecto")
	panel.comentarios.button_pressed = false
	assert_false(AjustesJuego.comentarios_crupieres())
