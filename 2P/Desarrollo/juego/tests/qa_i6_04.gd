extends SceneTree
## I6-04: captura la mesa en espera, durante la mano, con una mano larga, resuelta y en el
## Recaudador. Excluido de la exportación.
## godot --path . --script res://tests/qa_i6_04.gd -- --tam=1280x720 --carpeta=despues
var tam := Vector2i(1280, 720)
var carpeta := "despues"

func _init() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--tam="):
			var p := a.get_slice("=", 1).split("x")
			tam = Vector2i(int(p[0]), int(p[1]))
		elif a.begins_with("--carpeta="):
			carpeta = a.get_slice("=", 1)
	call_deferred("_r")

func _mesa(jefe: String) -> Control:
	var j: Control = load("res://casino/casino.tscn").instantiate()
	j.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(j)
	await process_frame
	j._entregar()
	j._cerrar()
	j.campana.superadas = CampanaCasino.MESAS.find(jefe)
	j.entrar(jefe)
	j._presentar_jefe()
	j._solicitud("tomar_asiento")
	j.mesa.establecer_movimiento_reducido(true)
	j.mesa.set("comentarios", false)
	return j

func _mazo(j: Control, cartas: Array) -> void:
	var m: ControladorMesa = j.mesa.controlador
	m.partida.mazo.clear()
	for d in cartas:
		m.partida.mazo.append(FabricaCartas.crear_carta(d[0], d[1]))

func _foto(nombre: String) -> void:
	for i in range(6): await process_frame
	await RenderingServer.frame_post_draw
	var ruta := "res://exportaciones/qa/i6_04/%s" % carpeta
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ruta))
	root.get_texture().get_image().save_png("%s/%s_%dx%d.png" % [ruta, nombre, tam.x, tam.y])

func _r() -> void:
	root.size = tam
	var j: Control = await _mesa("custodio")
	await _foto("1_espera")
	_mazo(j, [["llaves", 4], ["mascaras", 6], ["velas", 2], ["relojes", 3], ["velas", 1], ["llaves", 1], ["velas", 1]])
	j.mesa.boton_iniciar_pedir.pressed.emit()
	await _foto("2_mano")
	j.mesa.abrir_patrones()
	await _foto("2b_consulta_patrones")
	j.mesa.cerrar_patrones()
	for i in range(4): j.mesa.boton_iniciar_pedir.pressed.emit()
	await _foto("3_mano_larga")
	j.mesa.boton_plantarse.pressed.emit()
	await _foto("4_resuelta")
	j.queue_free()
	await process_frame
	var r: Control = await _mesa("recaudador")
	_mazo(r, [["velas", 9], ["relojes", 5], ["llaves", 3]])
	r.mesa.boton_iniciar_pedir.pressed.emit()
	await _foto("5_recaudador")
	r.queue_free()
	await process_frame
	var c: Control = await _mesa("custodio")
	_mazo(c, [["velas", 9], ["relojes", 9]])
	c.mesa.boton_iniciar_pedir.pressed.emit()
	await _foto("6_patron_cercano")
	quit()
