extends GutTest

func _crear_con_mascara() -> ControladorMesa:
	var c := ControladorMesa.new()
	add_child_autofree(c)
	var orden: Array[CartaEnPartida] = []
	for id in ["velas_08", "mascaras_08"]:
		for carta: CartaEnPartida in c.partida.mazo:
			if carta.definicion.id == id: orden.append(carta)
	for carta: CartaEnPartida in c.partida.mazo:
		if not orden.has(carta): orden.append(carta)
	c.partida.mazo = orden
	c.procesar_comando(IniciarMano.new())
	return c

func test_R09_mascara_intervalo_9_a_18_y_sin_desglose_anticipado() -> void:
	var c := _crear_con_mascara()
	var vista := c.obtener_vista()
	assert_eq(vista.intervalo, {"conocido": 8, "ocultas": 1, "minimo": 9, "maximo": 18})
	assert_null(vista.cartas[1].valor)
	assert_null(vista.cartas[1].valor_efectivo)
	assert_true(vista.cartas[1].oculta)
	assert_true(vista.ultima_mano.is_empty())
	assert_false(vista.cartas[1].has("definicion"))
	assert_false(vista.cartas[1].id.contains("mascaras"))
	assert_eq(vista.cartas[1].id.length(), 32)
	assert_eq(typeof(vista.mazo), TYPE_INT)

func test_R09_valor_real_oculto_no_cambia_ninguna_parte_de_vista() -> void:
	var c := _crear_con_mascara()
	var antes := c.obtener_vista()
	c.partida.mano[1].definicion.valor_impreso = 10
	assert_eq(c.obtener_vista(), antes, "No debe anticipar Quiebra aunque el total interno cambie")
	c.partida.mano[1].definicion.valor_impreso = 1
	assert_eq(c.obtener_vista(), antes)

func test_R09_al_plantarse_revela_y_solo_entonces_publica_puntuacion() -> void:
	var c := _crear_con_mascara()
	assert_true(c.procesar_comando(Plantarse.new()).aceptado)
	var vista := c.obtener_vista()
	assert_eq(vista.cartas[1].valor, 8)
	assert_false(vista.cartas[1].oculta)
	assert_eq(vista.ultima_mano.total, 16)
	assert_eq(vista.ultima_mano.puntos, 64)
	assert_eq(vista.intervalo.minimo, 16)
	assert_eq(vista.intervalo.maximo, 16)

func test_modificar_vista_no_modifica_el_modelo_ni_el_resultado() -> void:
	var c := _crear_con_mascara()
	var vista := c.obtener_vista()
	vista.cartas[0].valor = 99
	vista.acciones.pedir = false
	assert_eq(c.partida.mano[0].definicion.valor_impreso, 8)
	assert_true(c.obtener_vista().acciones.pedir)
	c.procesar_comando(Plantarse.new())
	var resultado := c.obtener_vista()
	resultado.ultima_mano.puntos = 999
	resultado.ultima_mano.patrones.clear()
	assert_eq(c.obtener_vista().ultima_mano.puntos, 64)
	assert_eq(c.obtener_vista().ultima_mano.patrones, ["Al filo"])

func test_reiniciar_sale_de_demostracion_y_renueva_identidades() -> void:
	var c := _crear_con_mascara()
	c.cargar_demostracion()
	assert_true(c.obtener_vista().modo_demostracion)
	var ids: Array = []
	for carta: CartaEnPartida in c.partida.mazo: ids.append(carta.id_instancia)
	c.reiniciar(41)
	assert_false(c.obtener_vista().modo_demostracion)
	for carta: CartaEnPartida in c.partida.mazo:
		assert_false(ids.has(carta.id_instancia))

func test_evaluar_es_repetible_y_no_modifica_cartas_o_definiciones() -> void:
	var c := _crear_con_mascara()
	var ids: Array = []
	var valores: Array = []
	for carta: CartaEnPartida in c.partida.mano:
		ids.append(carta.id_instancia)
		valores.append(carta.definicion.valor_impreso)
	var primero := EvaluadorMano.evaluar(c.partida.mano)
	assert_eq(EvaluadorMano.evaluar(c.partida.mano), primero)
	for i in range(c.partida.mano.size()):
		assert_eq(c.partida.mano[i].id_instancia, ids[i])
		assert_eq(c.partida.mano[i].definicion.valor_impreso, valores[i])

func test_R17_varios_reciclajes_conservan_todas_las_identidades() -> void:
	var estado := EstadoPartida.new(27)
	var originales: Array = []
	for carta: CartaEnPartida in estado.mazo: originales.append(carta.id_instancia)
	for ciclo in range(8):
		for i in range(6): estado.mano.append(estado.robar())
		estado.cerrar_mano()
		var actuales: Array = []
		for carta: CartaEnPartida in estado.mazo + estado.descarte + estado.mano:
			actuales.append(carta.id_instancia)
		originales.sort()
		actuales.sort()
		assert_eq(actuales, originales)
