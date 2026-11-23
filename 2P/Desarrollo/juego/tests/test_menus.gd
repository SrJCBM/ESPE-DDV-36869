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
	assert_eq(_textos(juego), ["Entrar al casino", "Cómo jugar", "Opciones", "Salir"])
	assert_eq(juego.pagina.process_mode, Node.PROCESS_MODE_DISABLED)
	assert_false(juego.indicador_objetivo.visible)
	_esc(juego)
	assert_eq(juego.menu.pantalla, "inicio", "Esc no sale del inicio")
	juego.menu.botones[0].pressed.emit()
	assert_false(juego.menu.visible)
	assert_eq(juego.pagina.process_mode, Node.PROCESS_MODE_INHERIT)

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
	assert_string_contains(juego.menu._contenido.get_child(1).text, "24 cartas")
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
	assert_eq(juego.sala, "vestibulo")

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
