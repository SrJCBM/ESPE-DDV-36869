extends SceneTree
## Arranque real con una partida guardada: comprueba que el inicio quepa en su marco.
## godot --path . --script res://tests/qa_menu_inicio.gd   (sin --headless guarda captura)

func _init() -> void:
	call_deferred("_revisar")

func _revisar() -> void:
	PartidaGuardada.ruta = "user://partida_qa_menu.json"
	root.size = Vector2i(1280, 720)
	# Primero una partida guardada; después, el arranque como lo hace el juego.
	var previa := CampanaCasino.new()
	previa.recibir_invitacion()
	PartidaGuardada.guardar({"campana": previa.a_datos()})
	var juego: Control = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(juego)
	current_scene = juego
	for i in range(3): await process_frame
	# Continuar, pausar y volver al inicio, como al salir otra vez al inicio.
	juego.menu.botones[0].pressed.emit()
	for i in range(3): await process_frame
	juego.pausar()
	for i in range(3): await process_frame
	juego.menu.botones[4].pressed.emit()
	for i in range(3): await process_frame
	var menu = juego.menu
	print("partida: ", PartidaGuardada.existe(), " botones: ", menu.botones.map(func(b): return b.text))
	print("panel: ", menu._panel.position, " ", menu._panel.size, " contenido min: ", menu._contenido.get_combined_minimum_size(), " fin contenido: ", menu._contenido.position.y + menu._contenido.size.y)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://exportaciones/qa/menu_inicio.png")
	PartidaGuardada.borrar()
	PartidaGuardada.ruta = "user://partida.json"
	quit()
