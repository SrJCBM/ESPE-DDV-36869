extends SceneTree
## Capturas de las pantallas de I4; excluido de la exportación.
## --script res://tests/qa_interfaz_i4.gd -- --vista=vitrina --tamano=1280x720
## Vistas: vitrina, vitrina-detalle, vitrina-baraja, corredor, puerta-cerrada, mesa, mesa-mano.

func _init() -> void:
	call_deferred("_revisar")

func _revisar() -> void:
	var opciones: Dictionary = {}
	for argumento in OS.get_cmdline_user_args():
		var partes := argumento.trim_prefix("--").split("=", true, 1)
		if partes.size() == 2: opciones[partes[0]] = partes[1]
	var medidas := str(opciones.get("tamano", "1280x720")).split("x")
	root.size = Vector2i(int(medidas[0]), int(medidas[1]))
	var vista: String = opciones.get("vista", "vitrina")
	var juego: Control = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(juego)
	await process_frame
	juego._entregar()
	juego._cerrar()
	juego.campana.saldo = int(opciones.get("saldo", "14"))
	juego.campana.superadas = int(opciones.get("sellos", "1"))
	juego._refrescar()
	match vista:
		"vitrina", "vitrina-detalle", "vitrina-baraja":
			juego.entrar("tienda")
			juego.tienda()
			if vista == "vitrina-detalle": juego.vitrina.fichas[1].pressed.emit()
			if vista == "vitrina-baraja":
				juego.vitrina.fichas[5].pressed.emit()
				juego.vitrina.selector.botones[2].grab_focus()
		"corredor", "puerta-cerrada":
			juego.entrar("corredor", "vestibulo")
			if vista == "puerta-cerrada" and opciones.has("x"):
				juego.visitante.position = Vector2(float(opciones.get("x")), float(opciones.get("y", "420")))
		"mesa", "mesa-mano":
			juego.campana.superadas = 0
			juego.entrar("custodio", "corredor")
			juego._jugar()
			await process_frame
			juego.mesa.establecer_movimiento_reducido(true)
			if vista == "mesa-mano":
				var m: ControladorMesa = juego.mesa.controlador
				m.partida._rng.seed = 7
				m.partida._barajar()
				m.procesar_comando(IniciarMano.new())
				m.procesar_comando(PedirCarta.new())
	for i in range(6): await process_frame
	await RenderingServer.frame_post_draw
	var destino := "res://exportaciones/qa/i4_%s_%s.png" % [vista, opciones.get("tamano", "1280x720")]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://exportaciones/qa"))
	var error := root.get_texture().get_image().save_png(destino)
	print(JSON.stringify({"captura": destino, "salida": error}))
	quit(error)
