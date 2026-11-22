extends GutTest
## R01, R17 y R19: catálogo, zonas e independencia de los intentos.

func test_catalogo_real_contiene_los_24_valores_del_gdd() -> void:
	assert_true(ResourceLoader.exists("res://datos/cartas/baraja_inicial.tres"))
	var cartas := FabricaCartas.crear_baraja()
	assert_eq(cartas.size(), 24)
	var por_palo := {"velas": [], "llaves": [], "relojes": [], "mascaras": []}
	for carta in cartas:
		por_palo[carta.definicion.palo].append(carta.definicion.valor_impreso)
	for valores in por_palo.values():
		valores.sort()
	assert_eq(por_palo.velas, [1, 2, 4, 6, 8, 10])
	assert_eq(por_palo.llaves, [1, 2, 3, 4, 5, 9])
	assert_eq(por_palo.relojes, [1, 2, 4, 6, 7, 9])
	assert_eq(por_palo.mascaras, [1, 3, 5, 7, 8, 10])


func test_identidades_publicas_son_24_tokens_opacos_unicos() -> void:
	var ids := {}
	var formato := RegEx.new()
	formato.compile("^[0-9a-f]{32}$")
	for carta in FabricaCartas.crear_baraja():
		assert_not_null(formato.search(carta.id_instancia))
		assert_false(ids.has(carta.id_instancia))
		ids[carta.id_instancia] = true
	assert_eq(ids.size(), 24)


func test_fabrica_crea_identidad_aleatoria_o_respeta_identidad_preparada() -> void:
	var primera := FabricaCartas.crear_carta("mascaras", 8)
	var segunda := FabricaCartas.crear_carta("mascaras", 8)
	assert_ne(primera.id_instancia, "")
	assert_ne(primera.id_instancia, segunda.id_instancia)
	assert_eq(FabricaCartas.crear_carta("llaves", 4, "caso-r11").id_instancia, "caso-r11")


func test_modificar_un_intento_no_cambia_otro_ni_el_catalogo() -> void:
	var a := FabricaCartas.crear_baraja()
	var b := FabricaCartas.crear_baraja()
	assert_eq(a.size(), 24)
	if a.size() != 24 or b.size() != 24:
		return
	a[0].definicion.valor_impreso = 99
	a[0].definicion.palo = "alterado"
	assert_eq(b[0].definicion.valor_impreso, 1)
	assert_eq(b[0].definicion.palo, "velas")
	var nueva := FabricaCartas.crear_baraja()
	assert_eq(nueva[0].definicion.valor_impreso, 1)
	assert_eq(nueva[0].definicion.palo, "velas")


func test_semilla_repite_orden_sin_compartir_identidades_o_rng_global() -> void:
	var a := EstadoPartida.new(12345)
	seed(456)
	var b := EstadoPartida.new(12345)
	assert_eq(a.mazo.size(), 24)
	assert_eq(b.mazo.size(), 24)
	for i in mini(a.mazo.size(), b.mazo.size()):
		assert_eq(a.mazo[i].definicion.id, b.mazo[i].definicion.id)
		assert_ne(a.mazo[i].id_instancia, b.mazo[i].id_instancia)


func test_robar_extrae_sin_anadir_a_mano_y_conserva_24_cartas() -> void:
	var estado := EstadoPartida.new(7)
	for i in 24:
		var carta := estado.robar()
		assert_not_null(carta)
		if carta == null:
			return
		assert_eq(estado.mano.size(), i)
		estado.mano.append(carta)
		assert_eq(estado.mazo.size() + estado.mano.size() + estado.descarte.size(), 24)
	assert_eq(estado.disponibles(), 0)
	assert_null(estado.robar(), "No debe reciclar cartas retenidas en la mano")


func test_cerrar_y_reciclar_mantienen_las_cartas_sin_cobrar_o_puntuar() -> void:
	var estado := EstadoPartida.new(9)
	for i in 24:
		var carta := estado.robar()
		if carta != null:
			estado.mano.append(carta)
	assert_eq(estado.mano.size(), 24)
	if estado.mano.size() != 24:
		return
	var retenida: CartaEnPartida = estado.mano.pop_front()
	estado.puntos = 83
	estado.campanadas = 4
	estado.cerrar_mano()
	assert_eq(estado.mano.size(), 0)
	assert_eq(estado.descarte.size(), 23)
	assert_eq(estado.disponibles(), 23)
	assert_eq(estado.puntos, 83)
	assert_eq(estado.campanadas, 4)
	estado.mano.append(retenida)
	var ids := {}
	for i in 23:
		var carta := estado.robar()
		assert_not_null(carta)
		assert_ne(carta.id_instancia, retenida.id_instancia)
		assert_false(ids.has(carta.id_instancia))
		ids[carta.id_instancia] = true
	assert_eq(estado.descarte.size(), 0)
	assert_eq(estado.mazo.size(), 0)
	assert_null(estado.robar())


func test_reiniciar_restaura_todos_los_recursos_y_renueva_las_cartas() -> void:
	var estado := EstadoPartida.new(2)
	var ids_anteriores := {}
	for carta in estado.mazo:
		ids_anteriores[carta.id_instancia] = true
	var robada := estado.robar()
	if robada != null:
		estado.mano.append(robada)
	estado.campanadas = 0
	estado.puntos = 200
	estado.umbral = 25
	estado.meta = 800
	estado.llave_usada = true
	estado.reiniciar(2)
	assert_eq(estado.mazo.size(), 24)
	assert_eq(estado.mano.size(), 0)
	assert_eq(estado.descarte.size(), 0)
	assert_eq(estado.campanadas, 10)
	assert_eq(estado.puntos, 0)
	assert_eq(estado.umbral, 17)
	assert_eq(estado.meta, 200)
	assert_false(estado.llave_usada)
	for carta in estado.mazo:
		assert_false(ids_anteriores.has(carta.id_instancia))

func test_todas_las_cartas_del_catalogo_usan_un_palo_conocido() -> void:
	var catalogo: CatalogoCartas = load("res://datos/cartas/baraja_inicial.tres")
	for definicion: CartaDef in catalogo.cartas:
		assert_true(Palos.es_valido(definicion.palo), definicion.id)
	assert_eq(Palos.TODOS.size(), 4)
	assert_false(Palos.es_valido("vela"), "Una errata no es un palo")
