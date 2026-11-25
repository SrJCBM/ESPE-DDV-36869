extends SceneTree
## Cierra la ventana con la mesa abierta a mitad de una mano (variante de qa_cierre.gd).

func _init() -> void:
	call_deferred("_recorrer")

func _recorrer() -> void:
	PartidaGuardada.ruta = "user://partida_qa_cierre.json"
	PartidaGuardada.borrar()
	var juego: Control = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(juego)
	current_scene = juego
	for i in range(3): await process_frame
	juego.menu.botones[0].pressed.emit()
	juego._solicitud("objeto_inicial:lente")
	juego._cerrar()
	juego.entrar("custodio", "pasillo_custodio")
	juego._presentar_jefe()
	juego.libro.primero.pressed.emit()
	await process_frame
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	for i in range(20): await process_frame
	var modo := OS.get_cmdline_user_args()
	if "--recompensa" in modo:
		juego.mesa.controlador.partida.meta = 1
		juego.mesa.boton_plantarse.pressed.emit()
		for i in range(30): await process_frame
		juego.mesa.boton_iniciar_pedir.pressed.emit()
		for i in range(5): await process_frame
		print("recompensa abierta: ", juego.campana.hay_recompensa())
	print("cerrando")
	root.propagate_notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	PartidaGuardada.borrar()
	PartidaGuardada.ruta = "user://partida.json"
	quit()
