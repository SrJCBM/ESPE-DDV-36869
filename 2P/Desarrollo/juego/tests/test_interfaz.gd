extends GutTest
## Contrato de presentación independiente de una partida o un reparto real.

const Mesa = preload("res://mesa/mesa.tscn")

func _mesa():
	var mesa = Mesa.instantiate()
	mesa.conectar_controlador = false
	mesa.set_anchors_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	return mesa

func _decision() -> Dictionary:
	return {"fase": "decision", "campanadas": 8, "presupuesto": 10,
		"puntos": 0, "meta": 200, "umbral": 17, "mazo": 21, "descarte": 0,
		"numero_mano": 1, "terminado": false, "victoria": false,
		"acciones": {"iniciar": false, "pedir": true, "plantarse": true,
			"devolver": false, "reiniciar": true},
		"cartas": [{"id": "opaco-1", "palo": "llaves", "valor": 4,
			"valor_efectivo": 4, "oculta": false},
			{"id": "opaco-2", "palo": "mascaras", "valor": null,
				"valor_efectivo": null, "oculta": true}],
		"intervalo": {"conocido": 4, "ocultas": 1, "minimo": 5, "maximo": 14},
		"llaves_disponibles": [], "ultima_mano": {}, "mensaje": "Decide sin prisa."}

func test_presenta_intervalo_y_habilita_solo_acciones_de_la_vista() -> void:
	var mesa = _mesa()
	mesa.presentar_vista(_decision())
	assert_eq(mesa.mano.fila.get_child_count(), 2)
	assert_eq(mesa._lectura.text, "5–14")
	assert_false(mesa.boton_iniciar_pedir.disabled)
	assert_false(mesa.boton_plantarse.disabled)
	assert_false(mesa.vista.acciones.devolver)
	assert_eq(mesa._contador.text, "8")

func test_mascara_elimina_datos_ocultos_de_ampliacion_y_tooltip() -> void:
	var mesa = _mesa()
	var datos := _decision()
	# Defensa adicional: incluso una vista defectuosa no revela el valor.
	datos.cartas[1].valor = 8
	datos.cartas[1].valor_efectivo = 8
	mesa.presentar_vista(datos)
	var carta = mesa.mano.fila.get_child(1)
	assert_null(carta._vista.valor)
	assert_null(carta._vista.valor_efectivo)
	assert_eq(carta._valor.text, "?")
	assert_false(carta.tooltip_text.contains("8"))
	mesa.mostrar_carta(carta._vista)
	var ampliada = mesa.modal.contenido.get_child(1)
	assert_eq(ampliada._valor.text, "?")
	assert_null(ampliada._vista.valor)
	mesa.cerrar_modal()

func test_cancelar_llave_no_modifica_vista_ni_cartas() -> void:
	var mesa = _mesa()
	var datos := _decision()
	datos.acciones.devolver = true
	datos.llaves_disponibles = ["opaco-1"]
	mesa.presentar_vista(datos)
	var carta: Control = mesa.mano.fila.get_child(0)
	carta.grab_focus()
	mesa.mostrar_devolucion()
	assert_false(mesa.modal.visible)
	assert_true(mesa.eleccion_llave.visible)
	mesa.eleccion_llave.cancelar()
	assert_eq(mesa.vista, datos)
	assert_eq(mesa.mano.fila.get_child_count(), 2)
	assert_eq(mesa.get_viewport().gui_get_focus_owner(), carta)

func test_ayuda_suspende_foco_de_mesa_y_lo_devuelve() -> void:
	var mesa = _mesa()
	mesa.presentar_vista(_decision())
	mesa.boton_ayuda.grab_focus()
	mesa.mostrar_ayuda()
	assert_eq(mesa.boton_iniciar_pedir.focus_mode, Control.FOCUS_NONE)
	assert_eq(mesa.modal.contenido.get_node("Reglamento").pagina_actual, 0)
	mesa.cerrar_modal()
	assert_eq(mesa.boton_iniciar_pedir.focus_mode, Control.FOCUS_ALL)
	assert_eq(mesa.get_viewport().gui_get_focus_owner(), mesa.boton_ayuda)

func test_cambiar_el_dialogo_abierto_conserva_el_foco_original() -> void:
	var mesa = _mesa()
	var vista := _decision()
	mesa.presentar_vista(vista)
	mesa.boton_ayuda.grab_focus()
	mesa.mostrar_ayuda()
	var audio := AudioCasino.new()
	add_child_autofree(audio)
	mesa.activar_audio(audio)
	assert_false(mesa.lienzo.has_node("boton_sonido"), "El volumen está en el menú de pausa")
	mesa.mostrar_carta(vista.cartas[1])
	assert_false(mesa.modal.contenido.has_node("Reglamento"))
	assert_eq(mesa.boton_ayuda.focus_mode, Control.FOCUS_NONE)
	mesa.cerrar_modal()
	assert_eq(mesa.boton_ayuda.focus_mode, Control.FOCUS_ALL)
	assert_eq(mesa.get_viewport().gui_get_focus_owner(), mesa.boton_ayuda)

func test_mano_larga_permanece_en_contenedor_desplazable() -> void:
	var mesa = _mesa()
	var datos := _decision()
	for indice in range(10):
		datos.cartas.append({"id": "c%s" % indice, "palo": "velas", "valor": 1,
			"valor_efectivo": 1, "oculta": false})
	mesa.presentar_vista(datos)
	assert_eq(mesa.mano.fila.get_child_count(), 12)
	assert_eq(mesa.mano.scroll.horizontal_scroll_mode, ScrollContainer.SCROLL_MODE_AUTO)
	assert_eq(mesa.mano.scroll.vertical_scroll_mode, ScrollContainer.SCROLL_MODE_DISABLED)

func test_accion_que_se_deshabilita_transfiere_foco_a_siguiente_legal() -> void:
	var mesa = _mesa()
	var datos := _decision()
	mesa.presentar_vista(datos)
	mesa.boton_iniciar_pedir.grab_focus()
	datos.acciones.pedir = false
	mesa.presentar_vista(datos)
	await get_tree().process_frame
	assert_eq(mesa.get_viewport().gui_get_focus_owner(), mesa.boton_plantarse)

func test_reglamento_cambia_paginas_sin_tocar_partida_y_conserva_opcion_de_movimiento() -> void:
	# La opción del libro se guarda: se redirige a un archivo de prueba.
	var ruta_original := AjustesJuego.ruta
	AjustesJuego.ruta = "user://ajustes_prueba_interfaz.cfg"
	var mesa = _mesa()
	mesa.presentar_vista(_decision())
	var antes: Dictionary = mesa.vista.duplicate(true)
	mesa.mostrar_ayuda()
	var guia = mesa.modal.contenido.get_node("Reglamento")
	for indice in range(4):
		guia.ir_a_pagina(indice)
		assert_eq(guia.pagina_actual, indice)
		assert_eq(guia.navegacion[indice].button_pressed, true)
	assert_eq(mesa.vista, antes)
	guia.movimiento.button_pressed = true
	assert_true(mesa.movimiento_reducido)
	mesa.cerrar_modal()
	mesa.mostrar_ayuda()
	assert_true(mesa.modal.contenido.get_node("Reglamento").movimiento.button_pressed)
	mesa.cerrar_modal()
	await get_tree().process_frame
	assert_true(AjustesJuego.movimiento_reducido(), "La elección queda guardada")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(AjustesJuego.ruta))
	AjustesJuego.ruta = ruta_original

func test_actualizar_misma_mano_conserva_cartas_y_foco() -> void:
	var mesa = _mesa()
	mesa.presentar_vista(_decision())
	var carta: Control = mesa.mano.fila.get_child(0)
	carta.grab_focus()
	mesa.presentar_vista(_decision())
	assert_same(mesa.mano.fila.get_child(0), carta)
	assert_eq(mesa.get_viewport().gui_get_focus_owner(), carta)

func test_movimiento_reducido_y_reinicio_cancelan_transiciones_sin_datos_antiguos() -> void:
	var mesa = Mesa.instantiate()
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	mesa.controlador.cargar_demostracion()
	mesa.controlador.procesar_comando(IniciarMano.new())
	mesa.controlador.procesar_comando(PedirCarta.new())
	mesa.establecer_movimiento_reducido(true)
	for carta in mesa.mano.fila.get_children():
		assert_eq(carta._visual.modulate.a, 1.0)
		assert_eq(carta._visual.scale, Vector2.ONE)
	mesa.controlador.procesar_comando(Plantarse.new())
	mesa._reiniciar()
	await get_tree().create_timer(0.45).timeout
	assert_eq(mesa.mano.fila.get_child_count(), 0)
	assert_eq(mesa._puntos.text, "0 / 200")
	assert_eq(mesa.vista.campanadas, 10)

func test_ejemplo_del_libro_no_tapa_la_formula_ni_el_boton_de_salida() -> void:
	var mesa = _mesa()
	mesa.mostrar_ayuda()
	var guia = mesa.modal.contenido.get_node("Reglamento")
	guia.ir_a_pagina(2)
	await get_tree().process_frame
	for carta in guia.find_children("*", "Button", true, false):
		if carta.has_method("presentar"):
			assert_lte(carta.get_global_rect().end.y, guia.get_global_rect().end.y)
			assert_lte(carta.get_global_rect().end.x, guia.get_global_rect().position.x + 545 * mesa.lienzo.scale.x)
	mesa.cerrar_modal()

func test_actualizacion_con_modal_no_roba_foco_y_cartas_nuevas_no_lo_admiten() -> void:
	var mesa = _mesa()
	var datos := _decision()
	mesa.presentar_vista(datos)
	mesa.boton_ayuda.grab_focus()
	mesa.mostrar_ayuda()
	var foco = mesa.get_viewport().gui_get_focus_owner()
	datos.terminado = true
	datos.victoria = true
	datos.fase = "finalizada"
	mesa.presentar_vista(datos)
	await get_tree().process_frame
	assert_eq(mesa.get_viewport().gui_get_focus_owner(), foco)
	assert_eq(mesa.mano.fila.get_child(0).focus_mode, Control.FOCUS_NONE)
	mesa.cerrar_modal()
	assert_eq(mesa.mano.fila.get_child(0).focus_mode, Control.FOCUS_ALL)
	assert_eq(mesa.get_viewport().gui_get_focus_owner(), mesa.boton_ayuda)

func _controlador_r11():
	var controlador := ControladorMesa.new()
	add_child_autofree(controlador)
	controlador.cargar_demostracion()
	controlador.procesar_comando(IniciarMano.new())
	controlador.procesar_comando(PedirCarta.new())
	return controlador

func test_r11_muestra_conocido_nueve_mas_oculta_e_intervalo_y_no_desglose() -> void:
	var controlador = _controlador_r11()
	var mesa = _mesa()
	mesa.presentar_vista(controlador.obtener_vista())
	assert_eq(mesa._lectura.text, "10–19")
	assert_string_contains(mesa._explicacion.text, "9 + ?")
	assert_string_contains(mesa._explicacion.text, "1 oculta")
	assert_eq(mesa._umbral.text, "17", "El umbral sigue visible, sin repetirlo junto al intervalo")
	assert_false(mesa.boton_desglose.visible)
	mesa.mostrar_desglose()
	assert_false(mesa.modal.visible, "Un resultado no puede adelantarse mientras hay una Máscara oculta")

func test_desglose_102_usa_bonos_reales_y_devuelve_foco() -> void:
	var controlador = _controlador_r11()
	controlador.procesar_comando(Plantarse.new())
	var mesa = _mesa()
	mesa.presentar_vista(controlador.obtener_vista())
	assert_true(mesa.boton_desglose.visible)
	mesa.boton_desglose.grab_focus()
	mesa.mostrar_desglose()
	var texto: String = mesa.modal.contenido.get_node("DesgloseResultado").text
	assert_string_contains(texto, "4 + 5 + 8 = 17")
	assert_string_contains(texto, "Base: 1")
	assert_string_contains(texto, "Punto exacto: +3")
	assert_string_contains(texto, "Ascenso: +2")
	assert_string_contains(texto, "17 × 6 = 102 PUNTOS")
	mesa.cerrar_modal()
	assert_eq(mesa.get_viewport().gui_get_focus_owner(), mesa.boton_desglose)

func test_desglose_quiebra_muestra_solo_resultado_revelado_y_cero_puntos() -> void:
	var controlador = _controlador_r11()
	controlador.procesar_comando(Plantarse.new())
	controlador.procesar_comando(IniciarMano.new())
	controlador.procesar_comando(PedirCarta.new())
	var mesa = _mesa()
	mesa.establecer_movimiento_reducido(true)
	mesa.presentar_vista(controlador.obtener_vista())
	assert_false(mesa.boton_desglose.visible)
	controlador.procesar_comando(Plantarse.new())
	mesa.presentar_vista(controlador.obtener_vista())
	await get_tree().process_frame
	assert_true(mesa.boton_desglose.visible)
	mesa.mostrar_desglose()
	var texto: String = mesa.modal.contenido.get_node("DesgloseResultado").text
	assert_string_contains(texto, "6 + 6 + 10 = 22")
	assert_string_contains(texto, "QUIEBRA")
	assert_string_contains(texto, "RESULTADO: 0 PUNTOS")
	assert_false(texto.contains("?"))
	assert_false(texto.contains("Punto exacto: +3"))
	for carta in mesa.vista.cartas:
		assert_false(carta.oculta)
	mesa.cerrar_modal()

func test_confirmacion_larga_envuelve_y_permanece_dentro_del_panel() -> void:
	var mesa = _mesa()
	mesa._confirmar("DEMOSTRACIÓN GUIADA", "Reinicia el intento y prepara tres manos: 102 puntos, una Quiebra y 119 puntos. Tú decides cuándo pedir y plantarte; la baraja está preparada para aprender.", func() -> void: pass)
	await get_tree().process_frame
	var descripcion: Label = mesa.modal.contenido.get_child(1)
	assert_eq(descripcion.autowrap_mode, TextServer.AUTOWRAP_WORD_SMART)
	assert_lte(descripcion.size.x, mesa.modal.panel.size.x - 96.0)
	assert_lte(descripcion.position.x + descripcion.size.x, mesa.modal.panel.size.x - 48.0)
	assert_gt(descripcion.get_line_count(), 1, "La descripción debe envolver varias líneas dentro del panel")
	mesa.cerrar_modal()

func test_mensajes_y_devolucion_conservan_anchos_del_diseno() -> void:
	var mesa = _mesa()
	var datos := _decision()
	datos.mensaje = "Decide sin prisa: antes de confirmar una petición revisa el intervalo, el umbral y las oportunidades disponibles para continuar tu mano."
	datos.acciones.devolver = true
	datos.llaves_disponibles = ["opaco-1"]
	mesa.presentar_vista(datos)
	mesa.mostrar_devolucion()
	await get_tree().process_frame
	assert_false(mesa.modal.visible)
	assert_true(mesa.eleccion_llave.visible)
	assert_lte(mesa.eleccion_llave.position.x + mesa.eleccion_llave.size.x, 1123.0)
	assert_lte(mesa._mensaje.size.x, 684.0)
	assert_lte(mesa._mensaje.get_line_count(), 2)
	assert_eq(mesa._mensaje.get_visible_line_count(), mesa._mensaje.get_line_count())
	# Las acciones están en la columna derecha: el mensaje no debe invadirla.
	assert_lte(mesa._mensaje.get_global_rect().end.x, mesa.boton_iniciar_pedir.get_global_rect().position.x)
	mesa.eleccion_llave.cancelar()

func test_resumen_de_varios_patrones_no_desborda_su_rectangulo() -> void:
	var controlador = _controlador_r11()
	controlador.procesar_comando(Plantarse.new())
	var datos: Dictionary = controlador.obtener_vista()
	# Prueba de longitud: el resumen debe aguantar un catálogo futuro más extenso.
	datos.ultima_mano.patrones = ["Punto exacto", "Al filo", "Ascenso", "Mano larga", "Racha"]
	datos.ultima_mano.bonos = {"Punto exacto": 3, "Al filo": 2, "Ascenso": 2, "Mano larga": 2, "Racha": 2}
	var mesa = _mesa()
	mesa.presentar_vista(datos)
	await get_tree().process_frame
	assert_lte(mesa._explicacion.size.x, 680.0)
	assert_lte(mesa._explicacion.position.x + mesa._explicacion.size.x, 1123.0)
	assert_eq(mesa._explicacion.get_visible_line_count(), mesa._explicacion.get_line_count())
	assert_string_contains(mesa._explicacion.text, "Exacto +3")

func _vista_con_cartas(cantidad: int) -> Dictionary:
	var datos := _decision()
	datos.cartas.clear()
	for indice in range(cantidad):
		datos.cartas.append({"id": "prueba-%s" % indice, "palo": "velas",
			"valor": 1, "valor_efectivo": 1, "oculta": false})
	return datos

func test_cuatro_cartas_completas_caben_sin_desplazamiento() -> void:
	var mesa = _mesa()
	mesa.presentar_vista(_vista_con_cartas(4))
	await get_tree().process_frame
	await get_tree().process_frame
	var ultima: Control = mesa.mano.fila.get_child(3)
	assert_lte(ultima.get_global_rect().end.x, mesa.mano.scroll.get_global_rect().end.x)
	assert_lte(mesa.mano.fila.size.x, 704.0)
	assert_eq(mesa.mano.scroll.scroll_horizontal, 0)

func test_cinco_cartas_completas_caben_sin_desplazamiento() -> void:
	var mesa = _mesa()
	mesa.presentar_vista(_vista_con_cartas(5))
	await get_tree().process_frame
	await get_tree().process_frame
	var ultima: Control = mesa.mano.fila.get_child(4)
	assert_lte(ultima.get_global_rect().end.x, mesa.mano.scroll.get_global_rect().end.x)
	assert_lte(mesa.mano.fila.size.x, 704.0)
	assert_eq(mesa.mano.scroll.scroll_horizontal, 0)

func test_doce_cartas_conservan_tamano_y_muestran_la_ultima_al_robar() -> void:
	var mesa = _mesa()
	mesa.presentar_vista(_vista_con_cartas(12))
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var primera: Control = mesa.mano.fila.get_child(0)
	var ultima: Control = mesa.mano.fila.get_child(11)
	assert_eq(ultima.size, Vector2(184, preload("res://mesa/interfaz/composicion_mesa.gd").ALTO_CARTA))
	assert_gt(mesa.mano.scroll.scroll_horizontal, 0)
	assert_lte(ultima.get_global_rect().end.x, mesa.mano.scroll.get_global_rect().end.x)
	assert_lt(primera.get_global_rect().position.x, mesa.mano.scroll.get_global_rect().position.x)

func test_actualizar_mano_larga_durante_modal_conserva_desplazamiento() -> void:
	var mesa = _mesa()
	mesa.presentar_vista(_vista_con_cartas(12))
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	mesa.mano.scroll.scroll_horizontal = 0
	mesa.mostrar_ayuda()
	mesa.presentar_vista(_vista_con_cartas(13))
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(mesa.mano.scroll.scroll_horizontal, 0)
	mesa.cerrar_modal()

func test_atajos_no_modifican_partida_detras_de_ayuda() -> void:
	var mesa = Mesa.instantiate()
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	mesa.controlador.cargar_demostracion()
	mesa.controlador.procesar_comando(IniciarMano.new())
	mesa.mostrar_ayuda()
	var antes: Dictionary = mesa.controlador.obtener_vista().duplicate(true)
	for codigo in [KEY_P, KEY_S, KEY_L, KEY_R]:
		var evento := InputEventKey.new()
		evento.keycode = codigo
		evento.pressed = true
		mesa._unhandled_key_input(evento)
		assert_eq(mesa.controlador.obtener_vista(), antes)
		assert_true(mesa.modal.contenido.has_node("Reglamento"))
	mesa.cerrar_modal()

func test_enter_y_espacio_activan_botones_nativos_sin_duplicar_coste() -> void:
	var mesa = Mesa.instantiate()
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	mesa.controlador.cargar_demostracion()
	mesa.boton_iniciar_pedir.grab_focus()
	for pulsada in [true, false]:
		var evento := InputEventKey.new()
		evento.keycode = KEY_ENTER
		evento.pressed = pulsada
		Input.parse_input_event(evento)
		await get_tree().process_frame
	assert_eq(mesa.controlador.partida.campanadas, 9)
	assert_eq(mesa.controlador.partida.mano.size(), 2)
	mesa.boton_plantarse.grab_focus()
	for pulsada in [true, false]:
		var evento := InputEventKey.new()
		evento.keycode = KEY_SPACE
		evento.pressed = pulsada
		Input.parse_input_event(evento)
		await get_tree().process_frame
	assert_eq(mesa.controlador.partida.campanadas, 9)
	assert_eq(mesa.controlador.partida.mano.size(), 0)
	assert_false(mesa.vista.ultima_mano.is_empty())
	await get_tree().process_frame
