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
	var principal: Control = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(principal)
	await process_frame
	var mesa: Control = principal.get_node("Mesa")
	var controlador: ControladorMesa = mesa.controlador
	var caso: String = opciones.get("vista", "inicio")
	if caso != "inicio":
		controlador.cargar_demostracion()
		controlador.procesar_comando(IniciarMano.new())
		if caso not in ["llave", "confirmacion"] and not caso.begins_with("ayuda"):
			controlador.procesar_comando(PedirCarta.new())
		if caso == "cinco":
			controlador.procesar_comando(PedirCarta.new())
			controlador.procesar_comando(PedirCarta.new())
		if caso in ["resolucion", "victoria", "derrota"]:
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
		if caso == "llave": mesa.mostrar_devolucion()
		if caso == "confirmacion": mesa._solicitar_demostracion()
		if caso.begins_with("ayuda"):
			mesa.mostrar_ayuda()
			var pagina: int = {"ayuda": 0, "ayuda-palos": 1, "ayuda-puntos": 2, "ayuda-controles": 3}.get(caso, 0)
			mesa._contenido_modal.get_node("Reglamento").ir_a_pagina(pagina)
		if caso == "desglose":
			controlador.procesar_comando(Plantarse.new())
			mesa.mostrar_desglose()
		if caso == "carta-oculta":
			mesa.mostrar_carta(mesa.fila_cartas.get_child(2)._vista)
	for i in range(4): await process_frame
	await create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	var destino := "res://exportaciones/qa/%s_%s.png" % [caso, opciones.get("tamano", "1280x720")]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://exportaciones/qa"))
	var error := root.get_texture().get_image().save_png(destino)
	print(JSON.stringify({"caso": caso, "tamano": root.size, "captura": destino,
		"puntos": controlador.partida.puntos, "campanadas": controlador.partida.campanadas,
		"salida": error}))
	var recortes: Array = []
	for etiqueta in principal.find_children("*", "Label", true, false):
		if etiqueta.is_visible_in_tree() and etiqueta.get_line_count() * etiqueta.get_line_height() > etiqueta.size.y + 2:
			recortes.append({"texto": etiqueta.text, "alto": etiqueta.size.y, "necesario": etiqueta.get_line_count() * etiqueta.get_line_height()})
	print(JSON.stringify({"recortes_verticales": recortes}))
	quit(error)
