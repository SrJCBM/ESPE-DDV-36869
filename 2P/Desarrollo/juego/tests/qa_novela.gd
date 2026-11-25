extends SceneTree
## Capturas de I5-10: prólogo (NVL, ilustración pendiente, ADV y tarjeta), llegada a la
## anfitriona y presentación de crupieres con sus cifras. Excluido de la exportación.
## godot --path . --script res://tests/qa_novela.gd

const DESTINO := "res://exportaciones/qa/novela_%s.png"

func _init() -> void:
	call_deferred("_recorrer")

func _captura(nombre: String) -> void:
	for i in range(4): await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://exportaciones/qa"))
	root.get_texture().get_image().save_png(DESTINO % nombre)
	print("captura ", nombre)

## Avanza hasta la intervención `id` eligiendo la primera respuesta.
func _hasta(dialogo, id: String) -> void:
	for i in range(120):
		if dialogo.actual == id or not dialogo.visible: break
		dialogo.completar()
		if dialogo.botones.is_empty(): dialogo.avanzar()
		else: dialogo.elegir(0)
	dialogo.completar()

func _recorrer() -> void:
	root.size = Vector2i(1280, 720)
	var juego: Control = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(juego)
	await process_frame
	juego.iniciar_prologo()
	var h = juego.historia
	h.reducido = true
	_hasta(h, "p0_3")
	await _captura("p0_nvl")
	_hasta(h, "p0a_1")
	await _captura("p0_adv")
	_hasta(h, "p1")
	await _captura("p1_tarjeta")
	_hasta(h, "p3_motivo")
	await _captura("p3_eleccion")
	_hasta(h, "p4_farolero")
	await _captura("p4_farolero")
	h.saltar()
	juego.campana.historia["vio_vestibulo"] = "si"
	juego.entrar("vestibulo")
	juego._recepcion()
	_hasta(juego.dialogo, "llegada")
	await _captura("anfitriona_llegada")
	juego.dialogo.cerrar()
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._presentar_jefe()
	_hasta(juego.dialogo, "asiento")
	await _captura("custodio_asiento")
	juego.dialogo.cerrar()
	juego.campana.superadas = 1
	juego.entrar("recaudador")
	juego._presentar_jefe()
	_hasta(juego.dialogo, "asiento")
	juego.dialogo.elegir(1)
	juego.dialogo.completar()
	juego.dialogo.elegir(0)
	juego.dialogo.completar()
	juego.dialogo.avanzar()
	juego.dialogo.completar()
	await _captura("recaudador_libro")
	juego.dialogo.abrir_historial()
	await _captura("historial")
	juego.dialogo.cerrar()
	juego.abrir_inicio()
	juego.menu.abrir("creditos")
	await _captura("creditos")
	juego.menu.abrir("opciones")
	await _captura("opciones")
	quit()
