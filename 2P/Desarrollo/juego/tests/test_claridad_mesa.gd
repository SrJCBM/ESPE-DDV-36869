extends GutTest

const Mesa = preload("res://mesa/mesa.tscn")

func after_each() -> void:
	await get_tree().process_frame

func _mesa(ids: Array = []):
	var mesa = Mesa.instantiate()
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	mesa.establecer_movimiento_reducido(true)
	mesa.controlador.cargar_demostracion()
	if not ids.is_empty():
		var orden: Array[CartaEnPartida] = []
		for id in ids:
			for carta in mesa.controlador.partida.mazo:
				if carta.definicion.id == id: orden.append(carta)
		for carta in mesa.controlador.partida.mazo:
			if not orden.has(carta): orden.append(carta)
		mesa.controlador.partida.mazo = orden
	mesa.controlador.procesar_comando(IniciarMano.new())
	return mesa

func test_senalar_racha_muestra_solo_las_ultimas_tres_sin_cambiar_la_mano() -> void:
	var mesa = _mesa(["llaves_01", "velas_02", "velas_04", "velas_06"])
	mesa.controlador.procesar_comando(PedirCarta.new())
	mesa.controlador.procesar_comando(PedirCarta.new())
	var antes: Dictionary = mesa.controlador.obtener_vista()
	var patron: Button = mesa.franja_patrones.get_child(4)
	patron.mouse_entered.emit()
	assert_false(mesa.mano.fila.get_child(0).get_meta("patron_resaltado", false))
	for indice in range(1, 4):
		assert_true(mesa.mano.fila.get_child(indice).get_meta("patron_resaltado", false))
	assert_string_contains(mesa._mensaje.text, "últimas 3")
	assert_eq(mesa.controlador.obtener_vista(), antes)
	patron.mouse_exited.emit()
	for carta in mesa.mano.fila.get_children():
		assert_false(carta.get_meta("patron_resaltado", false))

func test_foco_de_teclado_explica_ascenso_y_al_salir_limpia_resaltado() -> void:
	var mesa = _mesa()
	mesa.controlador.procesar_comando(PedirCarta.new())
	mesa.franja_patrones.get_child(2).grab_focus()
	for carta in mesa.mano.fila.get_children():
		assert_true(carta.get_meta("patron_resaltado", false))
	assert_string_contains(mesa._mensaje.text, "menor a mayor")
	mesa.boton_plantarse.grab_focus()
	for carta in mesa.mano.fila.get_children():
		assert_false(carta.get_meta("patron_resaltado", false))

func test_racha_con_mascaras_no_filtra_valores_ni_promete_puntos() -> void:
	var mesa = _mesa(["mascaras_01", "mascaras_03", "mascaras_05"])
	mesa.controlador.procesar_comando(PedirCarta.new())
	mesa.franja_patrones.get_child(4).mouse_entered.emit()
	var texto: String = mesa._mensaje.text
	assert_string_contains(texto, "revelar")
	for carta in mesa.mano.fila.get_children():
		assert_eq(carta._valor.text, "?")
		assert_null(carta._vista.valor)
	mesa.controlador.partida.mano[-1].definicion.valor_impreso = 10
	mesa.presentar_vista(mesa.controlador.obtener_vista())
	mesa.franja_patrones.get_child(4).mouse_entered.emit()
	assert_eq(mesa._mensaje.text, texto)

func test_ayuda_y_eleccion_llave_no_dejan_un_patron_activo_detras() -> void:
	var mesa = _mesa()
	mesa.franja_patrones.get_child(2).grab_focus()
	mesa.mostrar_devolucion()
	assert_true(mesa.eleccion_llave.visible)
	assert_true(mesa.mano.fila.get_child(0)._seleccionada)
	for carta in mesa.mano.fila.get_children():
		assert_false(carta.get_meta("patron_resaltado", false))
	mesa.eleccion_llave.cancelar()
	mesa.franja_patrones.get_child(2).grab_focus()
	mesa.mostrar_ayuda()
	for carta in mesa.mano.fila.get_children():
		assert_false(carta.get_meta("patron_resaltado", false))
	mesa.cerrar_modal()
	await get_tree().process_frame

func test_resultado_102_explica_sus_bonos_junto_a_la_mano() -> void:
	var mesa = _mesa()
	mesa.controlador.procesar_comando(PedirCarta.new())
	mesa.controlador.procesar_comando(Plantarse.new())
	assert_eq(mesa._lectura.text, "17 × 6 = 102")
	assert_string_contains(mesa._explicacion.text, "Exacto +3")
	assert_string_contains(mesa._explicacion.text, "Ascenso +2")
	assert_true(mesa.boton_desglose.visible)

func test_quiebra_explica_exceso_real_y_cero_aporte() -> void:
	var mesa = _mesa(["velas_10", "velas_06", "mascaras_03"])
	mesa.controlador.procesar_comando(PedirCarta.new())
	mesa.controlador.procesar_comando(Plantarse.new())
	assert_string_contains(mesa._lectura.text, "0 puntos")
	assert_string_contains(mesa._explicacion.text, "por 2")
	assert_eq(mesa.vista.puntos, 0)

func test_final_resume_manos_y_quiebras_una_sola_vez_y_reintentar_limpia() -> void:
	var mesa = _mesa()
	for pedidos in [1, 1, 2]:
		if not mesa.vista.get("ultima_mano", {}).is_empty():
			mesa.controlador.procesar_comando(IniciarMano.new())
		for i in range(pedidos): mesa.controlador.procesar_comando(PedirCarta.new())
		mesa.controlador.procesar_comando(Plantarse.new())
	assert_true(mesa.vista.victoria)
	var resumen: Dictionary = mesa.vista.get("resumen_intento", {})
	assert_eq(resumen.get("manos", -1), 3)
	assert_eq(resumen.get("validas", -1), 2)
	assert_eq(resumen.get("quiebras", -1), 1)
	mesa.controlador.procesar_comando(Plantarse.new())
	assert_eq(mesa.controlador.obtener_vista().get("resumen_intento", {}), resumen)
	assert_string_contains(mesa._mensaje.text, "3 manos")
	assert_false(mesa.boton_iniciar_pedir.disabled)
	assert_eq(mesa.boton_iniciar_pedir.get_node("Etiqueta").text, "VOLVER A JUGAR")
	mesa._iniciar_o_pedir()
	assert_eq(mesa.vista.puntos, 0)
	assert_eq(mesa.vista.campanadas, 10)
	assert_eq(mesa.mano.fila.get_child_count(), 0)
	assert_eq(mesa.vista.get("resumen_intento", {}).get("quiebras", -1), 0)

func test_enter_en_volver_a_jugar_reinicia_una_vez_sin_iniciar_otra_mano() -> void:
	var mesa = _mesa()
	mesa.controlador.partida.campanadas = 0
	mesa.controlador.procesar_comando(Plantarse.new())
	assert_false(mesa.vista.victoria)
	assert_eq(mesa.get_viewport().gui_get_focus_owner(), mesa.boton_iniciar_pedir)
	for pulsada in [true, false]:
		var evento := InputEventKey.new()
		evento.keycode = KEY_ENTER
		evento.pressed = pulsada
		Input.parse_input_event(evento)
		await get_tree().process_frame
	assert_eq(mesa.vista.campanadas, 10)
	assert_eq(mesa.vista.numero_mano, 0)
	assert_false(mesa.vista.terminado)
	assert_false(mesa.modal.visible)

func test_resumen_solo_cuenta_manos_resueltas_y_vista_no_modifica_contadores() -> void:
	var mesa = _mesa()
	assert_eq(mesa.vista.resumen_intento.manos, 0)
	mesa.controlador.procesar_comando(Plantarse.new())
	var vista: Dictionary = mesa.controlador.obtener_vista()
	assert_eq(vista.resumen_intento.manos, 1)
	vista.resumen_intento.quiebras = 99
	mesa.controlador.procesar_comando(IniciarMano.new())
	assert_eq(mesa.vista.resumen_intento.manos, 1)
	assert_eq(mesa.vista.resumen_intento.quiebras, 0)
