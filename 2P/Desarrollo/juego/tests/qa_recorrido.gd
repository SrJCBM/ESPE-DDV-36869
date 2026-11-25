extends SceneTree
## Capturas del recorrido vestíbulo → pasillo del Custodio (I5-10). Excluido de la exportación.
func _init() -> void:
	call_deferred("_r")

func _foto(n: String) -> void:
	for i in range(4): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://exportaciones/qa/recorrido_%s.png" % n)

func _r() -> void:
	root.size = Vector2i(1280, 720)
	var j: Control = load("res://casino/casino.tscn").instantiate()
	j.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(j)
	await process_frame
	j.entrar("vestibulo", "entrada")
	await _foto("vestibulo_sin_invitacion")
	j._entregar()
	j._cerrar()
	j.entrar("vestibulo", "entrada")
	j.visitante.position = Vector2(1100, 356)
	await _foto("vestibulo")
	j.entrar("pasillo_custodio", "vestibulo")
	await _foto("pasillo")
	j.entrar("vestibulo", "pasillo_custodio")
	j.historia.reducido = true
	j.examinar()
	j.historia.completar()
	await _foto("examinar_reloj")
	j.historia.avanzar()
	j.entrar("custodio")
	j._presentar_jefe()
	for i in range(8):
		if not j.dialogo.botones.is_empty(): break
		j.dialogo.completar()
		j.dialogo.avanzar()
	j.dialogo.elegir(1)
	j.dialogo.completar()
	j.dialogo.elegir(3)
	j.dialogo.completar()
	await _foto("custodio_cadena")
	quit()
