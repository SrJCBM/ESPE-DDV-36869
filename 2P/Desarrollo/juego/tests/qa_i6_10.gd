extends SceneTree
## I6-10: captura la reacción del Custodio tras un Punto exacto. Excluido de la exportación.
## godot --path . --script res://tests/qa_i6_10.gd -- --tam=1280x720
var tam := Vector2i(1280, 720)

func _init() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--tam="):
			var p := a.get_slice("=", 1).split("x")
			tam = Vector2i(int(p[0]), int(p[1]))
	call_deferred("_r")

func _r() -> void:
	root.size = tam
	var j: Control = load("res://casino/casino.tscn").instantiate()
	j.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(j)
	await process_frame
	j._entregar()
	j._cerrar()
	j.entrar("custodio")
	j._presentar_jefe()
	j._solicitud("tomar_asiento")
	j.mesa.movimiento_reducido = true
	var m: ControladorMesa = j.mesa.controlador
	m.partida.mazo.clear()
	for d in [["llaves", 10], ["velas", 7]]:
		m.partida.mazo.append(FabricaCartas.crear_carta(d[0], d[1]))
	j.mesa.boton_iniciar_pedir.pressed.emit()
	j.mesa.boton_plantarse.pressed.emit()
	for i in range(6): await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://exportaciones/qa/i6_10"))
	root.get_texture().get_image().save_png("res://exportaciones/qa/i6_10/reaccion_%dx%d.png" % [tam.x, tam.y])
	quit()
