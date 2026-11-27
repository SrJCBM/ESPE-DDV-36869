extends SceneTree
## Revisión de pantallas (26 nov 2026): mesa con patrones siempre visibles, mano resuelta,
## inventario de la mesa con usos y pertenencias del casino. Excluido de la exportación.
## godot --path . --script res://tests/qa_revision_pantallas.gd -- --tam=1280x720
var tam := Vector2i(1280, 720)

func _init() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--tam="):
			var p := a.get_slice("=", 1).split("x")
			tam = Vector2i(int(p[0]), int(p[1]))
	call_deferred("_r")

func _juego() -> Control:
	var j: Control = load("res://casino/casino.tscn").instantiate()
	j.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(j)
	await process_frame
	j._entregar()
	j._cerrar()
	return j

func _mesa(j: Control, jefe: String) -> void:
	j.campana.superadas = CampanaCasino.MESAS.find(jefe)
	j.entrar(jefe)
	j._presentar_jefe()
	j._solicitud("tomar_asiento")
	j.mesa.establecer_movimiento_reducido(true)
	j.mesa.set("comentarios", false)

func _mazo(j: Control, cartas: Array) -> void:
	var m: ControladorMesa = j.mesa.controlador
	m.partida.mazo.clear()
	for d in cartas:
		m.partida.mazo.append(FabricaCartas.crear_carta(d[0], d[1]))

func _foto(nombre: String) -> void:
	for i in range(6): await process_frame
	await RenderingServer.frame_post_draw
	var ruta := "res://exportaciones/qa/revision"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ruta))
	root.get_texture().get_image().save_png("%s/%s_%dx%d.png" % [ruta, nombre, tam.x, tam.y])

func _r() -> void:
	root.size = tam
	var j: Control = await _juego()
	await _mesa(j, "custodio")
	_mazo(j, [["llaves", 4], ["mascaras", 6], ["velas", 2], ["relojes", 3], ["velas", 1]])
	j.mesa.boton_iniciar_pedir.pressed.emit()
	await _foto("1_mano")
	j.mesa.abrir_patrones()
	await _foto("2_foco_patrones")
	j.mesa.cerrar_patrones()
	j.mesa.boton_iniciar_pedir.pressed.emit()
	j.mesa.boton_plantarse.pressed.emit()
	await _foto("3_resuelta")
	j.queue_free()
	await process_frame
	var r: Control = await _juego()
	r.campana.amuletos.assign(["corona", "prudente", "moneda"])
	r.campana.lentes = 1
	r.campana.saldo = 42
	await _mesa(r, "recaudador")
	r.mesa.controlador._objetos._usos_moneda = 1
	r.mesa._ver_objetos()
	await _foto("4_inventario_mesa")
	r.mesa.cerrar_modal()
	r.mesa.queue_free()
	r.mesa = null
	r.pagina.show()
	r._cerrar()
	r.entrar("pasillo_recaudador")
	r.inventario()
	await _foto("5_inventario_casino")
	quit()
