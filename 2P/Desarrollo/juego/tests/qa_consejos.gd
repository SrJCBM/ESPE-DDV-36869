extends SceneTree
## Capturas de los consejos del tutorial en contexto. Excluido de la exportación.
## godot --path . --script res://tests/qa_consejos.gd -- --tam=1280x720
var tam := Vector2i(1280, 720)

func _init() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--tam="):
			var p := a.get_slice("=", 1).split("x")
			tam = Vector2i(int(p[0]), int(p[1]))
	call_deferred("_r")

func _foto(nombre: String) -> void:
	for i in range(30): await process_frame
	await RenderingServer.frame_post_draw
	var ruta := "res://exportaciones/qa/consejos"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ruta))
	root.get_texture().get_image().save_png("%s/%s_%dx%d.png" % [ruta, nombre, tam.x, tam.y])

func _mazo(j: Control, cartas: Array) -> void:
	var m: ControladorMesa = j.mesa.controlador
	m.partida.mazo.clear()
	for d in cartas:
		m.partida.mazo.append(FabricaCartas.crear_carta(d[0], d[1]))

func _r() -> void:
	root.size = tam
	AjustesJuego.ruta = "user://ajustes_qa_consejos.cfg"
	PartidaGuardada.ruta = "user://partida_qa_consejos.json"
	AjustesJuego.reiniciar_consejos()
	AjustesJuego.guardar_movimiento_reducido(true)
	var j: Control = load("res://casino/casino.tscn").instantiate()
	j.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(j)
	await process_frame
	j.guardado_activo = false
	j._entregar()
	j._cerrar()
	j.entrar("custodio")
	j._presentar_jefe()
	j._solicitud("tomar_asiento")
	j.mesa.set("comentarios", false)
	await _foto("1_umbral")
	_mazo(j, [["mascaras", 6], ["llaves", 4], ["velas", 9], ["velas", 1], ["relojes", 3]])
	j.mesa.boton_iniciar_pedir.pressed.emit()
	await _foto("2_pedir")
	j.mesa.boton_iniciar_pedir.pressed.emit()
	await _foto("3_llave")
	j.mesa.boton_iniciar_pedir.pressed.emit()
	await _foto("4_mascara")
	j.mesa.boton_plantarse.pressed.emit()
	await _foto("5_quiebra")
	j.mesa.controlador.partida.meta = 1
	_mazo(j, [["velas", 9], ["relojes", 8]])
	j.mesa.boton_iniciar_pedir.pressed.emit()
	j.mesa.boton_plantarse.pressed.emit()
	await _foto("6_patron")
	j.mesa.boton_iniciar_pedir.pressed.emit()
	await _foto("7_recompensa")
	j.recompensa.boton_omitir.pressed.emit()
	j.entrar("tienda")
	j.tienda()
	await _foto("8_tienda")
	AjustesJuego.borrar()
	quit()
