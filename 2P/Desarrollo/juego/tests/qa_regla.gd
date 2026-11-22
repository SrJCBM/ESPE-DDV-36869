extends SceneTree
## Capturas de la placa de regla del crupier (I3-03); excluido de la exportación.
## --script res://tests/qa_regla.gd -- --mesa=dueno --manos=2 --tamano=1024x576

func _init() -> void:
	call_deferred("_revisar")

func _revisar() -> void:
	var opciones: Dictionary = {}
	for argumento in OS.get_cmdline_user_args():
		var partes := argumento.trim_prefix("--").split("=", true, 1)
		if partes.size() == 2: opciones[partes[0]] = partes[1]
	var medidas := str(opciones.get("tamano", "1280x720")).split("x")
	root.size = Vector2i(int(medidas[0]), int(medidas[1]))
	var mesa_id: String = opciones.get("mesa", "dueno")
	var c := CampanaCasino.new()
	c.recibir_invitacion()
	c.superadas = CampanaCasino.MESAS.find(mesa_id)
	c.iniciar(mesa_id)
	var mesa: Control = load("res://mesa/mesa.tscn").instantiate()
	mesa.campana = c
	mesa.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(mesa)
	await process_frame
	mesa.establecer_movimiento_reducido(true)
	var m: ControladorMesa = mesa.controlador
	m.partida._rng.seed = 7
	m.partida._barajar()
	# Cierra manos sin pedir y abre la siguiente, para ver la regla con la mano en curso.
	for i in range(int(opciones.get("manos", "2"))):
		if i > 0: m.procesar_comando(Plantarse.new())
		m.procesar_comando(IniciarMano.new())
	for i in range(4): await process_frame
	await RenderingServer.frame_post_draw
	var destino := "res://exportaciones/qa/regla_%s_%s.png" % [mesa_id, opciones.get("tamano", "1280x720")]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://exportaciones/qa"))
	var error := root.get_texture().get_image().save_png(destino)
	print(JSON.stringify({"captura": destino, "regla": mesa._regla_texto.text, "nota": mesa._nota_umbral.text, "umbral": mesa._umbral.text}))
	quit(error)
