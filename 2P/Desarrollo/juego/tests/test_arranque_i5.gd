extends GutTest
## I5: elección inicial de la anfitriona, recompensa tras el Custodio, «Ver baraja» y la
## variante de la Vela que cuenta doble para Racha.

const OFERTA := ["lente", "prudente", "moneda"]

func after_each() -> void:
	await get_tree().process_frame

func _casino():
	var juego = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	juego.entrar("vestibulo", "entrada")
	return juego

func _tecla(juego, codigo: Key) -> void:
	var tecla := InputEventKey.new()
	tecla.keycode = codigo
	tecla.physical_keycode = codigo
	tecla.pressed = true
	juego.get_viewport().push_input(tecla)

## Abre la conversación y llega a la oferta con sus botones listos.
func _abrir_oferta(juego) -> void:
	juego.campana.historia = {"vio_vestibulo": "si", "tono": "cortes"}
	juego._recepcion()
	juego.dialogo.completar()
	juego.dialogo.elegir(0)
	juego.dialogo.completar()
	juego.dialogo.avanzar()
	juego.dialogo.completar()
	juego.dialogo.elegir(2)
	juego.dialogo.completar()
	juego.dialogo.avanzar()
	juego.dialogo.completar()
	assert_eq(juego.dialogo.actual, "oferta")

func _cartas(m: ControladorMesa, palos: Array, valores: Array) -> void:
	m.partida.mazo.clear()
	for i in palos.size(): m.partida.mazo.append(FabricaCartas.crear_carta(palos[i], valores[i]))

func _vencer_al_custodio(juego) -> void:
	juego.entrar("pasillo_custodio", "vestibulo")
	juego.entrar("custodio", "pasillo_custodio")
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.meta = 1
	_cartas(m, ["llaves", "velas"], [2, 3])
	m.procesar_comando(IniciarMano.new())
	m.procesar_comando(Plantarse.new())
	juego.mesa.boton_iniciar_pedir.pressed.emit()

# --- Elección inicial -----------------------------------------------------------------

func test_cada_opcion_entrega_baraja_fichas_y_solo_ese_objeto(indice = use_parameters([0, 1, 2])) -> void:
	var juego = _casino()
	_abrir_oferta(juego)
	assert_false(juego.campana.recibida, "Ver la oferta no entrega nada")
	juego.dialogo.elegir(indice)
	var c: CampanaCasino = juego.campana
	assert_true(c.recibida)
	assert_eq(c.saldo, 10)
	assert_eq(c.baraja.size(), 24)
	var id: String = OFERTA[indice]
	assert_eq(c.lentes, 1 if id == "lente" else 0)
	assert_eq(c.amuletos, ([] if id == "lente" else [id]) as Array[String])
	assert_true(juego.dialogo.actual.begins_with("entrega_"), "Una línea propia de cada objeto")
	juego.inventario()
	var panel: Control = juego.libro.lista.get_child(0)
	assert_eq(panel.find_child("Cifra", true, false).text, "10")
	var objetos: Node = panel.get_child(2)
	assert_eq(objetos.get_child_count(), 1, "Solo el objeto elegido")
	assert_eq(objetos.get_child(0).tooltip_text, CampanaCasino.TIENDA.buscar(id).nombre)

func test_la_oferta_muestra_icono_nombre_y_efecto_del_catalogo() -> void:
	var juego = _casino()
	_abrir_oferta(juego)
	assert_eq(juego.dialogo.botones.size(), 4, "Tres objetos y pensarlo")
	for indice in 3:
		var producto := CampanaCasino.TIENDA.buscar(OFERTA[indice])
		var boton: Button = juego.dialogo.botones[indice]
		assert_not_null(boton.icon, producto.nombre)
		assert_string_contains(boton.text, producto.nombre)
		assert_string_contains(boton.text, producto.descripcion)
	assert_null(juego.dialogo.botones[3].icon)

func test_se_elige_con_teclado() -> void:
	var juego = _casino()
	_abrir_oferta(juego)
	await get_tree().process_frame
	assert_eq(juego.get_viewport().gui_get_focus_owner(), juego.dialogo.botones[0])
	juego.dialogo.botones[1].grab_focus()
	_tecla(juego, KEY_E)
	assert_eq(juego.campana.amuletos, ["prudente"] as Array[String])

func test_cerrar_antes_de_elegir_permite_retomar_la_oferta() -> void:
	var juego = _casino()
	_abrir_oferta(juego)
	juego.dialogo.elegir(3)
	assert_false(juego.dialogo.visible, "Pensarlo cierra el diálogo")
	assert_false(juego.campana.recibida)
	_abrir_oferta(juego)
	_tecla(juego, KEY_ESCAPE)
	assert_false(juego.dialogo.visible, "Esc también cierra")
	assert_false(juego.campana.recibida)
	assert_false(juego.campana.puerta_abierta("pasillo_custodio"), "Sin elegir no se avanza")
	_abrir_oferta(juego)
	juego.dialogo.elegir(2)
	assert_eq(juego.campana.amuletos, ["moneda"] as Array[String])
	assert_true(juego.campana.puerta_abierta("pasillo_custodio"))

func test_confirmar_dos_veces_no_duplica_la_entrega() -> void:
	var juego = _casino()
	_abrir_oferta(juego)
	juego.dialogo.elegir(0)
	var c: CampanaCasino = juego.campana
	c.saldo = 7
	for solicitud in ["objeto_inicial:lente", "objeto_inicial:moneda", "entregar_invitacion"]:
		assert_false(c.atender(solicitud), solicitud)
	juego._solicitud("objeto_inicial:lente")
	assert_eq([c.saldo, c.lentes, c.amuletos.size(), c.baraja.size()], [7, 1, 0, 24])
	juego._cerrar()
	juego._recepcion()
	assert_eq(juego.dialogo.actual, "pista_0", "Después de elegir ya no vuelve a ofrecer")

func test_la_campana_rechaza_objetos_fuera_de_la_oferta() -> void:
	var c := CampanaCasino.new()
	assert_false(c.atender("objeto_inicial:corona"))
	assert_false(c.atender("objeto_inicial:"))
	assert_false(c.recibida)

# --- Recompensa tras el Custodio ------------------------------------------------------

func test_elegir_la_carta_la_suma_y_sale_en_la_siguiente_mesa() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.campana.azar_recompensas.seed = 7
	_vencer_al_custodio(juego)
	var c: CampanaCasino = juego.campana
	assert_true(c.hay_recompensa())
	var opciones := c.opciones_recompensa()
	var fila: Node = juego.libro.lista.get_children().filter(func(n: Node) -> bool: return n.has_signal("elegida"))[0]
	assert_eq(fila.get_child_count(), 3, "Se reutiliza la fila de tres cartas")
	fila.get_child(0).pressed.emit()
	assert_false(c.hay_recompensa())
	assert_eq(c.baraja.size(), 25)
	var ganada: CartaEnPartida = c.baraja.back()
	assert_eq([ganada.definicion.palo, ganada.definicion.valor_impreso], [opciones[0].palo, opciones[0].valor])
	assert_true(c.ganadas.has(ganada.id_instancia))
	juego.entrar("pasillo_custodio", "custodio")
	juego.entrar("pasillo_recaudador", "pasillo_custodio")
	juego.entrar("recaudador", "pasillo_recaudador")
	assert_eq(juego.sala, "recaudador")
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	var m: ControladorMesa = juego.mesa.controlador
	assert_true(m.partida.mazo.has(ganada), "La carta ganada entra en el mazo de la siguiente mesa")
	assert_eq(m.partida.mazo.size(), 25)

func test_omitir_conserva_la_baraja() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	var antes: Array = juego.campana.baraja.map(func(c: CartaEnPartida) -> String: return c.id_instancia)
	_vencer_al_custodio(juego)
	var omitir: Button = juego.libro.lista.get_child(-1)
	assert_eq(omitir.text, "Omitir carta")
	omitir.pressed.emit()
	assert_false(juego.campana.hay_recompensa())
	assert_eq(juego.campana.baraja.map(func(c: CartaEnPartida) -> String: return c.id_instancia), antes)
	assert_true(juego.campana.ganadas.is_empty())

# --- Ver baraja -----------------------------------------------------------------------

func test_ver_baraja_desde_el_inventario_en_exploracion() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.inventario()
	var boton: Button = null
	for hijo in juego.libro.lista.get_children():
		if hijo is Button and hijo.text == "Ver baraja": boton = hijo
	assert_not_null(boton, "El inventario ofrece Ver baraja")
	boton.grab_focus()
	boton.pressed.emit()
	var vista = juego.vista_baraja
	assert_true(vista.visible)
	assert_eq(vista.total.text, "24 cartas")
	var suma := 0
	for fila in vista.filas: suma += fila.get_child_count()
	assert_eq(suma, 24)
	for indice in Palos.TODOS.size():
		for carta in vista.filas[indice].get_children():
			assert_eq(carta.get_meta("datos").palo, Palos.TODOS[indice], "Agrupadas por palo")
	await get_tree().process_frame
	_tecla(juego, KEY_ESCAPE)
	assert_false(vista.visible)
	assert_true(juego.libro.visible, "Vuelve al inventario abierto")
	assert_eq(juego.get_viewport().gui_get_focus_owner(), boton, "El foco vuelve a Ver baraja")

func test_las_filas_van_de_menor_a_mayor_y_no_siguen_el_mazo() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.campana.baraja.shuffle()
	juego.ver_baraja()
	for fila in juego.vista_baraja.filas:
		var previo := 0
		for carta in fila.get_children():
			var valor: int = carta.get_meta("datos").valor
			assert_gte(valor, previo)
			previo = valor
	for datos: Dictionary in juego.datos_baraja().cartas:
		assert_false(datos.has("id"), "Sin identidad de instancia ni posición en el mazo")

func test_ver_baraja_refleja_ganadas_ajustes_y_retiros() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	var c: CampanaCasino = juego.campana
	c.saldo = 100
	var subida := c.baraja[0]
	var retirada := c.baraja[1]
	var valor_retirada := retirada.definicion.valor_impreso
	assert_true(c.comprar("subir", subida))
	assert_true(c.comprar("eliminar", retirada))
	c.iniciar("custodio")
	c.cerrar(true, 0)
	c.resolver_recompensa(0)
	var datos: Dictionary = juego.datos_baraja()
	assert_eq(datos.cartas.size(), 24)
	assert_eq(datos.retiradas, [{"palo": retirada.definicion.palo, "valor": valor_retirada}])
	var ajustadas: Array = datos.cartas.filter(func(d: Dictionary) -> bool: return d.ajuste == 1)
	assert_eq(ajustadas.size(), 1)
	assert_string_contains(ajustadas[0].nota, "AJUSTE +1")
	assert_eq(ajustadas[0].valor, subida.definicion.valor_impreso)
	assert_eq(datos.cartas.filter(func(d: Dictionary) -> bool: return d.ganada).size(), 1)
	juego.ver_baraja()
	var textos := PackedStringArray()
	for linea in juego.vista_baraja.resumen.get_children():
		if linea is Label:
			textos.append(linea.text)
			textos.append(linea.tooltip_text)
	var resumen := "\n".join(textos)
	assert_string_contains(resumen, "Ganadas como recompensa: 1")
	assert_string_contains(resumen, "Con el valor ajustado: 1")
	assert_string_contains(resumen, "Retiradas en la tienda: 1")
	assert_string_contains(resumen, "%s de %s" % [valor_retirada, Palos.NOMBRES[retirada.definicion.palo]])

func test_ver_baraja_durante_una_mano_oculta_mascaras_y_vuelve_al_mismo_punto() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._jugar()
	var m: ControladorMesa = juego.mesa.controlador
	m.procesar_comando(IniciarMano.new())
	var antes := m.obtener_vista()
	var mazo_antes: Array = m.partida.mazo.duplicate()
	await get_tree().process_frame
	juego.pausar()
	juego.menu.botones[1].pressed.emit()
	assert_eq(juego.menu.pantalla, "inventario")
	assert_eq(juego.menu.botones[0].text, "Ver baraja")
	juego.menu.botones[0].grab_focus()
	juego.menu.botones[0].pressed.emit()
	assert_true(juego.vista_baraja.visible)
	var datos: Dictionary = juego.datos_baraja()
	assert_true(datos.en_mano)
	var mascaras: Array = datos.cartas.filter(func(d: Dictionary) -> bool: return d.palo == Palos.MASCARAS)
	assert_gt(mascaras.size(), 0)
	for mascara: Dictionary in mascaras:
		assert_true(mascara.oculta)
		assert_null(mascara.valor, "El valor de una Máscara no aparece durante la mano")
		assert_null(mascara.valor_efectivo)
	for carta in juego.vista_baraja.cartas:
		if carta.get_meta("datos").palo == Palos.MASCARAS:
			assert_eq(carta._valor.text, "?")
	_tecla(juego, KEY_ESCAPE)
	assert_false(juego.vista_baraja.visible)
	assert_eq(juego.menu.pantalla, "inventario", "Cerrar devuelve al inventario de la pausa")
	assert_eq(juego.get_viewport().gui_get_focus_owner(), juego.menu.botones[0])
	juego._reanudar()
	var despues := m.obtener_vista()
	assert_eq(m.partida.mazo, mazo_antes, "Consultar la baraja no toca el mazo")
	assert_eq([despues.fase, despues.campanadas, despues.cartas.size()], [antes.fase, antes.campanadas, antes.cartas.size()])

func test_sin_invitacion_no_hay_baraja_que_ver() -> void:
	var juego = _casino()
	juego.inventario()
	for hijo in juego.libro.lista.get_children():
		if hijo is Button: assert_ne(hijo.text, "Ver baraja")
	juego.ver_baraja()
	assert_false(juego.vista_baraja.visible)

# --- Variante: Vela de Racha ×2 -------------------------------------------------------

func _vela_doble(valor: int) -> CartaEnPartida:
	return FabricaCartas.crear_carta(Palos.VELAS, valor, "", CartaEnPartida.RASGO_RACHA_DOBLE)

func test_la_vela_doble_cuenta_dos_para_racha_y_su_valor_normal_para_el_umbral() -> void:
	var mano: Array[CartaEnPartida] = [FabricaCartas.crear_carta(Palos.LLAVES, 4), _vela_doble(5), FabricaCartas.crear_carta(Palos.VELAS, 3)]
	var resultado := EvaluadorMano.evaluar(mano, 17)
	assert_eq(resultado.total, 12, "Para el umbral vale lo impreso")
	assert_has(resultado.patrones, "Racha", "Vela ×2 + Vela = tres del palo")
	assert_eq(resultado.velas, 2, "Sigue sumando una Vela al multiplicador")
	var sin_doble: Array[CartaEnPartida] = [FabricaCartas.crear_carta(Palos.LLAVES, 4), FabricaCartas.crear_carta(Palos.VELAS, 5), FabricaCartas.crear_carta(Palos.VELAS, 3)]
	assert_does_not_have(EvaluadorMano.evaluar(sin_doble, 17).patrones, "Racha")

func test_la_vela_doble_solo_cuenta_si_participa_en_la_racha() -> void:
	var mano: Array[CartaEnPartida] = [_vela_doble(5), FabricaCartas.crear_carta(Palos.LLAVES, 2), FabricaCartas.crear_carta(Palos.LLAVES, 3)]
	assert_does_not_have(EvaluadorMano.evaluar(mano, 17).patrones, "Racha", "Una Llave en medio corta la racha")
	assert_eq(EvaluadorMano.racha([_vela_doble(2)]), 2)
	var quiebra: Array[CartaEnPartida] = [_vela_doble(10), FabricaCartas.crear_carta(Palos.VELAS, 9)]
	assert_true(EvaluadorMano.evaluar(quiebra, 17).quiebra, "Su valor normal puede provocar Quiebra")

func test_el_indicador_publico_de_racha_cuenta_la_vela_doble() -> void:
	var Indicadores = load("res://dominio/indicadores_patrones.gd")
	var cartas := [{"palo": Palos.LLAVES, "valor_efectivo": 2}, {"palo": Palos.VELAS, "valor_efectivo": 5, "rasgo": CartaEnPartida.RASGO_RACHA_DOBLE}, {"palo": Palos.VELAS, "valor_efectivo": 3}]
	var filas: Array = Indicadores.calcular(cartas, {"conocido": 10, "ocultas": 0, "minimo": 10, "maximo": 10}, 17)
	var racha: Dictionary = filas.filter(func(f: Dictionary) -> bool: return f.nombre == "Racha")[0]
	assert_eq(racha.estado, "activo")

func test_la_oferta_incluye_la_vela_y_muestra_su_efecto() -> void:
	var c := CampanaCasino.new()
	c.recibir_invitacion()
	c.azar_recompensas.seed = 11
	c.iniciar("custodio")
	c.cerrar(true, 0)
	var opciones := c.opciones_recompensa()
	assert_eq(opciones[2].palo, Palos.VELAS)
	assert_eq(opciones[2].rasgo, CartaEnPartida.RASGO_RACHA_DOBLE)
	var fila = load("res://casino/interfaz/cartas_recompensa.gd").new()
	add_child_autofree(fila)
	fila.presentar(opciones)
	var carta: Button = fila.get_child(2)
	assert_eq(carta._efecto.text, "RACHA ×2")
	assert_string_contains(carta.tooltip_text, "Racha")
	assert_true(c.resolver_recompensa(2))
	assert_eq(c.baraja.back().definicion.rasgo, CartaEnPartida.RASGO_RACHA_DOBLE)

func test_ver_baraja_senala_la_vela_doble() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.campana.baraja.append(_vela_doble(6))
	juego.ver_baraja()
	var marcadas: Array = juego.vista_baraja.cartas.filter(func(b: Button) -> bool: return b._efecto.text.contains("RACHA ×2"))
	assert_eq(marcadas.size(), 1)
	var resumen := PackedStringArray()
	for linea in juego.vista_baraja.resumen.get_children():
		if linea is Label: resumen.append(linea.text)
	assert_string_contains("\n".join(resumen), "Velas de Racha ×2: 1")

func test_sin_variante_la_oferta_es_la_de_siempre() -> void:
	var c := CampanaCasino.new()
	c.variante_vela = false
	c.recibir_invitacion()
	c.iniciar("custodio")
	c.cerrar(true, 0)
	for opcion in c.opciones_recompensa():
		assert_eq(opcion.rasgo, "")
