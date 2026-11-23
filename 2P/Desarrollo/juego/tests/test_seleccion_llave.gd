extends GutTest

const Mesa = preload("res://mesa/mesa.tscn")

func _mesa():
	var mesa = Mesa.instantiate()
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	mesa.establecer_movimiento_reducido(true)
	mesa.controlador.cargar_demostracion()
	mesa.controlador.procesar_comando(IniciarMano.new())
	return mesa

func test_clic_selecciona_llave_sin_ventana_ni_cambio_de_recursos() -> void:
	var mesa = _mesa()
	var antes: Dictionary = mesa.controlador.obtener_vista()
	var carta = mesa.mano.fila.get_child(0)
	carta.pressed.emit()
	assert_false(mesa.modal.visible)
	assert_true(mesa.eleccion_llave.visible)
	assert_eq(mesa.eleccion_llave.seleccionada, antes.cartas[0].id)
	assert_eq(mesa.controlador.obtener_vista(), antes)
	assert_true(carta._seleccionada)
	mesa.eleccion_llave.cancelar()
	assert_eq(mesa.eleccion_llave.seleccionada, "")
	assert_false(mesa.eleccion_llave.visible)
	assert_false(carta._seleccionada)
	assert_eq(mesa.controlador.obtener_vista(), antes)

func test_confirmar_devuelve_solo_la_elegida_y_reemplaza_al_final_gratis() -> void:
	var mesa = _mesa()
	var llave = mesa.mano.fila.get_child(0)
	var antes: Dictionary = mesa.controlador.obtener_vista()
	llave.pressed.emit()
	mesa.eleccion_llave.confirmar()
	var despues: Dictionary = mesa.controlador.obtener_vista()
	assert_eq(despues.campanadas, antes.campanadas)
	assert_eq(despues.cartas.size(), antes.cartas.size())
	assert_eq(despues.cartas[0].id, antes.cartas[1].id)
	assert_ne(despues.cartas[1].id, antes.cartas[0].id)
	assert_eq(despues.cartas[1].palo, "mascaras")
	assert_true(despues.cartas[1].oculta)
	assert_false(despues.acciones.devolver)
	assert_false(mesa.eleccion_llave.visible)
	# Una segunda confirmación tardía no ejecuta otro reemplazo.
	mesa.eleccion_llave.confirmar()
	assert_eq(mesa.controlador.obtener_vista(), despues)
	await get_tree().process_frame

func test_otro_robo_o_reinicio_invalida_confirmacion_pendiente() -> void:
	var mesa = _mesa()
	mesa.mano.fila.get_child(0).pressed.emit()
	mesa.controlador.procesar_comando(PedirCarta.new())
	var antes: Dictionary = mesa.controlador.obtener_vista()
	mesa.eleccion_llave.confirmar()
	assert_eq(mesa.controlador.obtener_vista(), antes)
	assert_false(mesa.eleccion_llave.visible)
	mesa._reiniciar()
	assert_eq(mesa.eleccion_llave.seleccionada, "")
	assert_eq(mesa.vista.campanadas, 10)
	await get_tree().process_frame

func test_escape_cancela_seleccion_y_carta_comun_conserva_ampliacion() -> void:
	var mesa = _mesa()
	mesa.mostrar_devolucion()
	var evento := InputEventKey.new()
	evento.keycode = KEY_ESCAPE
	evento.pressed = true
	mesa._unhandled_key_input(evento)
	assert_false(mesa.eleccion_llave.visible)
	assert_false(mesa.modal.visible)
	mesa.mano.fila.get_child(1).pressed.emit()
	assert_true(mesa.modal.visible)
	assert_eq(mesa.eleccion_llave.seleccionada, "")
	mesa.cerrar_modal()

func test_eleccion_permanece_dentro_de_mesa_sin_tapar_acciones() -> void:
	var mesa = _mesa()
	mesa.mostrar_devolucion()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_gte(mesa.eleccion_llave.position.x, 405.0)
	assert_lte(mesa.eleccion_llave.position.x + mesa.eleccion_llave.size.x, 1123.0)
	assert_lte(mesa.eleccion_llave.position.y + mesa.eleccion_llave.size.y, 599.0)
	assert_lt(mesa.eleccion_llave.get_global_rect().end.y, mesa.boton_iniciar_pedir.get_global_rect().position.y)
	var elegida: Control = mesa.eleccion_llave.carta_por_id(mesa.eleccion_llave.seleccionada)
	assert_almost_eq(mesa.eleccion_llave.get_global_rect().get_center().x, elegida.get_global_rect().get_center().x, 1.0, "La confirmación sigue a la carta elegida después de ordenar los contenedores")

func test_puntuacion_al_plantarse_solo_se_publica_sin_valores_ocultos() -> void:
	var mesa = _mesa()
	assert_eq(mesa.vista.resultado_visible.puntos, 9)
	assert_string_contains(mesa.boton_plantarse.get_node("Coste").text, "9 puntos")
	mesa.controlador.procesar_comando(PedirCarta.new())
	assert_true(mesa.vista.resultado_visible.is_empty())
	var antes: Dictionary = mesa.controlador.obtener_vista()
	mesa.controlador.partida.mano[-1].definicion.valor_impreso = 1
	assert_eq(mesa.controlador.obtener_vista(), antes, "La orientación tampoco puede filtrar Máscaras")

func test_atajos_se_ven_dentro_de_su_accion_y_no_bajo_el_borde() -> void:
	var mesa = _mesa()
	for boton in [mesa.boton_iniciar_pedir, mesa.boton_plantarse]:
		var tecla: Control = boton.get_node("Atajo")
		assert_true(boton.get_global_rect().encloses(tecla.get_global_rect()))
		assert_gte(tecla.size.y, 26.0)
	assert_null(mesa.lienzo.get_node_or_null("boton_llave"), "La devolución es contextual, sin botón permanente")

func _dos_llaves(mesa) -> void:
	mesa.controlador.reiniciar(0)
	var orden: Array[CartaEnPartida] = []
	for id in ["llaves_04", "llaves_05"]:
		for carta: CartaEnPartida in mesa.controlador.partida.mazo:
			if carta.definicion.id == id: orden.append(carta)
	for carta: CartaEnPartida in mesa.controlador.partida.mazo:
		if not orden.has(carta): orden.append(carta)
	mesa.controlador.partida.mazo = orden
	mesa.controlador.procesar_comando(IniciarMano.new())

func test_se_puede_elegir_la_segunda_llave_y_no_devuelve_la_primera() -> void:
	var mesa = _mesa()
	_dos_llaves(mesa)
	var antes: Dictionary = mesa.controlador.obtener_vista()
	mesa.mano.fila.get_child(1).pressed.emit()
	assert_eq(mesa.eleccion_llave.seleccionada, antes.cartas[1].id)
	mesa.eleccion_llave.confirmar()
	assert_eq(mesa.vista.cartas[0].id, antes.cartas[0].id)
	for carta in mesa.vista.cartas:
		assert_ne(carta.id, antes.cartas[1].id)
	assert_eq(mesa.vista.campanadas, 9)
	await get_tree().process_frame

func test_tecla_l_recorre_llaves_y_ayuda_cancela_la_eleccion_sin_devolver() -> void:
	var mesa = _mesa()
	_dos_llaves(mesa)
	var antes: Dictionary = mesa.controlador.obtener_vista()
	mesa.mostrar_devolucion()
	assert_eq(mesa.eleccion_llave.seleccionada, antes.cartas[0].id)
	mesa.mostrar_devolucion()
	assert_eq(mesa.eleccion_llave.seleccionada, antes.cartas[1].id)
	mesa.mostrar_ayuda()
	assert_true(mesa.modal.visible)
	assert_false(mesa.eleccion_llave.visible)
	assert_eq(mesa.eleccion_llave.seleccionada, "")
	assert_eq(mesa.controlador.obtener_vista(), antes)
	mesa.cerrar_modal()
	await get_tree().process_frame

func _enter() -> void:
	for pulsada in [true, false]:
		var evento := InputEventKey.new()
		evento.keycode = KEY_ENTER
		evento.pressed = pulsada
		Input.parse_input_event(evento)
		await get_tree().process_frame

func test_enter_elije_y_solo_un_segundo_enter_confirma() -> void:
	var mesa = _mesa()
	var antes: Dictionary = mesa.controlador.obtener_vista()
	mesa.mano.fila.get_child(0).grab_focus()
	await _enter()
	assert_eq(mesa.controlador.obtener_vista(), antes, "Seleccionar no confirma con el mismo evento")
	assert_true(mesa.eleccion_llave.visible)
	await _enter()
	assert_false(mesa.vista.acciones.devolver)
	assert_eq(mesa.vista.campanadas, 9)
	assert_ne(mesa.vista.cartas[0].id, antes.cartas[0].id)
	await get_tree().process_frame

func test_orientacion_y_riesgo_muestran_todas_sus_lineas() -> void:
	var mesa = _mesa()
	await get_tree().process_frame
	assert_eq(mesa._mensaje.get_visible_line_count(), mesa._mensaje.get_line_count())
	mesa.controlador.procesar_comando(PedirCarta.new())
	await get_tree().process_frame
	assert_eq(mesa._explicacion.get_visible_line_count(), mesa._explicacion.get_line_count())
	assert_eq(mesa._mensaje.get_visible_line_count(), mesa._mensaje.get_line_count())

func test_confirmacion_sigue_la_llave_despues_de_repartir_en_una_mesa_ya_abierta() -> void:
	var mesa = Mesa.instantiate()
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1280, 720)
	add_child_autofree(mesa)
	await get_tree().process_frame
	mesa.controlador.cargar_demostracion()
	mesa.controlador.procesar_comando(IniciarMano.new())
	mesa.mostrar_devolucion()
	for i in range(3): await get_tree().process_frame
	var elegida: Control = mesa.eleccion_llave.carta_por_id(mesa.eleccion_llave.seleccionada)
	assert_almost_eq(mesa.eleccion_llave.get_global_rect().get_center().x, elegida.get_global_rect().get_center().x, 1.0)
