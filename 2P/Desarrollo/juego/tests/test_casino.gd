extends GutTest



func nueva() -> CampanaCasino:
	var c := CampanaCasino.new()
	c.recibir_invitacion()
	return c

func control(c: CampanaCasino, nivel := 0) -> ControladorMesa:
	c.superadas = nivel
	assert_true(c.iniciar(CampanaCasino.MESAS[nivel]))
	var m := ControladorMesa.new()
	autofree(m)
	m.configurar_campana(c)
	return m

func reparto(m: ControladorMesa, palos: Array, valores: Array) -> void:
	m.partida.mazo.clear()
	for i in palos.size(): m.partida.mazo.append(FabricaCartas.crear_carta(palos[i],valores[i]))

func test_reglas_de_coleccionista_y_dueno_siguen_el_balance_de_campana() -> void:
	# BALANCE_CAMPANA.md: la Coleccionista deja de ser un pase libre y el Dueño
	# se puede superar sin compras en torno a un tercio de las veces.
	for nivel in [2, 3]:
		var m := control(nueva(), nivel)
		var esperado: Array = [[25, 700, 12, 12], [25, 750, 17, 17]][nivel - 2]
		assert_eq([m.partida.umbral, m.partida.meta, m.presupuesto, m.partida.campanadas], esperado)

func test_recepcion_unica_y_puertas() -> void:
	var c := CampanaCasino.new()
	assert_false(c.iniciar("custodio"))
	assert_false(c.puerta_abierta("recaudador"))
	c.recibir_invitacion()
	assert_true(c.comprar("lente"))
	c.recibir_invitacion()
	assert_eq(c.saldo,4)
	assert_eq(c.baraja.size(),24)
	assert_true(c.iniciar("custodio"))
	assert_false(c.comprar("lente"))
	assert_eq(c.cerrar(true,2),20)
	assert_eq(c.cerrar(true,2),0)
	assert_true(c.resolver_recompensa())
	assert_true(c.puerta_abierta("recaudador"))
	assert_false(c.iniciar("custodio"))
	assert_false(c.iniciar("dueno"))

func test_tienda_confirma_coste_y_limites_de_baraja() -> void:
	var c := nueva()
	c.saldo = 200
	var primera := c.baraja[0]
	var v := primera.definicion.valor_impreso
	assert_true(c.comprar("subir",primera))
	assert_eq(primera.definicion.valor_impreso,v+1)
	assert_false(c.comprar("bajar",primera))
	assert_true(c.comprar("moneda"))
	assert_false(c.comprar("moneda"))
	assert_true(c.comprar("lente"))
	assert_true(c.comprar("lente"))
	assert_false(c.comprar("lente"))
	while c.baraja.size()>12: assert_true(c.comprar("eliminar",c.baraja.back()))
	var saldo := c.saldo
	assert_false(c.comprar("eliminar",c.baraja.back()))
	assert_eq(c.saldo,saldo)
	assert_eq(nueva().baraja.size(),24)

func test_lente_muestra_solo_mascaras_actuales_y_corona_requiere_otra() -> void:
	var c := nueva()
	c.amuletos.append("corona")
	c.lentes = 1
	var m := control(c)
	assert_false(m.usar_lente())
	reparto(m,["llaves","mascaras","mascaras"],[3,4,5])
	m.procesar_comando(IniciarMano.new())
	assert_null(m.obtener_vista().cartas[1].valor)
	assert_true(m.usar_lente())
	assert_eq(c.lentes,0)
	assert_eq(m.obtener_vista().intervalo.conocido,7)
	assert_false(m.obtener_vista().cartas[1].oculta)
	assert_true(m.obtener_vista().llaves_disponibles.is_empty())
	m.procesar_comando(PedirCarta.new())
	assert_true(m.obtener_vista().cartas[2].oculta)
	m.procesar_comando(Plantarse.new())
	assert_eq(m.obtener_vista().ultima_mano.corona,2)
	assert_eq(m.obtener_vista().ultima_mano.puntos,60)

func test_lente_sin_mascara_nueva_y_limites_de_amuletos() -> void:
	var c := nueva()
	c.amuletos.assign(["corona","prudente","moneda"])
	c.lentes = 1
	var m := control(c)
	for i in range(3):
		reparto(m,["mascaras","llaves"],[3,5])
		m.procesar_comando(IniciarMano.new())
		if i == 0: assert_true(m.usar_lente())
		m.procesar_comando(Plantarse.new())
		assert_eq(m.obtener_vista().ultima_mano.get("corona",0),0 if i==0 else 2)
	# Tres manos cuestan tres campanadas; el Sello devuelve solo una por mesa.
	assert_eq(m.partida.campanadas,8)
	m.partida.meta = 1000
	for i in range(4):
		reparto(m,["llaves","llaves"],[8,9])
		m.procesar_comando(IniciarMano.new())
		m.procesar_comando(Plantarse.new())
	assert_eq(c.saldo,16)
	assert_eq(m.exactos,4)

func test_usar_lente_publica_una_vista_sin_aceptar_comandos_reentrantes() -> void:
	var c := nueva()
	c.lentes = 1
	var m := control(c)
	reparto(m, ["llaves", "mascaras", "velas"], [3, 4, 5])
	assert_true(m.procesar_comando(IniciarMano.new()).aceptado)
	var recibidas: Array[Dictionary] = []
	var aceptados: Array[bool] = []
	m.vista_actualizada.connect(func(vista: Dictionary) -> void:
		recibidas.append(vista)
		aceptados.append(m.procesar_comando(PedirCarta.new()).aceptado), CONNECT_ONE_SHOT)
	assert_true(m.usar_lente())
	assert_eq(aceptados, [false])
	assert_eq(recibidas.size(), 1)
	assert_eq(recibidas[0].cartas[1].valor, 4)
	assert_eq(m.partida.mano.size(), 2)
	assert_true(m.procesar_comando(PedirCarta.new()).aceptado)

func test_recaudador_cobra_solo_si_entrega_carta() -> void:
	var c := nueva()
	var m := control(c,1)
	assert_eq(c.saldo,25)
	assert_false(c.iniciar("recaudador"))
	reparto(m,["llaves","velas","llaves"],[1,2,3])
	m.procesar_comando(IniciarMano.new())
	assert_eq(c.saldo,25)
	m.procesar_comando(PedirCarta.new())
	assert_eq(c.saldo,24)
	assert_false(m.procesar_comando(PedirCarta.new()).aceptado)
	assert_eq(c.saldo,24)
	c.saldo=0
	m.partida.mazo.append(FabricaCartas.crear_carta("llaves",1))
	assert_false(m.obtener_vista().acciones.pedir)
	assert_false(m.procesar_comando(PedirCarta.new()).aceptado)
	assert_true(m.procesar_comando(Plantarse.new()).aceptado)
	m.reiniciar()
	m.cargar_demostracion()
	assert_eq(c.saldo,0)
	assert_eq(m.partida.campanadas,11)

func test_retencion_desempata_por_ultima_y_dueno_puntua_con_umbral_vigente() -> void:
	var c := nueva()
	var m := control(c,2)
	reparto(m,["llaves","velas","mascaras"],[4,4,7])
	var ultima := m.partida.mazo[1]
	m.procesar_comando(IniciarMano.new())
	m.procesar_comando(Plantarse.new())
	assert_eq(m.partida.retenidas,[ultima])
	var vista := m.obtener_vista()
	assert_eq(vista.cartas[1].id, ultima.id_instancia)
	assert_eq(vista.retenidas, 1)
	assert_eq(m.partida.disponibles(),2)
	m.procesar_comando(IniciarMano.new())
	m.procesar_comando(Plantarse.new())
	assert_eq(m.partida.retenidas.size(),1)
	c.cerrar(true,0)
	c.resolver_recompensa()
	var final := control(c,3)
	reparto(final,["llaves","mascaras","velas"],[8,9,8])
	final.procesar_comando(IniciarMano.new())
	final.procesar_comando(PedirCarta.new())
	final.procesar_comando(Plantarse.new())
	assert_has(final.obtener_vista().ultima_mano.patrones,"Punto exacto")
	assert_eq(final.obtener_vista().umbral,25)
	final.procesar_comando(IniciarMano.new())
	assert_eq(final.obtener_vista().umbral,24)

func test_recorrido_f5_interaccion_compra_mesa_y_regreso() -> void:
	var juego = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	add_child_autofree(juego)
	assert_eq(juego.sala,"entrada")
	var pos: Vector2 = juego.visitante.position
	Input.action_press("norte")
	for i in range(8): await get_tree().physics_frame
	Input.action_release("norte")
	assert_lt(juego.visitante.position.y,pos.y)
	juego.entrar("vestibulo","entrada")
	juego.visitante.position = Vector2(985,288)
	var e := InputEventKey.new()
	e.keycode = KEY_E
	e.physical_keycode = KEY_E
	e.pressed = true
	juego._unhandled_key_input(e)
	assert_true(juego.dialogo.visible, "La anfitriona habla en la escena de diálogos")
	assert_true(juego.visitante.bloqueado)
	assert_eq(juego.dialogo.actual, "llegada", "La primera vez, la primera respuesta a la anfitriona")
	juego.dialogo.cerrar()
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
	juego.dialogo.elegir(0)
	assert_eq(juego.campana.saldo,10)
	assert_eq(juego.campana.lentes,1, "La Lente de humo es el objeto inicial elegido")
	for i in range(6):
		if not juego.dialogo.visible: break
		juego.dialogo.completar()
		juego.dialogo.avanzar()
	assert_false(juego.visitante.bloqueado)
	juego.entrar("pasillo_custodio","vestibulo")
	juego.entrar("tienda")
	assert_eq(juego.sala,"pasillo_custodio", "La tienda abre tras el primer sello")
	juego.entrar("custodio")
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	assert_not_null(juego.mesa)
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.meta=1
	reparto(m,["llaves","velas"],[2,3])
	m.procesar_comando(IniciarMano.new())
	m.procesar_comando(Plantarse.new())
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	assert_null(juego.mesa)
	assert_true(juego.campana.puerta_abierta("recaudador"))
	assert_true(juego.campana.puerta_abierta("tienda"))
	assert_eq(juego.campana.saldo,20)
	assert_true(juego.recompensa.visible, "La recompensa se elige en su propia pantalla")
	assert_true(juego.visitante.bloqueado)
	await get_tree().process_frame
	await get_tree().process_frame

func test_colision_del_mostrador_y_derrota_sin_premio() -> void:
	var juego = load("res://casino/casino.tscn").instantiate()
	add_child_autofree(juego)
	juego.entrar("vestibulo")
	juego.visitante.position = Vector2(980,289)
	Input.action_press("norte")
	for i in range(18): await get_tree().physics_frame
	Input.action_release("norte")
	assert_gte(juego.visitante.position.y,274.0)
	assert_lt(juego.visitante.position.y,289.0)
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._jugar()
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.campanadas = 1
	reparto(m,["llaves","velas"],[9,10])
	m.procesar_comando(IniciarMano.new())
	m.procesar_comando(Plantarse.new())
	assert_false(m.obtener_vista().victoria)
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	assert_true(juego.campana.derrota)
	assert_false(juego.campana.puerta_abierta("recaudador"))
	assert_eq(juego.campana.saldo,10)
	var historia: Control = juego.historia
	for i in range(5):
		historia.completar()
		historia.avanzar()
	historia.elegir(0)
	assert_eq(juego.campana.saldo,0)
	assert_eq(juego.sala,"entrada")
	await get_tree().process_frame
	await get_tree().process_frame

func test_campana_completa_con_baraja_normal_y_recompensas_unicas() -> void:
	var juego = load("res://casino/casino.tscn").instantiate()
	add_child_autofree(juego)
	juego._entregar()
	juego._cerrar()
	var c: CampanaCasino = juego.campana
	c.comprar("lente")
	for nivel in range(4):
		if nivel > 0:
			if not c.amuletos.has("corona"): c.comprar("corona")
			if not c.amuletos.has("prudente"): c.comprar("prudente")
			if c.lentes == 0: c.comprar("lente")
		var mesa_actual: String = CampanaCasino.MESAS[nivel]
		var pasillo: String = PlanoGaleria.PADRE[mesa_actual]
		juego.entrar(pasillo,juego.sala)
		assert_eq(juego.sala,pasillo)
		juego.visitante.position = PlanoGaleria.punto(pasillo, mesa_actual) + (Vector2(0,12) if PlanoGaleria.norte(pasillo, mesa_actual) else Vector2(-12,0))
		juego.interactuar(juego.cercano())
		assert_eq(juego.sala,CampanaCasino.MESAS[nivel])
		juego.visitante.position = Vector2(640,536)
		juego.interactuar(juego.cercano())
		assert_true(juego.dialogo.visible, "El crupier habla en la escena de novela visual")
		juego._solicitud("tomar_asiento")
		var m: ControladorMesa = juego.mesa.controlador
		juego.mesa.movimiento_reducido = true
		m.partida._rng.seed = 98+nivel
		m.partida.mazo.assign(c.baraja)
		m.partida._barajar()
		for paso in range(220):
			var v := m.obtener_vista()
			if v.terminado: break
			if v.fase == "preparado": juego.mesa.boton_iniciar_pedir.pressed.emit()
			elif c.lentes>0 and v.intervalo.ocultas and v.intervalo.maximo>v.umbral: juego.mesa.boton_lente.pressed.emit()
			elif v.acciones.pedir and (v.intervalo.minimo+v.intervalo.maximo)/2.0 <= v.umbral-6.0: juego.mesa.boton_iniciar_pedir.pressed.emit()
			else: juego.mesa.boton_plantarse.pressed.emit()
		assert_true(m.obtener_vista().victoria)
		juego.mesa.boton_iniciar_pedir.pressed.emit()
		assert_eq(c.superadas,nivel+1)
		if juego.recompensa.visible: juego.recompensa.boton_omitir.pressed.emit()
		else: juego.libro.lista.get_child(-1).pressed.emit()
	juego.visitante.position=Vector2(640,194)
	juego.interactuar(juego.cercano())
	assert_eq(juego.libro.primero.text,"Comenzar otro viaje")
	juego.libro.primero.pressed.emit()
	assert_eq(juego.sala,"entrada")
	assert_eq(juego.campana.superadas,0)
	assert_false(juego.campana.recibida)
	await get_tree().process_frame
	await get_tree().process_frame

func test_cada_mesa_usa_la_regla_de_su_crupier() -> void:
	assert_true(FabricaCrupieres.para("custodio") is ReglaCrupier)
	assert_false(FabricaCrupieres.para("custodio").cobra_por_pedir())
	assert_true(FabricaCrupieres.para("recaudador") is ReglaRecaudador)
	assert_true(FabricaCrupieres.para("coleccionista") is ReglaColeccionista)
	assert_true(FabricaCrupieres.para("dueno") is ReglaDueno)
	assert_true(FabricaCrupieres.para("") is ReglaCrupier, "La mesa suelta de I1 no tiene regla especial")
	for nivel in range(4):
		var m := control(nueva(), nivel)
		assert_eq(m.regla.cobra_por_pedir(), nivel == 1)

func test_catalogos_de_mesas_y_tienda_cargan_desde_resources() -> void:
	var ids := []
	for mesa: ReglaMesa in CampanaCasino.MESAS_CAMPANA.mesas: ids.append(mesa.id)
	assert_eq(ids, CampanaCasino.MESAS, "Las mesas del recurso siguen el orden de la campaña")
	var precios := {}
	for objeto: ObjetoTienda in CampanaCasino.TIENDA.objetos: precios[objeto.id] = objeto.precio
	assert_eq(precios, {"lente": 6, "corona": 15, "prudente": 12, "moneda": 10, "eliminar": 4, "subir": 5, "bajar": 5})
	assert_null(CampanaCasino.TIENDA.buscar("inexistente"))
	assert_null(CampanaCasino.MESAS_CAMPANA.de("inexistente"))
