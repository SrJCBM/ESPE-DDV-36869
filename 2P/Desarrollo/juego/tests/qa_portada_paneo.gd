extends SceneTree
## Paneo de las portadas del inicio: capturas a 0 s, 7 s y durante el fundido. Excluido de la exportación.
## godot --path . --script res://tests/qa_portada_paneo.gd
func _init() -> void:
	call_deferred("_r")

func _foto(nombre: String) -> void:
	await RenderingServer.frame_post_draw
	var ruta := "res://exportaciones/qa/portada"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ruta))
	root.get_texture().get_image().save_png("%s/%s.png" % [ruta, nombre])

func _r() -> void:
	root.size = Vector2i(1280, 720)
	AjustesJuego.ruta = "user://ajustes_qa_portada.cfg"
	var j: Control = load("res://casino/casino.tscn").instantiate()
	j.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(j)
	for i in range(3): await process_frame
	j.abrir_inicio()
	await _foto("1_inicio")
	await create_timer(7.0).timeout
	await _foto("2_siete_segundos")
	await create_timer(7.6).timeout
	await _foto("3_fundido")
	await create_timer(2.0).timeout
	await _foto("4_siguiente")
	quit()
