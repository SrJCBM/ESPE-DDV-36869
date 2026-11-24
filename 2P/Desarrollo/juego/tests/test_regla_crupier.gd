extends GutTest
## I3-03: la regla del crupier se lee en la mesa y el cambio de umbral del Dueño se anuncia.

const Mesa = preload("res://mesa/mesa.tscn")
const Lectura = preload("res://mesa/lectura_mesa.gd")

func after_each() -> void:
	await get_tree().process_frame

func _campana(nivel: int) -> CampanaCasino:
	var c := CampanaCasino.new()
	c.recibir_invitacion()
	c.superadas = nivel
	assert_true(c.iniciar(CampanaCasino.MESAS[nivel]))
	return c

func _mesa(nivel: int, reducido := true):
	var mesa = Mesa.instantiate()
	if nivel >= 0: mesa.campana = _campana(nivel)
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	mesa.establecer_movimiento_reducido(reducido)
	return mesa

## Reparto fijo de cartas bajas: ninguna mano llega a Quiebra.
func _repartir_bajas(m: ControladorMesa) -> void:
	m.partida.mazo.clear()
	for i in range(20): m.partida.mazo.append(FabricaCartas.crear_carta("llaves", 1 + i % 3))

func test_vista_del_dueno_anuncia_umbral_anterior_y_siguiente() -> void:
	var m := ControladorMesa.new()
	autofree(m)
	m.configurar_campana(_campana(3))
	_repartir_bajas(m)
	var v := m.obtener_vista()
	assert_eq([v.mesa, v.umbral, v.umbral_anterior, v.umbral_siguiente], ["dueno", 25, -1, 25])
	m.procesar_comando(IniciarMano.new())
	v = m.obtener_vista()
	assert_eq([v.umbral, v.umbral_anterior, v.umbral_siguiente], [25, -1, 24])
	m.procesar_comando(Plantarse.new())
	v = m.obtener_vista()
	assert_eq([v.umbral, v.umbral_anterior, v.umbral_siguiente], [25, 25, 24], "Entre manos se anuncia la siguiente")
	m.procesar_comando(IniciarMano.new())
	v = m.obtener_vista()
	assert_eq([v.umbral, v.umbral_anterior, v.umbral_siguiente], [24, 25, 23])

func test_otras_mesas_no_anuncian_cambios_de_umbral() -> void:
	for nivel in range(3):
		var m := ControladorMesa.new()
		autofree(m)
		m.configurar_campana(_campana(nivel))
		var v := m.obtener_vista()
		assert_eq([v.umbral_anterior, v.umbral_siguiente], [-1, -1])

func test_textos_de_regla_por_mesa() -> void:
	assert_eq(Lectura.regla({"mesa": "custodio"}).texto, "", "El Custodio no tiene regla especial")
	assert_eq(Lectura.regla({}).texto, "", "La mesa suelta de I1 tampoco")
	assert_string_contains(Lectura.regla({"mesa": "recaudador", "saldo": 7}).texto, "1 ficha. Saldo: 7")
	assert_string_contains(Lectura.regla({"mesa": "coleccionista", "retenidas": 2}).texto, "Retenidas: 2")
	var mano := {"mesa": "dueno", "fase": "decision", "umbral": 24, "umbral_anterior": 25, "umbral_siguiente": 23}
	assert_eq(Lectura.regla(mano).texto, "El umbral bajó de 25 a 24. Si cierras esta mano sin Quiebra, bajará a 23.")
	assert_eq(Lectura.regla(mano).nota, "Baja a 23 sin Quiebra.")
	var tras_quiebra := {"mesa": "dueno", "fase": "decision", "umbral": 24, "umbral_anterior": 24, "umbral_siguiente": 23}
	assert_string_contains(Lectura.regla(tras_quiebra).texto, "sigue en 24: tu última mano fue Quiebra")
	var entre_quiebra := {"mesa": "dueno", "fase": "preparado", "umbral": 24, "umbral_anterior": 24, "umbral_siguiente": 24}
	assert_string_contains(Lectura.regla(entre_quiebra).texto, "La Quiebra no baja el umbral")
	var minimo := {"mesa": "dueno", "fase": "decision", "umbral": 17, "umbral_anterior": 17, "umbral_siguiente": 17}
	assert_string_contains(Lectura.regla(minimo).texto, "mínimo: 17")
	var entre := {"mesa": "dueno", "fase": "preparado", "umbral": 25, "umbral_anterior": 25, "umbral_siguiente": 24}
	assert_eq(Lectura.regla(entre).nota, "Próxima mano: 24.")

func test_placa_visible_en_el_dueno_y_oculta_en_el_custodio() -> void:
	var custodio = _mesa(-1)
	assert_false(custodio._regla.visible)
	assert_eq(custodio._nota_umbral.text, "", "Sin regla que cambie el umbral, no hay nota (I4-03)")
	var dueno = _mesa(3)
	assert_true(dueno._regla.visible)
	assert_string_contains(dueno._regla_texto.text, "Empieza en 25")
	await get_tree().process_frame
	var rect: Rect2 = dueno._regla.get_global_rect()
	var umbral_rect: Rect2 = dueno._umbral.get_global_rect()
	assert_false(rect.intersects(umbral_rect), "La placa no tapa el umbral")

func test_cambio_de_umbral_late_y_se_explica() -> void:
	var mesa = _mesa(3, false)
	var m: ControladorMesa = mesa.controlador
	_repartir_bajas(m)
	m.procesar_comando(IniciarMano.new())
	m.procesar_comando(Plantarse.new())
	assert_eq(mesa._nota_umbral.text, "Próxima mano: 24.")
	assert_eq(mesa._umbral.scale, Vector2.ONE, "Plantarse no cambia el umbral vigente")
	m.procesar_comando(IniciarMano.new())
	assert_eq(mesa._umbral.text, "24")
	assert_gt(mesa._umbral.scale.x, 1.0, "El número late al bajar")
	assert_string_contains(mesa._regla_texto.text, "bajó de 25 a 24")
	await get_tree().create_timer(1.1).timeout
	assert_eq(mesa._umbral.scale, Vector2.ONE)
	assert_eq(mesa._umbral.modulate, Color.WHITE)

func test_quiebra_no_baja_el_umbral_del_dueno() -> void:
	var mesa = _mesa(3, false)
	var m: ControladorMesa = mesa.controlador
	m.partida.mazo.clear()
	# Mano 1: 10 + 10 + 9 = 29 > 25, Quiebra. Después, cartas bajas.
	for valor in [10, 10, 9]: m.partida.mazo.append(FabricaCartas.crear_carta("velas", valor))
	for i in range(12): m.partida.mazo.append(FabricaCartas.crear_carta("llaves", 1 + i % 3))
	m.procesar_comando(IniciarMano.new())
	m.procesar_comando(PedirCarta.new())
	m.procesar_comando(Plantarse.new())
	assert_true(m.obtener_vista().ultima_mano.quiebra)
	assert_eq(m.obtener_vista().umbral_siguiente, 25)
	assert_eq(m.reglas_ayuda().umbral, 25, "El libro anuncia el mismo umbral")
	assert_string_contains(mesa._regla_texto.text, "La Quiebra no baja el umbral")
	m.procesar_comando(IniciarMano.new())
	assert_eq(m.partida.umbral, 25)
	assert_eq(mesa._umbral.scale, Vector2.ONE, "Sin cambio de umbral no hay aviso")
	assert_string_contains(mesa._regla_texto.text, "sigue en 25: tu última mano fue Quiebra")
	m.procesar_comando(Plantarse.new())
	m.procesar_comando(IniciarMano.new())
	assert_eq(m.partida.umbral, 24, "Una mano válida sí lo baja")

func test_movimiento_reducido_explica_sin_animar() -> void:
	var mesa = _mesa(3)
	var m: ControladorMesa = mesa.controlador
	_repartir_bajas(m)
	m.procesar_comando(IniciarMano.new())
	m.procesar_comando(Plantarse.new())
	m.procesar_comando(IniciarMano.new())
	assert_eq(mesa._umbral.scale, Vector2.ONE)
	assert_string_contains(mesa._regla_texto.text, "bajó de 25 a 24")
