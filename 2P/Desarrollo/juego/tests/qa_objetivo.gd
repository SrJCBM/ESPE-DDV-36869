extends SceneTree
## Capturas del objetivo de exploración (I2-K2); excluido de la exportación.
## --script res://tests/qa_objetivo.gd -- --sala=vestibulo --progreso=0 --tamano=1024x576
## progreso: -1 sin invitación, 0–4 sellos y mesas superadas.

func _init() -> void:
	call_deferred("_revisar")

func _revisar() -> void:
	var opciones: Dictionary = {}
	for argumento in OS.get_cmdline_user_args():
		var partes := argumento.trim_prefix("--").split("=", true, 1)
		if partes.size() == 2: opciones[partes[0]] = partes[1]
	var tamano := str(opciones.get("tamano", "1024x576"))
	var medidas := tamano.split("x")
	root.size = Vector2i(int(medidas[0]), int(medidas[1]))
	var juego: Control = load("res://casino/casino.tscn").instantiate()
	root.add_child(juego)
	juego.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await process_frame
	var progreso := int(opciones.get("progreso", "-1"))
	if progreso >= 0:
		juego.campana.recibir_invitacion()
		juego.campana.superadas = progreso
	var sala := str(opciones.get("sala", "vestibulo"))
	juego.entrar(sala)
	if sala == "corredor": juego.visitante.position = Vector2(640, 375)
	for i in range(6): await process_frame
	await create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	var destino := "res://exportaciones/qa/objetivo_%s_%s_%s.png" % [sala, progreso, tamano]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://exportaciones/qa"))
	var error := root.get_texture().get_image().save_png(destino)
	var caja: Rect2 = juego.indicador_objetivo.get_global_rect()
	print(JSON.stringify({"sala": sala, "objetivo": juego.indicador_objetivo.texto.text, "visible": juego.indicador_objetivo.is_visible_in_tree(),
		"rect_pantalla": [caja.position.x, caja.position.y, caja.size.x, caja.size.y],
		"alto_texto_px": juego.indicador_objetivo.texto.get_line_height() * juego.indicador_objetivo.get_global_transform().get_scale().y,
		"captura": ProjectSettings.globalize_path(destino), "salida": error}))
	juego.queue_free()
	await create_timer(0.15).timeout
	quit(error)
