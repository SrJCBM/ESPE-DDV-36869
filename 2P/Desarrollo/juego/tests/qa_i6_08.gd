extends SceneTree
## I6-08: reproduce las superposiciones de las capturas y guarda el antes o el después.
## godot --path . --script res://tests/qa_i6_08.gd -- --etapa=antes --tam=1280x720
## Casos: victoria del Custodio con recompensa, inventario con un sello, derrota del
## Recaudador, mesa del Recaudador al iniciar y al pedir, y la toma de Ignacio del prólogo.
## Excluido de la exportación.

var etapa := "antes"
var tam := Vector2i(1280, 720)

func _init() -> void:
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("--etapa="): etapa = argumento.get_slice("=", 1)
		if argumento.begins_with("--tam="):
			var partes := argumento.get_slice("=", 1).split("x")
			tam = Vector2i(int(partes[0]), int(partes[1]))
	call_deferred("_recorrer")

func _foto(nombre: String) -> void:
	for i in range(5): await process_frame
	await RenderingServer.frame_post_draw
	var carpeta := "res://exportaciones/qa/i6_08"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
	root.get_texture().get_image().save_png("%s/%s_%s_%dx%d.png" % [carpeta, etapa, nombre, tam.x, tam.y])
	print("captura ", nombre)

func _casino() -> Control:
	var juego: Control = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(juego)
	return juego

func _cartas(juego, datos: Array) -> void:
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.mazo.clear()
	for d in datos:
		m.partida.mazo.append(FabricaCartas.crear_carta(d[0], d[1]))

func _recorrer() -> void:
	root.size = tam
	DisplayServer.window_set_size(tam)
	var juego := _casino()
	await process_frame
	AjustesJuego.ruta = "user://ajustes_qa_i6.cfg"
	juego.historia.reducido = true
	juego.dialogo.reducido = true
	# 1 · Recompensa del Custodio y su diálogo de victoria.
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	juego.mesa.movimiento_reducido = true
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.meta = 1
	_cartas(juego, [["llaves", 2], ["velas", 3]])
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	juego.mesa.boton_plantarse.pressed.emit()
	for i in range(20): await process_frame
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	await _foto("recompensa")
	juego.libro.primero.pressed.emit()
	await _foto("victoria")
	juego._resolver_recompensa(-1)
	# 2 · Inventario con un sello, baraja y vitrina.
	juego.campana.lentes = 1
	juego.campana.amuletos.append("moneda")
	juego.entrar("pasillo_custodio")
	juego.inventario()
	await _foto("inventario")
	juego.ver_baraja()
	juego.vista_baraja.cartas[0].grab_focus()
	await _foto("baraja")
	juego.vista_baraja.cerrar()
	juego._cerrar()
	juego.entrar("tienda")
	juego.tienda()
	await _foto("vitrina")
	juego._cerrar()
	# 3 · Mesa del Recaudador: iniciar y pedir.
	juego.entrar("pasillo_recaudador", "pasillo_custodio")
	juego.entrar("recaudador", "pasillo_recaudador")
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	juego.mesa.movimiento_reducido = true
	await _foto("mesa_iniciar")
	_cartas(juego, [["llaves", 2], ["relojes", 3], ["velas", 2], ["llaves", 4]])
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	for i in range(10): await process_frame
	await _foto("mesa_pedir")
	# 4 · Derrota del Recaudador.
	juego._levantarse(false, 0)
	juego.historia.completar()
	juego.historia.avanzar()
	juego.historia.completar()
	await create_timer(0.8).timeout
	await _foto("derrota")
	juego.historia.cerrar()
	# 5 · La toma de Ignacio en el prólogo.
	juego.iniciar_prologo()
	var h = juego.historia
	h.reducido = true
	for i in range(60):
		if h.actual == "p0a_2": break
		h.completar()
		h.avanzar()
	h.completar()
	await create_timer(0.8).timeout # Termina el fundido de entrada de la cinemática.
	await _foto("ignacio")
	juego.queue_free()
	await process_frame
	quit()
