extends GutTest
## Respuesta visual al resolver: debe volver siempre al reposo y terminar en los textos finales.

const Mesa = preload("res://mesa/mesa.tscn")

func after_each() -> void:
	await get_tree().process_frame

func _mesa(ids: Array, reducido := false):
	var mesa = Mesa.instantiate()
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	mesa.establecer_movimiento_reducido(reducido)
	var orden: Array[CartaEnPartida] = []
	for id in ids:
		for carta in mesa.controlador.partida.mazo:
			if carta.definicion.id == id: orden.append(carta)
	for carta in mesa.controlador.partida.mazo:
		if not orden.has(carta): orden.append(carta)
	mesa.controlador.partida.mazo = orden
	mesa.controlador.procesar_comando(IniciarMano.new())
	return mesa

func _esperar(segundos: float) -> void:
	await get_tree().create_timer(segundos).timeout

func _assert_cartas_en_reposo(mesa) -> void:
	for carta in mesa.mano.fila.get_children():
		assert_eq(carta._visual.position, Vector2.ZERO, "posición de reposo")
		assert_eq(carta._visual.scale, Vector2.ONE, "escala de reposo")
		assert_eq(carta._visual.rotation, 0.0, "sin giro residual")
		assert_eq(carta._visual.modulate, Color.WHITE, "sin tinte residual")

func test_punto_exacto_cuenta_los_puntos_y_termina_en_el_resultado() -> void:
	# 8 + 9 = 17: Punto exacto sin Máscaras, así no hay revelación previa.
	var mesa = _mesa(["velas_08", "llaves_09"])
	mesa.controlador.procesar_comando(Plantarse.new())
	assert_true(mesa._feedback != null and mesa._feedback.is_valid(), "la cuenta está en marcha")
	assert_ne(mesa._lectura.text, "17 × 5 = 85", "empieza desde cero")
	await _esperar(1.1)
	assert_eq(mesa._lectura.text, "17 × 5 = 85")
	assert_eq(mesa._puntos.text, "85 / 200")
	assert_eq(mesa._lectura.scale, Vector2.ONE)
	_assert_cartas_en_reposo(mesa)

func test_quiebra_sacude_las_cartas_y_vuelve_al_reposo() -> void:
	var mesa = _mesa(["velas_10", "velas_08", "llaves_09"])
	mesa.controlador.procesar_comando(PedirCarta.new())
	mesa.controlador.procesar_comando(Plantarse.new())
	await get_tree().process_frame
	await get_tree().process_frame
	var movidas := 0
	for carta in mesa.mano.fila.get_children():
		if carta._visual.position != Vector2.ZERO or carta._visual.modulate != Color.WHITE: movidas += 1
	assert_gt(movidas, 0, "la Quiebra se nota en las cartas")
	assert_string_contains(mesa._lectura.text, "0 puntos")
	await _esperar(0.8)
	_assert_cartas_en_reposo(mesa)
	assert_eq(mesa._lectura.modulate, Color.WHITE)

func test_revelacion_de_mascara_termina_con_resultado_y_cartas_en_reposo() -> void:
	var mesa = _mesa(["llaves_04", "relojes_06", "mascaras_08"])
	mesa.controlador.procesar_comando(PedirCarta.new())
	mesa.controlador.procesar_comando(Plantarse.new())
	assert_true(mesa.revelacion.activa)
	await _esperar(1.8)
	assert_false(mesa.revelacion.activa)
	assert_eq(mesa._lectura.text, Lectura().resultado(mesa.vista).formula)
	_assert_cartas_en_reposo(mesa)

func test_movimiento_reducido_muestra_el_resultado_al_instante() -> void:
	var mesa = _mesa(["velas_08", "llaves_09"], true)
	mesa.controlador.procesar_comando(Plantarse.new())
	assert_eq(mesa._lectura.text, "17 × 5 = 85")
	assert_eq(mesa._puntos.text, "85 / 200")
	assert_null(mesa._feedback)
	_assert_cartas_en_reposo(mesa)

func test_activar_movimiento_reducido_a_mitad_de_cuenta_fija_el_resultado() -> void:
	var mesa = _mesa(["velas_08", "llaves_09"])
	mesa.controlador.procesar_comando(Plantarse.new())
	await get_tree().process_frame
	mesa.establecer_movimiento_reducido(true)
	assert_eq(mesa._lectura.text, "17 × 5 = 85")
	assert_eq(mesa._puntos.text, "85 / 200")
	_assert_cartas_en_reposo(mesa)

func test_iniciar_otra_mano_interrumpe_la_cuenta_sin_textos_viejos() -> void:
	var mesa = _mesa(["velas_08", "llaves_09", "velas_02", "velas_04"])
	mesa.controlador.procesar_comando(Plantarse.new())
	await get_tree().process_frame
	mesa.controlador.procesar_comando(IniciarMano.new())
	await _esperar(0.7)
	assert_eq(mesa._puntos.text, "85 / 200", "el acumulado no queda a medias")
	assert_eq(mesa._lectura.text, "6", "la lectura es la de la mano nueva")

func Lectura():
	return preload("res://mesa/lectura_mesa.gd")
