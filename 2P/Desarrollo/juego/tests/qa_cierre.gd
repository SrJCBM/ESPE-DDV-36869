extends SceneTree
## Recorrido real con el casino como escena principal: entra, juega contra el Custodio, elige
## la recompensa y cierra la ventana como lo haría el jugador. Sirve para ver los errores de
## depuración al cerrar y para capturar la franja de patrones. Excluido de la exportación.
## godot --path . --verbose --script res://tests/qa_cierre.gd

const DESTINO := "res://exportaciones/qa/cierre_%s.png"

func _init() -> void:
	call_deferred("_recorrer")

func _captura(nombre: String) -> void:
	for i in range(4): await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://exportaciones/qa"))
	root.get_texture().get_image().save_png(DESTINO % nombre)
	print("captura ", nombre)

func _recorrer() -> void:
	PartidaGuardada.ruta = "user://partida_qa_cierre.json"
	PartidaGuardada.borrar()
	root.size = Vector2i(1280, 720)
	var juego: Control = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(juego)
	current_scene = juego
	for i in range(3): await process_frame
	print("guardado activo: ", juego.guardado_activo, " · inicio visible: ", juego.menu.visible)
	juego.menu.botones[0].pressed.emit()
	juego.entrar("vestibulo", "entrada")
	juego._solicitud("objeto_inicial:lente")
	juego._cerrar()
	juego.entrar("pasillo_custodio", "vestibulo")
	juego.entrar("custodio", "pasillo_custodio")
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	await process_frame
	var m: ControladorMesa = juego.mesa.controlador
	# Mano preparada: dos Velas y después otra Vela pedida (Racha en curso y luego activa).
	m.partida.mazo.clear()
	for datos in [["velas", 2], ["velas", 4], ["velas", 6], ["llaves", 3], ["relojes", 5]]:
		m.partida.mazo.append(FabricaCartas.crear_carta(datos[0], datos[1]))
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	await _captura("racha_2")
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	await _captura("racha_3")
	juego.mesa.franja_patrones.get_child(4).grab_focus()
	await _captura("racha_foco")
	m.partida.meta = 1
	juego.mesa.boton_plantarse.pressed.emit()
	for i in range(30): await process_frame
	await _captura("resuelta")
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	await process_frame
	await _captura("recompensa")
	var fila = juego.libro.lista.get_children().filter(func(n): return n.has_signal("elegida"))[0]
	fila.get_child(0).pressed.emit()
	await process_frame
	await _captura("tras_custodio")
	print("partida guardada: ", PartidaGuardada.existe(), " · sellos: ", juego.campana.superadas)
	# Cierre como el botón de la ventana.
	root.propagate_notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	PartidaGuardada.borrar()
	PartidaGuardada.ruta = "user://partida.json"
	quit()
