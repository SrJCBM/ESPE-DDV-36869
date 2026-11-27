extends SceneTree
## Revisión de interfaz (27 nov 2026): letra mínima de 16, atajos leídos del mapa de entrada y
## menos texto repetido. Captura las pantallas principales a la resolución de la ventana.
## godot --path . --resolution 1280x720 --position 30000,30000 --script res://tests/qa_revision_interfaz.gd
const DESTINO := "res://exportaciones/qa/revision_interfaz"

func _init() -> void:
	call_deferred("_r")

func _juego() -> Control:
	var j: Control = load("res://casino/casino.tscn").instantiate()
	j.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(j)
	await process_frame
	return j

func _mesa(j: Control, jefe: String) -> void:
	j.campana.superadas = CampanaCasino.MESAS.find(jefe)
	j.entrar(jefe)
	j._presentar_jefe()
	j._solicitud("tomar_asiento")
	j.mesa.establecer_movimiento_reducido(true)
	j.mesa.comentarios = false

func _mazo(j: Control, cartas: Array) -> void:
	var m: ControladorMesa = j.mesa.controlador
	m.partida.mazo.clear()
	for d in cartas:
		m.partida.mazo.append(FabricaCartas.crear_carta(d[0], d[1]))

func _foto(nombre: String) -> void:
	for i in range(6): await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DESTINO))
	var imagen := root.get_texture().get_image()
	imagen.save_png("%s/%s_%dx%d.png" % [DESTINO, nombre, imagen.get_width(), imagen.get_height()])

func _r() -> void:
	AjustesJuego.ruta = "user://ajustes_qa_interfaz.cfg"
	AjustesJuego.borrar()
	var j: Control = await _juego()
	j.entrar("vestibulo")
	j.visitante.position = Vector2(985, 300)
	j.actualizar_exploracion()
	await _foto("1_exploracion_pista")
	j._entregar()
	j._cerrar()
	await _mesa(j, "custodio")
	await _foto("2_mesa_vacia_consejo")
	_mazo(j, [["llaves", 4], ["mascaras", 6], ["velas", 2], ["relojes", 3], ["velas", 1]])
	j.mesa.boton_iniciar_pedir.pressed.emit()
	await _foto("3_mano")
	j.mesa.boton_iniciar_pedir.pressed.emit()
	j.mesa.boton_plantarse.pressed.emit()
	await _foto("4_resuelta")
	j.queue_free()
	await process_frame
	var r: Control = await _juego()
	r._entregar()
	r._cerrar()
	r.campana.amuletos.assign(["corona", "prudente", "moneda"])
	r.campana.lentes = 1
	r.campana.saldo = 42
	await _mesa(r, "recaudador")
	r.mesa.controlador._objetos.usos["moneda"] = 1
	await _foto("5_mesa_recaudador")
	r.mesa._ver_objetos()
	await _foto("6_inventario_mesa")
	r.mesa.cerrar_modal()
	r.mesa.queue_free()
	r.mesa = null
	r.pagina.show()
	r._cerrar()
	r.entrar("pasillo_recaudador")
	r.inventario()
	await _foto("7_inventario_casino")
	r._cerrar()
	r.entrar("tienda")
	r.tienda()
	await _foto("8_vitrina")
	r._cerrar()
	r.entrar("recaudador")
	r.campana.activa = "recaudador"
	r._levantarse(true, 1)
	await _foto("9_recompensa")
	AjustesJuego.borrar()
	quit()
