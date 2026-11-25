extends GutTest

const Mesa = preload("res://mesa/mesa.tscn")

func _crear(ids: Array) -> ControladorMesa:
	var c := ControladorMesa.new()
	add_child_autofree(c)
	var orden: Array[CartaEnPartida] = []
	for id in ids:
		for carta: CartaEnPartida in c.partida.mazo:
			if carta.definicion.id == id: orden.append(carta)
	for carta: CartaEnPartida in c.partida.mazo:
		if not orden.has(carta): orden.append(carta)
	c.partida.mazo = orden
	return c

func test_se_paga_solo_una_campanada_por_mano_aunque_se_pidan_varias() -> void:
	var c := _crear(["llaves_01", "velas_02", "relojes_01", "mascaras_03"])
	c.procesar_comando(IniciarMano.new())
	assert_eq(c.partida.campanadas, 9)
	for i in range(2):
		assert_true(c.procesar_comando(PedirCarta.new()).aceptado)
	assert_eq(c.partida.campanadas, 9)
	c.procesar_comando(Plantarse.new())
	assert_eq(c.partida.campanadas, 9)
	c.procesar_comando(IniciarMano.new())
	assert_eq(c.partida.campanadas, 8)

func test_ultima_mano_permite_pedir_y_no_pierde_antes_de_plantarse() -> void:
	var c := _crear(["llaves_04", "relojes_06", "mascaras_08"])
	c.partida.campanadas = 1
	c.procesar_comando(IniciarMano.new())
	assert_eq(c.partida.campanadas, 0)
	assert_true(c.obtener_vista().acciones.pedir)
	assert_true(c.procesar_comando(PedirCarta.new()).aceptado)
	assert_false(c.obtener_vista().terminado)
	assert_true(c.obtener_vista().cartas[-1].oculta)
	c.partida.puntos = 98
	c.procesar_comando(Plantarse.new())
	assert_true(c.obtener_vista().victoria)
	assert_eq(c.obtener_vista().cartas[-1].valor, 8)
	assert_eq(c.partida.puntos, 200)

func test_exceso_demostrable_con_mascara_espera_revelacion_y_no_filtra_valor() -> void:
	var c := _crear(["velas_10", "mascaras_08", "velas_08"])
	c.partida.campanadas = 1
	c.procesar_comando(IniciarMano.new())
	c.procesar_comando(PedirCarta.new())
	var antes := c.obtener_vista()
	assert_eq(antes.fase, "decision")
	assert_false(antes.terminado)
	assert_false(antes.acciones.pedir)
	assert_true(antes.acciones.plantarse)
	assert_true(antes.cartas[1].oculta)
	assert_true(antes.ultima_mano.is_empty())
	c.partida.mano[1].definicion.valor_impreso = 1
	assert_eq(c.obtener_vista(), antes)
	c.procesar_comando(Plantarse.new())
	assert_true(c.obtener_vista().terminado)
	assert_false(c.obtener_vista().victoria)
	assert_eq(c.obtener_vista().cartas[1].valor, 1)
	assert_true(c.obtener_vista().ultima_mano.quiebra)

func test_patrones_publicos_muestran_progreso_sin_inferir_mascaras() -> void:
	var c := _crear(["llaves_04", "relojes_06", "mascaras_08"])
	c.procesar_comando(IniciarMano.new())
	var patrones: Array = c.obtener_vista().patrones_visibles
	assert_eq(patrones.size(), 5)
	assert_eq(patrones[2].nombre, "Ascenso")
	assert_string_contains(patrones[2].detalle, "2/3")
	c.procesar_comando(PedirCarta.new())
	var antes: Array = c.obtener_vista().patrones_visibles
	assert_eq(antes[0].estado, "pendiente")
	assert_eq(antes[2].estado, "pendiente")
	c.partida.mano[-1].definicion.valor_impreso = 1
	assert_eq(c.obtener_vista().patrones_visibles, antes)
	c.partida.mano[-1].definicion.valor_impreso = 8
	c.procesar_comando(Plantarse.new())
	assert_eq(c.obtener_vista().patrones_visibles[0].estado, "activo")
	assert_eq(c.obtener_vista().patrones_visibles[2].estado, "activo")

func _mesa():
	var mesa = Mesa.instantiate()
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	mesa.controlador.cargar_demostracion()
	mesa.controlador.procesar_comando(IniciarMano.new())
	mesa.controlador.procesar_comando(PedirCarta.new())
	return mesa

func test_ui_revela_mascara_antes_del_cartel_de_victoria_y_permite_saltar() -> void:
	var mesa = _mesa()
	mesa.controlador.partida.puntos = 98
	mesa.controlador.partida.campanadas = 0
	mesa.controlador.procesar_comando(Plantarse.new())
	assert_true(mesa.revelacion.activa)
	assert_true(mesa.vista.cartas[-1].oculta)
	assert_false(mesa._titulo_estado.text.contains("VICTORIA"))
	mesa.revelacion.terminar()
	assert_false(mesa.revelacion.activa)
	assert_eq(mesa.mano.fila.get_child(2)._valor.text, "8")
	assert_true(mesa._titulo_estado.text.contains("VICTORIA"))
	assert_eq(mesa.vista.puntos, 200)
	mesa.revelacion.terminar()
	assert_eq(mesa.controlador.partida.puntos, 200)
	await get_tree().create_timer(0.9).timeout

func test_reinicio_durante_revelacion_no_restaura_una_derrota_antigua() -> void:
	var mesa = _mesa()
	mesa.controlador.partida.campanadas = 0
	mesa.controlador.procesar_comando(Plantarse.new())
	assert_true(mesa.revelacion.activa)
	mesa._reiniciar()
	await get_tree().create_timer(0.9).timeout
	assert_false(mesa.revelacion.activa)
	assert_eq(mesa.vista.puntos, 0)
	assert_eq(mesa.vista.campanadas, 10)
	assert_false(mesa.vista.terminado)
	assert_eq(mesa.mano.fila.get_child_count(), 0)

func test_movimiento_reducido_revela_sin_esperar_y_patrones_abren_su_ayuda() -> void:
	var mesa = _mesa()
	mesa.establecer_movimiento_reducido(true)
	mesa.controlador.procesar_comando(Plantarse.new())
	assert_false(mesa.revelacion.activa)
	assert_eq(mesa.vista.puntos, 102)
	assert_eq(mesa.mano.fila.get_child(2)._valor.text, "8")
	assert_eq(mesa.franja_patrones.get_child_count(), 5)
	mesa.franja_patrones.get_child(2).pressed.emit()
	assert_true(mesa.modal.visible)
	assert_eq(mesa.modal.contenido.get_node("Reglamento").pagina_actual, 2)
	mesa.cerrar_modal()
	await get_tree().process_frame

func test_revelacion_automatica_muestra_el_valor_tambien_si_se_pierde() -> void:
	var mesa = _mesa()
	mesa.controlador.partida.campanadas = 0
	mesa.controlador.procesar_comando(Plantarse.new())
	assert_false(mesa._titulo_estado.text.contains("DERROTA"))
	await get_tree().create_timer(0.7).timeout
	assert_false(mesa.revelacion.activa)
	assert_eq(mesa.mano.fila.get_child(2)._valor.text, "8")
	assert_true(mesa._titulo_estado.text.contains("DERROTA"))
	assert_eq(mesa.vista.puntos, 102)

func test_dos_mascaras_se_revelan_en_orden_antes_del_resultado() -> void:
	var mesa = _mesa()
	mesa.controlador.reiniciar(3)
	mesa.controlador.partida.mazo.assign([
		FabricaCartas.crear_carta(Palos.MASCARAS, 9),
		FabricaCartas.crear_carta(Palos.MASCARAS, 2),
	])
	mesa.controlador.procesar_comando(IniciarMano.new())
	mesa.controlador.procesar_comando(Plantarse.new())
	await mesa.revelacion.carta_revelada
	assert_eq(mesa.mano.fila.get_child(0)._valor.text, "9")
	assert_true(mesa.mano.fila.get_child(1)._vista.oculta)
	assert_false(mesa.boton_desglose.visible)
	await mesa.revelacion.carta_revelada
	assert_eq(mesa.mano.fila.get_child(1)._valor.text, "2")
	assert_false(mesa.boton_desglose.visible)
	await mesa.revelacion.terminada
	await get_tree().process_frame
	assert_true(mesa.boton_desglose.visible)
	assert_eq(mesa.vista.ultima_mano.total, 11)

func test_ascenso_no_promete_huecos_imposibles_con_cotas_publicas() -> void:
	var c := _crear(["mascaras_08", "llaves_01", "velas_02"])
	c.procesar_comando(IniciarMano.new())
	c.procesar_comando(PedirCarta.new())
	assert_eq(c.obtener_vista().patrones_visibles[2].estado, "inactivo")
	var antes: Array = c.obtener_vista().patrones_visibles
	c.partida.mano[0].definicion.valor_impreso = 1
	assert_eq(c.obtener_vista().patrones_visibles, antes)

func test_patrones_nuevos_no_roban_foco_detras_del_libro() -> void:
	var mesa = Mesa.instantiate()
	mesa.conectar_controlador = false
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	mesa.mostrar_ayuda()
	var foco = mesa.get_viewport().gui_get_focus_owner()
	var controlador := _crear(["llaves_04", "relojes_06"])
	controlador.procesar_comando(IniciarMano.new())
	mesa.presentar_vista(controlador.obtener_vista())
	for boton in mesa.franja_patrones.get_children():
		assert_eq(boton.focus_mode, Control.FOCUS_NONE)
	assert_eq(mesa.get_viewport().gui_get_focus_owner(), foco)
	mesa.cerrar_modal()
	for boton in mesa.franja_patrones.get_children():
		assert_eq(boton.focus_mode, Control.FOCUS_ALL)

func test_cada_patron_abre_un_ejemplo_correcto_con_cartas_reales() -> void:
	var mesa = _mesa()
	mesa.establecer_movimiento_reducido(true)
	mesa.controlador.procesar_comando(Plantarse.new())
	var baraja: Array = FabricaCartas.crear_baraja()
	for indice in range(5):
		mesa.franja_patrones.get_child(indice).pressed.emit()
		var guia = mesa.modal.contenido.get_node("Reglamento")
		var mano: Array = []
		for nodo in guia.find_children("*", "Button", true, false):
			if not nodo.has_method("presentar"): continue
			for carta in baraja:
				if carta.definicion.palo == nodo._vista.palo and carta.definicion.valor_impreso == nodo._vista.valor:
					mano.append(carta)
					break
		var resultado: Dictionary = EvaluadorMano.evaluar(mano)
		assert_true(resultado.patrones.has(mesa.vista.patrones_visibles[indice].nombre))
		assert_string_contains(guia.find_child("EjemploPuntos", true, false).text, "%s puntos" % resultado.puntos)
		mesa.cerrar_modal()
		await get_tree().process_frame

func test_racha_formada_con_mascaras_no_se_anuncia_como_bono_seguro() -> void:
	var c := _crear(["mascaras_01", "mascaras_03", "mascaras_05"])
	c.procesar_comando(IniciarMano.new())
	c.procesar_comando(PedirCarta.new())
	var mesa = Mesa.instantiate()
	mesa.conectar_controlador = false
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	mesa.presentar_vista(c.obtener_vista())
	var racha: Button = mesa.franja_patrones.get_child(4)
	assert_false(racha.text.contains("LISTO"))
	assert_string_contains(racha.text, "al revelar")

func test_la_franja_muestra_nombre_y_bono_de_cada_patron() -> void:
	var c := _crear(["velas_02", "velas_04", "velas_06"])
	c.procesar_comando(IniciarMano.new())
	c.procesar_comando(PedirCarta.new())
	var mesa = Mesa.instantiate()
	mesa.conectar_controlador = false
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	mesa.presentar_vista(c.obtener_vista())
	var esperados := ["Punto exacto +3", "Al filo +2", "Ascenso +2", "Mano larga +2", "Racha +2"]
	var ancho := 0.0
	for i in esperados.size():
		var boton: Button = mesa.franja_patrones.get_child(i)
		assert_true(boton.text.begins_with(esperados[i]), boton.text)
		ancho += boton.custom_minimum_size.x
	assert_lte(ancho + 4 * 6, mesa.franja_patrones.size.x, "Los cinco caben en la franja")
	assert_string_contains(mesa.franja_patrones.get_child(4).text, "Activo")
