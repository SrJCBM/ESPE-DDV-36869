extends GutTest
## I3-04: red de seguridad antes de reorganizar el código (I3-05).
## Las cartas nunca se duplican ni se pierden, el barajado es uniforme y una semilla reproduce el intento.

const PASOS_POR_MESA := 2500

## Mesa de campaña lista para jugar, con un reparto que depende solo de la semilla.
func _mesa(nivel: int, semilla: int) -> ControladorMesa:
	var c := CampanaCasino.new()
	c.recibir_invitacion()
	c.saldo = 40
	c.lentes = 2
	c.amuletos.assign(["corona", "prudente", "moneda"])
	c.superadas = nivel
	assert_true(c.iniciar(CampanaCasino.MESAS[nivel]))
	var m := ControladorMesa.new()
	m.configurar_campana(c)
	m.partida._rng.seed = semilla
	m.partida.mazo.assign(c.baraja)
	m.partida.descarte.clear()
	m.partida._barajar()
	return m

## Elige al azar entre las acciones legales que anuncia la vista pública.
func _accion_aleatoria(m: ControladorMesa, azar: RandomNumberGenerator) -> void:
	var v := m.obtener_vista()
	var opciones: Array[Callable] = []
	if v.acciones.iniciar: opciones.append(func() -> void: m.procesar_comando(IniciarMano.new()))
	if v.acciones.pedir: opciones.append(func() -> void: m.procesar_comando(PedirCarta.new()))
	if v.acciones.plantarse: opciones.append(func() -> void: m.procesar_comando(Plantarse.new()))
	for id: String in v.llaves_disponibles:
		opciones.append(func() -> void: m.procesar_comando(DevolverLlave.new(id)))
	if v.fase == "decision" and m.campana.lentes > 0: opciones.append(func() -> void: m.usar_lente())
	if opciones.is_empty(): return
	opciones[azar.randi_range(0, opciones.size() - 1)].call()

## Cada carta de la baraja del intento está exactamente en una zona.
func _comprobar_zonas(m: ControladorMesa, contexto: String) -> bool:
	var vistas := {}
	var total := 0
	for zona: Array in [m.partida.mazo, m.partida.mano, m.partida.descarte, m.partida.retenidas]:
		for carta: CartaEnPartida in zona:
			total += 1
			if vistas.has(carta.id_instancia):
				fail_test("%s: carta duplicada %s" % [contexto, carta.definicion.id])
				return false
			vistas[carta.id_instancia] = true
	if total != m.campana.baraja.size():
		fail_test("%s: %s cartas en zonas, %s en la baraja" % [contexto, total, m.campana.baraja.size()])
		return false
	for carta: CartaEnPartida in m.campana.baraja:
		if not vistas.has(carta.id_instancia):
			fail_test("%s: falta la carta %s" % [contexto, carta.definicion.id])
			return false
	return true

func test_las_cartas_nunca_se_duplican_ni_se_pierden_en_las_cuatro_mesas() -> void:
	var azar := RandomNumberGenerator.new()
	azar.seed = 36869
	var acciones := 0
	for nivel in range(4):
		var semilla := 0
		var m := _mesa(nivel, semilla)
		for paso in range(PASOS_POR_MESA):
			if m.obtener_vista().terminado:
				m.free()
				semilla += 1
				m = _mesa(nivel, semilla)
			_accion_aleatoria(m, azar)
			acciones += 1
			if not _comprobar_zonas(m, "%s, semilla %s, paso %s" % [CampanaCasino.MESAS[nivel], semilla, paso]):
				m.free()
				return
		m.free()
	assert_eq(acciones, PASOS_POR_MESA * 4)
	pass_test("%s acciones aleatorias sin duplicar ni perder cartas" % acciones)

func test_el_barajado_reparte_los_24_ordenes_de_4_cartas_por_igual() -> void:
	var estado := EstadoPartida.new(2026)
	var cartas: Array[CartaEnPartida] = []
	for valor in range(1, 5): cartas.append(FabricaCartas.crear_carta("velas", valor))
	var conteo := {}
	var tiradas := 24000
	for i in range(tiradas):
		estado.mazo.assign(cartas)
		estado._barajar()
		var clave := ""
		for carta in estado.mazo: clave += str(carta.definicion.valor_impreso)
		conteo[clave] = int(conteo.get(clave, 0)) + 1
	assert_eq(conteo.size(), 24, "Aparecen las 24 permutaciones")
	var esperado := tiradas / 24.0
	var chi := 0.0
	for clave in conteo: chi += pow(conteo[clave] - esperado, 2) / esperado
	# Con 23 grados de libertad, superar 41,64 tiene probabilidad 0,01 si el barajado es uniforme.
	assert_lt(chi, 41.64, "chi-cuadrado %.2f" % chi)
	gut.p("Chi-cuadrado del barajado: %.2f (umbral 41,64)" % chi)

## Huella del intento por definiciones: las identidades de instancia son aleatorias a propósito.
func _huella(m: ControladorMesa) -> String:
	var partes := PackedStringArray()
	for zona: Array in [m.partida.mazo, m.partida.mano, m.partida.descarte, m.partida.retenidas]:
		var ids := PackedStringArray()
		for carta: CartaEnPartida in zona: ids.append(carta.definicion.id)
		partes.append(",".join(ids))
	partes.append("puntos=%s campanadas=%s umbral=%s saldo=%s lentes=%s" % [m.partida.puntos, m.partida.campanadas, m.partida.umbral, m.campana.saldo, m.campana.lentes])
	return " | ".join(partes)

func _jugar(nivel: int, semilla: int, pasos: int) -> String:
	var azar := RandomNumberGenerator.new()
	azar.seed = semilla
	var m := _mesa(nivel, semilla)
	for i in range(pasos):
		if m.obtener_vista().terminado: break
		_accion_aleatoria(m, azar)
	var huella := _huella(m)
	m.free()
	return huella

func test_la_misma_semilla_y_las_mismas_acciones_reproducen_el_intento() -> void:
	for nivel in range(4):
		var a := _jugar(nivel, 7 + nivel, 300)
		assert_eq(a, _jugar(nivel, 7 + nivel, 300), "Mesa %s reproducible" % CampanaCasino.MESAS[nivel])
		assert_ne(a, _jugar(nivel, 1000 + nivel, 300), "Otra semilla da otro intento en %s" % CampanaCasino.MESAS[nivel])
