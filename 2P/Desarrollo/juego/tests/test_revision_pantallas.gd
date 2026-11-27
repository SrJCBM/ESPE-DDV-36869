extends GutTest
## Revisión de pantallas (26 nov 2026): recompensa con efecto en la baraja y sin «Leer al
## crupier», inventario ilustrado con usos, sin el título del juego en las esquinas, patrones
## siempre visibles y la regla de las Llaves (R07) explicada en la mesa del Custodio.

const Lectura := preload("res://mesa/lectura_mesa.gd")

func after_each() -> void:
	await get_tree().process_frame

func _casino():
	var juego = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	juego._entregar()
	juego._cerrar()
	return juego

func _sentar(juego, jefe := "custodio") -> void:
	juego.campana.superadas = CampanaCasino.MESAS.find(jefe)
	juego.entrar(jefe)
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	juego.mesa.establecer_movimiento_reducido(true)

func _vencer(juego) -> void:
	_sentar(juego)
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.meta = 1
	m.partida.mazo.clear()
	for d in [["llaves", 2], ["velas", 3]]:
		m.partida.mazo.append(FabricaCartas.crear_carta(d[0], d[1]))
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	juego.mesa.boton_plantarse.pressed.emit()
	juego.mesa.boton_iniciar_pedir.pressed.emit()

func test_la_recompensa_dice_como_cambia_la_baraja() -> void:
	var juego = _casino()
	_vencer(juego)
	var pantalla = juego.recompensa
	pantalla.revelar_ya()
	var opcion: Dictionary = juego.campana.opciones_recompensa()[0]
	var antes: int = juego.campana.baraja.filter(func(c: CartaEnPartida) -> bool: return c.definicion.palo == opcion.palo).size()
	assert_eq(pantalla.get_viewport().gui_get_focus_owner(), pantalla.cartas[0], "La primera carta llega enfocada")
	pantalla._mostrar(-1)
	assert_eq(pantalla._cifra_total.text, "24 cartas", "Sin carta señalada, el reparto actual")
	assert_true(pantalla.boton_confirmar.disabled, "No se añade nada sin elegir")
	pantalla.cartas[0].focus_entered.emit()
	assert_string_contains(pantalla._cifra_total.text, "24 → 25")
	assert_eq(pantalla._cifras[opcion.palo].text, "%s→%s" % [antes, antes + 1], "La barra del palo ofrecido crece")
	assert_string_contains(pantalla.titulo_detalle.text, Palos.NOMBRES[opcion.palo])
	assert_false(pantalla.texto_detalle.text.is_empty(), "y se explica su efecto")

func test_esc_sigue_sin_carta_y_no_hay_leer_al_crupier() -> void:
	var juego = _casino()
	_vencer(juego)
	var antes: int = juego.campana.baraja.size()
	assert_false(juego.libro.visible, "La recompensa ya no usa el libro con «Leer al crupier»")
	var evento := InputEventKey.new()
	evento.keycode = KEY_ESCAPE
	evento.pressed = true
	juego.recompensa._unhandled_input(evento)
	assert_false(juego.campana.hay_recompensa())
	assert_eq(juego.campana.baraja.size(), antes)
	assert_false(juego.recompensa.visible)

func test_las_preguntas_al_crupier_quedan_para_la_revisita() -> void:
	var juego = _casino()
	_vencer(juego)
	juego.recompensa.boton_omitir.pressed.emit()
	juego.entrar("custodio")
	juego._presentar_jefe()
	assert_true(juego.dialogo.visible)
	for i in range(6):
		if juego.dialogo.botones.any(func(b: Button) -> bool: return b.visible): break
		juego.dialogo.avanzar()
	assert_eq(juego.dialogo.actual, "preguntas_revisita")
	assert_true(juego.dialogo.botones.any(func(b: Button) -> bool: return b.visible and b.text == "Nada más"), "Al volver a hablarle, sus preguntas y salir")

func test_el_inventario_de_la_mesa_muestra_objetos_con_usos() -> void:
	var juego = _casino()
	juego.campana.amuletos.assign(["corona", "moneda"])
	juego.campana.lentes = 1
	_sentar(juego, "recaudador")
	juego.mesa.controlador._objetos.usos["moneda"] = 1
	juego.mesa._ver_objetos()
	var tarjetas: Array = juego.mesa.modal.contenido.find_children("Objeto_*", "", true, false)
	var por_id := {}
	for t in tarjetas: por_id[t.id] = t
	assert_eq(por_id.keys().size(), 3, "Corona, Moneda y Lente")
	assert_not_null(por_id.corona.arte.texture, "Cada objeto con su ilustración")
	assert_eq(por_id.corona.marcas.size(), 0, "La Corona es pasiva")
	assert_eq(por_id.moneda.marcas.size(), 3)
	assert_eq(por_id.moneda.usos_encendidos(), 2, "Le quedan dos de tres en esta mesa")
	assert_eq(por_id.lente.usos_encendidos(), 1)
	for t in tarjetas:
		assert_true(Rect2(Vector2.ZERO, juego.mesa.modal.panel.size).encloses(Rect2(t.get_global_rect().position - juego.mesa.modal.panel.get_global_rect().position, t.size)), "%s cabe en el marco" % t.name)

func test_solo_aparecen_los_objetos_que_se_llevan() -> void:
	var juego = _casino()
	juego.campana.amuletos.assign(["moneda"])
	juego.campana.lentes = 0
	_sentar(juego, "recaudador")
	juego.mesa._ver_objetos()
	var ids: Array = juego.mesa.modal.contenido.find_children("Objeto_*", "", true, false).map(func(t): return t.id)
	assert_eq(ids, ["moneda"], "Con la Moneda elegida, ninguna Lente «Agotada» que no se compró")
	juego.mesa.cerrar_modal()

func test_las_pertenencias_usan_las_mismas_tarjetas() -> void:
	var juego = _casino()
	juego.campana.amuletos.assign(["prudente"])
	juego.inventario()
	var tarjetas: Array = juego.libro.lista.find_children("Objeto_*", "", true, false)
	assert_eq(tarjetas.size(), 1)
	assert_eq(tarjetas[0].cifra_usos.text, "1 / 1", "Fuera de la mesa, lo que da por mesa")

func test_el_titulo_del_juego_ya_no_ocupa_las_esquinas() -> void:
	var juego = _casino()
	var con_titulo: Array = juego.find_children("*", "Label", true, false).filter(func(l: Label) -> bool: return l.text.contains("LA ÚLTIMA MESA"))
	assert_eq(con_titulo.size(), 0, "Ni en el casino ni en el libro")
	_sentar(juego)
	con_titulo = juego.mesa.find_children("*", "Label", true, false).filter(func(l: Label) -> bool: return l.text.contains("LA ÚLTIMA MESA"))
	assert_eq(con_titulo.size(), 0, "Ni en la mesa")

func test_la_pista_explica_la_regla_de_las_llaves_en_el_custodio() -> void:
	var base := {"fase": "decision", "mesa": "custodio", "umbral": 17, "campanadas": 9, "numero_mano": 1,
		"intervalo": {"minimo": 6, "maximo": 6}, "acciones": {"pedir": true}}
	var dos := base.duplicate(true)
	dos.cartas = [{}, {}]
	dos.llaves_disponibles = ["a", "b"]
	assert_string_contains(Lectura.pista(dos), "una de tus dos Llaves iniciales")
	var pedida := base.duplicate(true)
	pedida.cartas = [{}, {}, {}]
	pedida.llaves_disponibles = ["c"]
	assert_string_contains(Lectura.pista(pedida), "solo esa puede cambiarse")
	var otra_mesa := dos.duplicate(true)
	otra_mesa.mesa = "recaudador"
	otra_mesa.comision = false
	assert_false(Lectura.pista(otra_mesa).contains("dos Llaves"), "Fuera del Custodio, la pista breve de siempre")
