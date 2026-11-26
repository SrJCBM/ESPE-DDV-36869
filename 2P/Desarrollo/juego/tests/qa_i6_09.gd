extends SceneTree
## I6-09: captura cada figura del recorrido con Klein al lado, para revisar escala, apoyo,
## sombra y huella. Excluido de la exportación.
## godot --path . --script res://tests/qa_i6_09.gd -- --carpeta=despues
var carpeta := "despues"

const ESCENAS := [
	["vestibulo", "", Vector2(400, 330), "vestibulo_piano"],
	["vestibulo", "", Vector2(470, 560), "vestibulo_jugadores"],
	["vestibulo", "", Vector2(900, 300), "vestibulo_anfitriona"],
	["pasillo_custodio", "vestibulo", Vector2(560, 380), "pasillo_tobias"],
	["pasillo_recaudador", "pasillo_custodio", Vector2(800, 380), "pasillo_benavides"],
	["tienda", "pasillo_recaudador", Vector2(560, 330), "tienda_anfitriona"],
	["custodio", "pasillo_custodio", Vector2(560, 330), "sala_custodio"],
	["recaudador", "pasillo_recaudador", Vector2(560, 330), "sala_recaudador"],
]

func _init() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--carpeta="):
			carpeta = a.get_slice("=", 1)
	call_deferred("_r")

func _r() -> void:
	root.size = Vector2i(1280, 720)
	var j: Control = load("res://casino/casino.tscn").instantiate()
	j.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(j)
	await process_frame
	j._entregar()
	j._cerrar()
	j.campana.superadas = 3
	var ruta := "res://exportaciones/qa/i6_09/%s" % carpeta
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ruta))
	for escena in ESCENAS:
		j.entrar(escena[0], escena[1])
		j.visitante.position = escena[2]
		for i in range(5): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("%s/%s.png" % [ruta, escena[3]])
	quit()
