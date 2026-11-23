extends SceneTree
## Capturas reproducibles para revisar presentación; excluido de la exportación.
## --script res://tests/qa_visual.gd -- --vista=victoria --tamano=1280x720

func _init() -> void:
	call_deferred("_revisar")

func _revisar() -> void:
	var opciones: Dictionary = {}
	for argumento in OS.get_cmdline_user_args():
		var partes := argumento.trim_prefix("--").split("=", true, 1)
		if partes.size() == 2: opciones[partes[0]] = partes[1]
	var medidas := str(opciones.get("tamano", "1280x720")).split("x")
	root.size = Vector2i(int(medidas[0]), int(medidas[1]))
	var principal: Control = load("res://principal/principal.tscn").instantiate()
	root.add_child(principal)
	await process_frame
	var mesa: Control = principal.get_node("Mesa")
	var controlador: ControladorMesa = mesa.controlador
	var caso: String = opciones.get("vista", "inicio")
	if caso != "inicio":
		controlador.cargar_demostracion()
		if caso == "ultima-mano": controlador.partida.campanadas = 1
		if caso in ["dos-llaves", "resaltado-racha"]:
			var orden: Array[CartaEnPartida] = []
			var ids: Array = ["llaves_01", "velas_02", "velas_04", "velas_06"] if caso == "resaltado-racha" else ["llaves_04", "llaves_05"]
			for id in ids:
				for carta: CartaEnPartida in controlador.partida.mazo:
					if carta.definicion.id == id: orden.append(carta)
			for carta: CartaEnPartida in controlador.partida.mazo:
				if not orden.has(carta): orden.append(carta)
			controlador.partida.mazo = orden
		controlador.procesar_comando(IniciarMano.new())
		if caso not in ["llave", "llave-confirmada", "dos-llaves", "mano-visible", "confirmacion"] and not caso.begins_with("ayuda"):
			controlador.procesar_comando(PedirCarta.new())
		if caso == "cinco":
			controlador.procesar_comando(PedirCarta.new())
			controlador.procesar_comando(PedirCarta.new())
		if caso == "resaltado-racha": controlador.procesar_comando(PedirCarta.new())
		if caso in ["resolucion", "victoria", "derrota", "revelacion"]:
			if caso == "derrota": controlador.partida.campanadas = 0
			controlador.procesar_comando(Plantarse.new())
		if caso == "victoria":
			controlador.procesar_comando(IniciarMano.new())
			controlador.procesar_comando(PedirCarta.new())
			controlador.procesar_comando(Plantarse.new())
			controlador.procesar_comando(IniciarMano.new())
			controlador.procesar_comando(PedirCarta.new())
			controlador.procesar_comando(PedirCarta.new())
			controlador.procesar_comando(Plantarse.new())
		if caso == "quiebra-resuelta":
			controlador.procesar_comando(Plantarse.new())
			controlador.procesar_comando(IniciarMano.new())
			controlador.procesar_comando(PedirCarta.new())
			controlador.procesar_comando(Plantarse.new())
		if caso == "llave": mesa.mostrar_devolucion()
		if caso == "dos-llaves":
			mesa.mostrar_devolucion()
			mesa.mostrar_devolucion()
		if caso == "llave-confirmada":
			mesa.mostrar_devolucion()
			mesa.eleccion_llave.confirmar()
		if caso == "confirmacion": mesa._solicitar_demostracion()
		if caso == "patron-racha": mesa._mostrar_patron(4)
		if caso == "patron-larga": mesa._mostrar_patron(3)
		if caso.begins_with("ayuda"):
			mesa.mostrar_ayuda()
			var pagina: int = {"ayuda": 0, "ayuda-palos": 1, "ayuda-puntos": 2, "ayuda-controles": 3}.get(caso, 0)
			mesa.modal.contenido.get_node("Reglamento").ir_a_pagina(pagina)
		if caso == "desglose":
			controlador.procesar_comando(Plantarse.new())
			mesa.mostrar_desglose()
		if caso == "carta-oculta":
			mesa.mostrar_carta(mesa.mano.fila.get_child(2)._vista)
	for i in range(4): await process_frame
	if caso != "revelacion":
		await create_timer(0.4).timeout
		while mesa.revelacion.activa: await process_frame
		while mesa._feedback != null and mesa._feedback.is_running(): await process_frame
	if caso in ["resaltado-racha", "resaltado-ascenso"]:
		mesa.franja_patrones.get_child(4 if caso == "resaltado-racha" else 2).grab_focus()
		await process_frame
	await RenderingServer.frame_post_draw
	var destino := "res://exportaciones/qa/%s_%s.png" % [caso, opciones.get("tamano", "1280x720")]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://exportaciones/qa"))
	var error := root.get_texture().get_image().save_png(destino)
	print(JSON.stringify({"caso": caso, "tamano": root.size, "captura": destino,
		"puntos": controlador.partida.puntos, "campanadas": controlador.partida.campanadas,
		"revelando": mesa.revelacion.activa, "salida": error}))
	var recortes: Array = []
	for etiqueta in principal.find_children("*", "Label", true, false):
		if etiqueta.is_visible_in_tree() and etiqueta.get_visible_line_count() < etiqueta.get_line_count():
			var necesario: int = etiqueta.get_line_count() * etiqueta.get_line_height() + maxi(0, etiqueta.get_line_count() - 1) * etiqueta.get_theme_constant("line_spacing")
			recortes.append({"texto": etiqueta.text, "alto": etiqueta.size.y, "necesario": necesario})
	print(JSON.stringify({"recortes_verticales": recortes}))
	# Da al mezclador tiempo de liberar los sonidos tras desmontar la escena.
	principal.queue_free()
	await create_timer(0.15).timeout
	quit(error)
