extends GutTest
## I2-K1 e I2-K2: ayuda con las reglas de la mesa activa y objetivo de exploración.

const Mesa = preload("res://mesa/mesa.tscn")

func _campana(nivel: int) -> CampanaCasino:
	var c := CampanaCasino.new()
	c.recibir_invitacion()
	c.superadas = nivel
	assert_true(c.iniciar(CampanaCasino.MESAS[nivel]))
	return c

func _mesa_campana(nivel: int):
	var mesa = Mesa.instantiate()
	mesa.campana = _campana(nivel)
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	return mesa

func _libro(mesa):
	mesa.mostrar_ayuda()
	return mesa.modal.contenido.get_node("Reglamento")

func _casino():
	var juego = load("res://casino/casino.tscn").instantiate()
	add_child_autofree(juego)
	return juego

# --- I2-K1 · Ayuda de la mesa activa ---

func test_reglas_de_cada_mesa_coinciden_con_la_campana() -> void:
	for nivel in range(4):
		var m := ControladorMesa.new()
		autofree(m)
		m.configurar_campana(_campana(nivel))
		var reglas := m.reglas_ayuda()
		var esperado: ReglaMesa = CampanaCasino.MESAS_CAMPANA.de(CampanaCasino.MESAS[nivel])
		assert_eq(reglas.mesa, CampanaCasino.MESAS[nivel])
		assert_eq(reglas.umbral, esperado.umbral)
		assert_eq(reglas.meta, esperado.meta)
		assert_eq(reglas.presupuesto, esperado.campanadas)
		assert_eq(reglas.ficha_por_pedir, 1 if nivel == 1 else 0)

func test_acceso_i1_conserva_las_reglas_del_custodio() -> void:
	var m := ControladorMesa.new()
	autofree(m)
	var reglas := m.reglas_ayuda()
	assert_eq([reglas.mesa, reglas.umbral, reglas.meta, reglas.presupuesto, reglas.ficha_por_pedir], ["custodio", 17, 200, 10, 0])

func test_dueno_muestra_el_umbral_vigente() -> void:
	var m := ControladorMesa.new()
	autofree(m)
	m.configurar_campana(_campana(3))
	assert_eq(m.reglas_ayuda().umbral, 25)
	m.partida.mazo.clear()
	for valor in [2, 3, 4, 5]: m.partida.mazo.append(FabricaCartas.crear_carta("velas", valor))
	m.procesar_comando(IniciarMano.new())
	assert_eq(m.reglas_ayuda().umbral, 25)
	m.procesar_comando(Plantarse.new())
	assert_eq(m.reglas_ayuda().umbral, 24, "Entre manos el libro anuncia el umbral de la siguiente.")
	m.procesar_comando(IniciarMano.new())
	assert_eq(m.reglas_ayuda().umbral, 24)

func test_libro_del_recaudador_cobra_una_ficha_por_pedir() -> void:
	var guia = _libro(_mesa_campana(1))
	assert_eq(guia.find_child("Coste0", true, false).text, "−1 campanada")
	assert_eq(guia.find_child("Coste1", true, false).text, "−1 ficha")
	var condiciones: String = guia.find_child("CondicionesMesa", true, false).text
	assert_string_contains(condiciones, "400")
	assert_string_contains(condiciones, "21")
	assert_string_contains(condiciones, "12 manos")
	assert_false(condiciones.contains("Pedir es gratis"))
	assert_string_contains(guia.find_child("NotaMesa", true, false).text, "reparto inicial es cortesía")
	assert_string_contains(guia.find_child("ResumenMesa", true, false).text, "EL RECAUDADOR")
	guia.ir_a_pagina(1)
	var palos: String = ""
	for etiqueta in guia.find_children("*", "Label", true, false): palos += etiqueta.text
	assert_false(palos.contains("Pedirlos es gratis"))
	await get_tree().process_frame
	await get_tree().process_frame

func test_libro_de_las_demas_mesas_y_de_i1_no_cobra_fichas() -> void:
	for nivel in [0, 2, 3]:
		var mesa = _mesa_campana(nivel)
		var guia = _libro(mesa)
		var reglas: ReglaMesa = CampanaCasino.MESAS_CAMPANA.de(CampanaCasino.MESAS[nivel])
		assert_eq(guia.find_child("Coste1", true, false).text, "Gratis")
		assert_string_contains(guia.find_child("CondicionesMesa", true, false).text, str(reglas.meta))
		assert_string_contains(guia.find_child("ResumenMesa", true, false).text, "UMBRAL %s" % reglas.umbral)
		mesa.cerrar_modal()
	var i1 = Mesa.instantiate()
	i1.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	i1.size = Vector2(1440, 810)
	add_child_autofree(i1)
	var guia = _libro(i1)
	assert_eq(guia.find_child("Coste1", true, false).text, "Gratis")
	assert_string_contains(guia.find_child("CondicionesMesa", true, false).text, "200 puntos")
	assert_string_contains(guia.find_child("ResumenMesa", true, false).text, "EL CUSTODIO · UMBRAL 17")

# --- I2-K2 · Objetivo discreto ---

func test_objetivo_sigue_el_progreso_y_no_cambia_con_la_tienda() -> void:
	var c := CampanaCasino.new()
	assert_eq(c.objetivo(), "Habla con la anfitriona")
	c.recibir_invitacion()
	assert_eq(c.objetivo(), "Encuentra la mesa del Custodio")
	assert_true(c.comprar("lente"))
	assert_eq(c.objetivo(), "Encuentra la mesa del Custodio")
	var textos := ["Encuentra la mesa del Recaudador", "Encuentra la mesa de la Coleccionista", "Encuentra la mesa del Dueño de la Casa", "Abre el portón del amanecer"]
	for nivel in range(4):
		assert_true(c.iniciar(CampanaCasino.MESAS[nivel]))
		c.cerrar(true, 0)
		c.resolver_recompensa()
		assert_eq(c.objetivo(), textos[nivel])

func test_indicador_cambia_una_vez_y_se_oculta_con_ventanas() -> void:
	var juego = _casino()
	assert_eq(juego.indicador_objetivo.texto.text, "Habla con la anfitriona")
	assert_true(juego.indicador_objetivo.visible)
	juego._recepcion()
	assert_false(juego.indicador_objetivo.visible, "Diálogo abierto")
	juego.dialogo.completar()
	juego.dialogo.elegir(0)
	juego.dialogo.completar()
	juego.dialogo.elegir(1)
	assert_eq(juego.indicador_objetivo.texto.text, "Encuentra la mesa del Custodio")
	assert_eq(juego.indicador_objetivo.cambios, 1)
	assert_false(juego.indicador_objetivo.visible)
	juego._cerrar()
	assert_true(juego.indicador_objetivo.visible)
	juego.inventario()
	assert_false(juego.indicador_objetivo.visible, "Inventario abierto")
	juego._cerrar()
	juego.entrar("pasillo_custodio", "vestibulo")
	juego.tienda()
	assert_false(juego.indicador_objetivo.visible, "Tienda abierta")
	juego._cerrar()
	juego.entrar("vestibulo")
	assert_true(juego.indicador_objetivo.visible)
	assert_eq(juego.indicador_objetivo.cambios, 1, "Pasear y abrir la tienda no cambia el objetivo.")
	juego.entrar("custodio")
	juego._presentar_jefe()
	juego.libro.primero.pressed.emit()
	assert_not_null(juego.mesa)
	await get_tree().process_frame
	assert_false(juego.indicador_objetivo.visible, "Mesa de cartas abierta")
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.meta = 1
	m.partida.mazo.clear()
	for valor in [2, 3]: m.partida.mazo.append(FabricaCartas.crear_carta("velas", valor))
	m.procesar_comando(IniciarMano.new())
	m.procesar_comando(Plantarse.new())
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	assert_eq(juego.indicador_objetivo.texto.text, "Encuentra la mesa del Recaudador")
	assert_eq(juego.indicador_objetivo.cambios, 2)
	juego.libro.primero.pressed.emit()
	await get_tree().process_frame
	assert_true(juego.indicador_objetivo.visible)
	assert_eq(juego.indicador_objetivo.cambios, 2)

func test_indicador_deja_pasar_clics_y_no_tapa_el_juego() -> void:
	var juego = _casino()
	var nodos: Array = [juego.indicador_objetivo]
	nodos.append_array(juego.indicador_objetivo.find_children("*", "Control", true, false))
	for nodo in nodos: assert_eq(nodo.mouse_filter, Control.MOUSE_FILTER_IGNORE, str(nodo.name))
	juego.campana.recibir_invitacion()
	juego.campana.superadas = 2
	await get_tree().process_frame
	var caja: Rect2 = juego.indicador_objetivo.get_rect()
	assert_eq(juego.indicador_objetivo.texto.text, "Encuentra la mesa de la Coleccionista")
	assert_gte(caja.position.y, juego.mundo.position.y, "Debajo del encabezado")
	assert_lte(caja.size.y, 60.0, "Como máximo dos líneas")
	assert_lte(caja.end.x, 560.0, "Ocupa solo la esquina izquierda")
	assert_lt(caja.end.y, juego.mundo.position.y + 178, "Por encima del área caminable de las salas")
	for sala in ["entrada", "vestibulo", "pasillo_custodio", "pasillo_recaudador", "pasillo_coleccionista", "tienda", "custodio", "dueno"]:
		juego.campana.superadas = 4
		juego.entrar(sala)
		for punto in juego.exploracion.puntos:
			assert_false(caja.has_point(juego.mundo.position + punto.pos), "%s · %s" % [sala, punto.accion])
	await get_tree().process_frame
	await get_tree().process_frame
