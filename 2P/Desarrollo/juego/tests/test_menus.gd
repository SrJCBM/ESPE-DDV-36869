extends GutTest
## I4-07: inicio, pausa con Esc y opciones que se conservan.

var _ruta_original := ""

func before_each() -> void:
	_ruta_original = AjustesJuego.ruta
	AjustesJuego.ruta = "user://ajustes_prueba_menus.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(AjustesJuego.ruta))

func after_each() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(AjustesJuego.ruta))
	AjustesJuego.ruta = _ruta_original
	await get_tree().process_frame

func _casino():
	var juego = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	return juego

func _esc(juego) -> void:
	var tecla := InputEventKey.new()
	tecla.keycode = KEY_ESCAPE
	tecla.physical_keycode = KEY_ESCAPE
	tecla.pressed = true
	juego.get_viewport().push_input(tecla)

func _textos(juego) -> Array:
	return juego.menu.botones.map(func(b: Button) -> String: return b.text)

func test_el_inicio_ofrece_sus_cuatro_opciones_y_entrar_devuelve_el_control() -> void:
	var juego = _casino()
	assert_false(juego.menu.visible, "Las pruebas montan el casino sin el inicio")
	juego.abrir_inicio()
	assert_eq(_textos(juego), ["Entrar al casino", "Cómo jugar", "Opciones", "Créditos", "Salir"])
	assert_eq(juego.pagina.process_mode, Node.PROCESS_MODE_DISABLED)
	assert_false(juego.indicador_objetivo.visible)
	_esc(juego)
	assert_eq(juego.menu.pantalla, "inicio", "Esc no sale del inicio")
	juego.menu.botones[0].pressed.emit()
	assert_false(juego.menu.visible)
	assert_eq(juego.pagina.process_mode, Node.PROCESS_MODE_INHERIT)

func test_la_portada_cambia_sin_robar_foco_y_respeta_movimiento_reducido() -> void:
	var juego = _casino()
	juego.abrir_inicio()
	var menu = juego.menu
	var inicial: Texture2D = menu._fondo.texture
	var accion: Button = menu.botones[0]
	assert_false(menu._tempo_portada.is_stopped())
	menu._tempo_portada.timeout.emit()
	await menu._fundido_portada.finished
	assert_ne(menu._fondo.texture, inicial)
	assert_eq(juego.get_viewport().gui_get_focus_owner(), accion)
	menu.abrir("opciones")
	assert_true(menu._tempo_portada.is_stopped())
	AjustesJuego.guardar_movimiento_reducido(true)
	menu.abrir("inicio")
	assert_true(menu._tempo_portada.is_stopped())
	assert_false(menu._fondo_siguiente.visible)

func test_esc_abre_la_pausa_y_otra_pulsacion_reanuda() -> void:
	var juego = _casino()
	_esc(juego)
	assert_eq(juego.menu.pantalla, "pausa")
	assert_eq(_textos(juego), ["Reanudar", "Inventario", "Cómo jugar", "Opciones", "Volver al inicio"])
	assert_eq(juego.pagina.process_mode, Node.PROCESS_MODE_DISABLED, "Sala congelada")
	assert_eq(juego.get_viewport().gui_get_focus_owner(), juego.menu.botones[0])
	_esc(juego)
	assert_false(juego.menu.visible)
	assert_eq(juego.pagina.process_mode, Node.PROCESS_MODE_INHERIT)

func test_esc_cierra_lo_abierto_antes_de_pausar() -> void:
	var juego = _casino()
	juego.inventario()
	_esc(juego)
	assert_false(juego.libro.visible)
	assert_false(juego.menu.visible, "Una pulsación, una acción")

func test_desde_una_subpantalla_esc_vuelve_a_la_pausa() -> void:
	var juego = _casino()
	juego._entregar()
	juego.pausar()
	juego.menu.botones[1].pressed.emit()
	assert_eq(juego.menu.pantalla, "inventario")
	var inventario: Control = juego.menu._contenido.get_child(1)
	var cabecera: Control = inventario.get_child(0)
	assert_eq(cabecera.get_child(0).get_child(0).get_child(1).text, "24 cartas")
	_esc(juego)
	assert_eq(juego.menu.pantalla, "pausa")
	juego.menu.botones[2].pressed.emit()
	assert_eq(juego.menu.pantalla, "como_jugar")
	_esc(juego)
	assert_eq(juego.menu.pantalla, "pausa")

func test_pausar_a_mitad_de_una_mano_conserva_el_estado() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._jugar()
	var m: ControladorMesa = juego.mesa.controlador
	m.procesar_comando(IniciarMano.new())
	var antes := m.obtener_vista()
	_esc(juego)
	assert_eq(juego.menu.pantalla, "pausa")
	assert_eq(juego.mesa.process_mode, Node.PROCESS_MODE_DISABLED, "La mesa no recibe entradas")
	assert_eq(juego.menu.get_index(), juego.get_child_count() - 1, "El menú queda sobre la mesa")
	_esc(juego)
	assert_false(juego.menu.visible)
	assert_eq(juego.mesa.process_mode, Node.PROCESS_MODE_INHERIT)
	var despues := m.obtener_vista()
	assert_eq(despues.mazo, antes.mazo)
	assert_eq(despues.campanadas, antes.campanadas)
	assert_eq(despues.fase, antes.fase)

func test_volver_al_inicio_pide_confirmacion_con_un_intento_activo() -> void:
	var juego = _casino()
	juego._entregar()
	juego.pausar()
	juego.menu.botones[4].pressed.emit()
	assert_eq(juego.menu.pantalla, "confirmar")
	assert_true(juego.campana.recibida, "Aún no se pierde nada")
	_esc(juego)
	assert_eq(juego.menu.pantalla, "pausa")
	juego.menu.botones[4].pressed.emit()
	juego.menu.botones[1].pressed.emit()
	assert_eq(juego.menu.pantalla, "inicio")
	assert_false(juego.campana.recibida, "Intento nuevo")
	assert_eq(juego.sala, "entrada")

func test_sin_intento_vuelve_al_inicio_directamente() -> void:
	var juego = _casino()
	juego.pausar()
	juego.menu.botones[4].pressed.emit()
	assert_eq(juego.menu.pantalla, "inicio")

func test_volver_al_inicio_desde_una_mesa_la_retira() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._jugar()
	juego.volver_al_inicio()
	assert_false(is_instance_valid(juego.mesa))
	assert_true(juego.pagina.visible)
	assert_eq(juego.menu.pantalla, "inicio")

func test_las_opciones_guardan_el_movimiento_reducido() -> void:
	var juego = _casino()
	juego.pausar()
	juego.menu.botones[3].pressed.emit()
	assert_eq(juego.menu.pantalla, "opciones")
	var opciones = juego.menu._contenido.get_child(1)
	assert_not_null(opciones.find_child("*", true, false), "Incluye el volumen por canal")
	assert_false(AjustesJuego.movimiento_reducido())
	opciones.movimiento.button_pressed = true
	assert_true(AjustesJuego.movimiento_reducido(), "Se conserva entre sesiones")

func test_el_encabezado_no_repite_el_boton_de_sonido() -> void:
	var juego = _casino()
	for hijo in juego.pagina.get_children():
		assert_false(hijo is Button and hijo.text.begins_with("Sonido"))

func _tecla(juego, codigo: Key) -> void:
	var tecla := InputEventKey.new()
	tecla.keycode = codigo
	tecla.physical_keycode = codigo
	tecla.pressed = true
	juego.get_viewport().push_input(tecla)
	var suelta := tecla.duplicate()
	suelta.pressed = false
	juego.get_viewport().push_input(suelta)

func _mesa_con_mano(juego) -> ControladorMesa:
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._jugar()
	var m: ControladorMesa = juego.mesa.controlador
	m.procesar_comando(IniciarMano.new())
	return m

func test_reanudar_con_esc_devuelve_el_foco_a_plantarse_y_enter_actua_una_vez() -> void:
	var juego = _casino()
	var m := _mesa_con_mano(juego)
	await get_tree().process_frame
	var plantarse: BaseButton = juego.mesa.boton_plantarse
	plantarse.grab_focus()
	var manos: int = m.obtener_vista().numero_mano
	_esc(juego)
	assert_ne(juego.get_viewport().gui_get_focus_owner(), plantarse, "La pausa toma el foco")
	_esc(juego)
	assert_false(juego.menu.visible)
	assert_eq(juego.get_viewport().gui_get_focus_owner(), plantarse, "Plantarse recupera el foco")
	assert_eq(m.obtener_vista().fase, "decision", "La mano se conserva")
	watch_signals(plantarse)
	_tecla(juego, KEY_ENTER)
	assert_signal_emit_count(plantarse, "pressed", 1)
	assert_eq(m.obtener_vista().numero_mano, manos)

func test_reanudar_con_el_boton_tambien_devuelve_el_foco() -> void:
	var juego = _casino()
	_mesa_con_mano(juego)
	await get_tree().process_frame
	var plantarse: BaseButton = juego.mesa.boton_plantarse
	plantarse.grab_focus()
	juego.pausar()
	juego.menu.botones[0].pressed.emit()
	assert_eq(juego.get_viewport().gui_get_focus_owner(), plantarse)

func test_si_el_control_ya_no_existe_enfoca_una_accion_de_la_mesa() -> void:
	var juego = _casino()
	_mesa_con_mano(juego)
	await get_tree().process_frame
	var efimero := Button.new()
	juego.mesa.add_child(efimero)
	efimero.grab_focus()
	juego.pausar()
	efimero.free()
	juego.menu.botones[0].pressed.emit()
	assert_eq(juego.get_viewport().gui_get_focus_owner(), juego.mesa.boton_iniciar_pedir)

func test_ninguna_pantalla_del_menu_desborda_su_marco() -> void:
	var juego = _casino()
	juego.menu.hay_partida = func() -> bool: return true
	for nombre in ["inicio", "pausa", "opciones", "como_jugar", "inventario", "confirmar", "confirmar_nueva", "creditos"]:
		juego.menu.abrir(nombre)
		await get_tree().process_frame
		var panel: Panel = juego.menu._panel
		var contenido: VBoxContainer = juego.menu._contenido
		assert_true(contenido.position.y + contenido.get_combined_minimum_size().y <= panel.size.y - 24, "%s: el contenido cabe en el marco" % nombre)
		assert_true(panel.position.y >= 0 and panel.position.y + panel.size.y <= 720, "%s: el marco no sale de la pantalla" % nombre)
	juego.menu.abrir("inicio")
	assert_eq(_textos(juego), ["Continuar", "Nueva partida", "Cómo jugar", "Opciones", "Créditos", "Salir"])

func test_los_creditos_nombran_al_equipo_y_vuelven_al_inicio() -> void:
	var juego = _casino()
	juego.abrir_inicio()
	juego.menu.botones[3].pressed.emit()
	assert_eq(juego.menu.pantalla, "creditos")
	var textos := []
	for hijo in juego.menu._contenido.get_children():
		if hijo is Label: textos.append(hijo.text)
	for nombre in ["Julio", "Ariel", "Kenned"]:
		assert_has(textos, nombre)
	juego.menu.botones[0].pressed.emit()
	assert_eq(juego.menu.pantalla, "inicio")

func test_las_opciones_de_lectura_se_guardan_y_llegan_al_dialogo() -> void:
	var juego = _casino()
	juego.abrir_inicio()
	juego.menu.abrir("opciones")
	var panel = juego.menu._contenido.get_child(1)
	panel.lectura["tamano_texto"].value = 130
	panel.lectura["velocidad"].value = 120
	panel.lectura["opacidad"].value = 60
	assert_eq(AjustesJuego.lectura("tamano_texto"), 130)
	assert_eq(juego.dialogo.escala_texto, 1.3)
	assert_eq(juego.dialogo.velocidad, 0.0, "El máximo es instantáneo")
	assert_almost_eq(juego.dialogo.opacidad, 0.6, 0.001)
	assert_eq(juego.dialogo.texto.get_theme_font_size("font_size"), 29)
