extends GutTest
## Revisión de interfaz y código (27 nov 2026): pila de pantallas, límites de objetos en el
## catálogo, fichas solo por la campaña, ajustes en memoria, acciones con tecla y botón de mando,
## y letra mínima de 16 en el lienzo.

func before_each() -> void:
	AjustesJuego.borrar()

func after_each() -> void:
	AjustesJuego.borrar()
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
	juego.mesa.comentarios = false

func _boton(indice: JoyButton) -> InputEventJoypadButton:
	var evento := InputEventJoypadButton.new()
	evento.button_index = indice
	evento.pressed = true
	return evento

# --- Pila de pantallas ---

func test_la_pila_dice_la_pantalla_mas_alta_y_avisa_al_cambiar() -> void:
	var pila := PilaPantallas.new()
	var abajo := Control.new()
	var arriba := Control.new()
	add_child_autofree(abajo)
	add_child_autofree(arriba)
	pila.registrar(&"arriba", func() -> bool: return arriba.visible, arriba)
	pila.registrar(&"abajo", func() -> bool: return abajo.visible, abajo)
	watch_signals(pila)
	arriba.hide()
	abajo.hide()
	assert_eq(pila.superior(), &"")
	assert_false(pila.alguna())
	abajo.show()
	assert_eq(pila.superior(), &"abajo")
	arriba.show()
	assert_eq(pila.superior(), &"arriba", "La registrada antes está encima")
	assert_false(pila.alguna([&"arriba", &"abajo"]))
	assert_signal_emit_count(pila, "cambiada", 4, "Cada cambio de visibilidad avisa")

func test_el_casino_sabe_que_pantalla_esta_encima() -> void:
	var juego = _casino()
	assert_eq(juego.pantallas.superior(), &"")
	juego.inventario()
	assert_eq(juego.pantallas.superior(), &"libro")
	juego._cerrar()
	_sentar(juego)
	assert_eq(juego.pantallas.superior(), &"mesa")
	juego.pausar()
	assert_eq(juego.pantallas.superior(), &"menu")

func test_el_casino_no_recalcula_en_cada_fotograma() -> void:
	var juego = _casino()
	assert_false(juego.get_script().get_script_method_list().any(func(m: Dictionary) -> bool: return m.name == "_process"),
		"Objetivo, minimapa y pista se actualizan por eventos")
	juego.entrar("vestibulo")
	juego.visitante.position = Vector2(985, 300)
	juego.visitante.movido.emit()
	assert_eq(juego.pista.text, "E · Hablar", "Moverse actualiza la pista")
	juego.inventario()
	assert_false(juego.minimapa.visible, "Abrir una pantalla oculta el minimapa sin esperar un fotograma")

# --- Datos: límites y fichas ---

func test_los_limites_de_los_objetos_salen_del_catalogo() -> void:
	assert_eq(CampanaCasino.usos_por_mesa("moneda"), CampanaCasino.TIENDA.buscar("moneda").usos_por_mesa)
	assert_eq(CampanaCasino.usos_por_mesa("prudente"), 1)
	assert_eq(CampanaCasino.maximo_llevado("lente"), 2)
	var campana := CampanaCasino.new()
	campana.amuletos.assign(["moneda", "prudente"])
	var datos := _inventario(campana)
	for objeto: Dictionary in datos:
		assert_eq(objeto.maximo, CampanaCasino.usos_por_mesa(objeto.id), objeto.id)

func _inventario(campana: CampanaCasino) -> Array[Dictionary]:
	return preload("res://casino/interfaz/objetos/tarjeta_objeto.gd").inventario(campana)

func test_la_lente_muestra_cuantas_llevas_no_un_maximo() -> void:
	var campana := CampanaCasino.new()
	campana.lentes = 1
	var datos: Array[Dictionary] = _inventario(campana)
	assert_eq(datos.size(), 1)
	var tarjeta = preload("res://casino/interfaz/objetos/tarjeta_objeto.gd").new()
	add_child_autofree(tarjeta)
	tarjeta.configurar(datos[0])
	assert_eq(tarjeta.cifra_usos.text, "1", "Una Lente se lee «1», no «1 / 2»")

func test_las_fichas_no_quedan_en_negativo() -> void:
	var campana := CampanaCasino.new()
	campana.ingresar(3)
	assert_false(campana.gastar(4))
	assert_eq(campana.saldo, 3)
	assert_true(campana.gastar(3))
	assert_eq(campana.saldo, 0)
	campana.ingresar(-5)
	assert_eq(campana.saldo, 0, "Ingresar nunca resta")

func test_la_moneda_se_agota_segun_el_catalogo() -> void:
	var ObjetosMesa := preload("res://dominio/campana/objetos_mesa.gd")
	var objetos = ObjetosMesa.new()
	var campana := CampanaCasino.new()
	campana.amuletos.assign(["moneda"])
	assert_eq(objetos.usos_restantes(campana), {"moneda": 3}, "Solo los objetos que se llevan")
	for i in range(5):
		objetos._gastar_uso(campana, "moneda")
	assert_eq(objetos.usos_restantes(campana).moneda, 0)

# --- Ajustes en memoria ---

func test_los_ajustes_se_leen_una_vez_y_se_guardan_al_cambiar() -> void:
	AjustesJuego.guardar_consejos(false)
	assert_false(AjustesJuego.consejos())
	var archivo := ConfigFile.new()
	assert_eq(archivo.load(AjustesJuego.ruta), OK, "Cada cambio se escribe en el disco")
	assert_false(archivo.get_value("tutorial", "consejos", true))
	AjustesJuego.borrar()
	assert_true(AjustesJuego.consejos(), "Borrar vuelve a lo predeterminado")
	var vistos := AjustesJuego.consejos_vistos()
	vistos.append("umbral")
	assert_eq(AjustesJuego.consejos_vistos(), [], "La lista devuelta es una copia")

# --- Acciones de entrada ---

func test_cada_accion_tiene_tecla_y_las_de_juego_boton_de_mando() -> void:
	for accion: StringName in [Acciones.PEDIR, Acciones.PLANTARSE, Acciones.DEVOLVER_LLAVE, Acciones.PATRONES,
			Acciones.AYUDA, Acciones.INVENTARIO, Acciones.MAPA, Acciones.PAUSA, Acciones.INTERACTUAR,
			Acciones.SONIDO, Acciones.REINICIAR]:
		assert_true(InputMap.has_action(accion), str(accion))
		assert_false(Acciones.tecla(accion).is_empty(), "%s tiene tecla" % accion)
		if accion in [Acciones.SONIDO, Acciones.REINICIAR]:
			continue
		var con_mando := InputMap.action_get_events(accion).any(func(e: InputEvent) -> bool: return e is InputEventJoypadButton)
		assert_true(con_mando, "%s tiene botón de mando" % accion)
	for rumbo in ["norte", "sur", "este", "oeste"]:
		assert_true(InputMap.action_get_events(rumbo).any(func(e: InputEvent) -> bool: return e is InputEventJoypadMotion), rumbo)
	assert_eq(Acciones.tecla(Acciones.PEDIR), "P")
	assert_eq(Acciones.tecla(Acciones.VOLVER), "Esc")

func test_con_mando_se_pide_carta_y_se_pausa() -> void:
	var juego = _casino()
	_sentar(juego)
	var mesa: MesaUI = juego.mesa
	mesa._unhandled_input(_boton(JOY_BUTTON_X))
	assert_eq(mesa.vista.fase, "decision", "X inicia la mano")
	juego._unhandled_input(_boton(JOY_BUTTON_START))
	assert_true(juego.menu.visible, "Start pausa")
	assert_eq(juego.menu.pantalla, "pausa")

func test_los_textos_nombran_la_tecla_del_mapa_de_entrada() -> void:
	assert_string_contains(Consejos.texto("pedir"), "P: otra carta")
	var juego = _casino()
	_sentar(juego)
	assert_string_contains(juego.mesa.boton_ayuda.text, "· " + Acciones.tecla(Acciones.AYUDA))

# --- Letra mínima ---

func test_ningun_rotulo_de_la_mesa_baja_de_la_letra_minima() -> void:
	var juego = _casino()
	_sentar(juego)
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.mazo.clear()
	for d in [["velas", 4], ["mascaras", 6], ["llaves", 2]]:
		m.partida.mazo.append(FabricaCartas.crear_carta(d[0], d[1]))
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	var pequenos := PackedStringArray()
	for nodo in juego.mesa.lienzo.find_children("*", "Control", true, false):
		if not (nodo is Label or nodo is Button) or not nodo.is_visible_in_tree() or nodo.text.strip_edges().is_empty():
			continue
		if _dentro_de_carta(nodo):
			continue
		if nodo.get_theme_font_size("font_size") < Tipografia.MINIMA:
			pequenos.append("%s (%s)" % [nodo.text, nodo.get_theme_font_size("font_size")])
	assert_eq(pequenos, PackedStringArray(), "Rótulos por debajo de %s" % Tipografia.MINIMA)

func _dentro_de_carta(nodo: Node) -> bool:
	var padre := nodo.get_parent()
	while padre != null:
		if padre.get_script() == preload("res://cartas/carta_ui.gd"):
			return true
		padre = padre.get_parent()
	return false
