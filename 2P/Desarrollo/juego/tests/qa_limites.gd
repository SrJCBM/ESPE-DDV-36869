extends SceneTree
## Captura cada sala con el visitante empujado contra los límites (arriba, izquierda y
## derecha) para revisar que no camine sobre paredes ni muebles. Excluido de la exportación.
## godot --path . --script res://tests/qa_limites.gd -- --sala=vestibulo

func _init() -> void:
	call_deferred("_revisar")

func _empujar(juego, accion: String, cuadros: int) -> void:
	Input.action_press(accion)
	for i in range(cuadros): await physics_frame
	Input.action_release(accion)

func _revisar() -> void:
	var sala := "vestibulo"
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("--sala="): sala = argumento.get_slice("=", 1)
	root.size = Vector2i(1280, 720)
	var juego: Control = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(juego)
	await process_frame
	juego.campana.recibir_invitacion()
	juego.campana.superadas = 4
	juego.entrar(sala)
	await physics_frame
	var marcas := []
	for punto in [Vector2(640, 500), Vector2(300, 500), Vector2(980, 500)]:
		juego.visitante.position = punto
		await physics_frame
		await _empujar(juego, "norte", 120)
		marcas.append(juego.visitante.position)
	for punto in [Vector2(640, 450)]:
		juego.visitante.position = punto
		await _empujar(juego, "oeste", 150)
		marcas.append(juego.visitante.position)
		juego.visitante.position = punto
		await _empujar(juego, "este", 150)
		marcas.append(juego.visitante.position)
		juego.visitante.position = punto
		await _empujar(juego, "sur", 120)
		marcas.append(juego.visitante.position)
	print(sala, " ", marcas)
	if DisplayServer.get_name() == "headless":
		quit()
		return
	# Deja al visitante arriba en el centro para la foto.
	juego.visitante.position = marcas[0]
	for i in range(4): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://exportaciones/qa/limites_%s.png" % sala)
	quit()
