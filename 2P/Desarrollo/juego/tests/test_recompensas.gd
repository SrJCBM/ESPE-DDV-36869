extends GutTest

func test_ofertas_distintas_y_recompensa_unica_en_las_tres_mesas() -> void:
	var campana := CampanaCasino.new()
	campana.recibir_invitacion()
	campana.azar_recompensas.seed = 31
	for nivel in range(3):
		assert_true(campana.iniciar(CampanaCasino.MESAS[nivel]))
		campana.cerrar(true, 0)
		var opciones := campana.opciones_recompensa()
		assert_eq(opciones.size(), 3)
		var combinaciones := {}
		for opcion in opciones:
			assert_true(Palos.es_valido(opcion.palo))
			assert_between(opcion.valor, 1, 10)
			combinaciones[Vector2i(Palos.TODOS.find(opcion.palo), opcion.valor)] = true
		assert_eq(combinaciones.size(), 3)
		assert_false(campana.iniciar(CampanaCasino.MESAS[nivel + 1]))
		assert_false(campana.resolver_recompensa(3))
		assert_eq(campana.opciones_recompensa(), opciones)
		assert_true(campana.resolver_recompensa(1))
		assert_eq(campana.baraja.size(), 25 + nivel)
		assert_eq(campana.baraja.back().definicion.palo, opciones[1].palo)
		assert_eq(campana.baraja.back().definicion.valor_impreso, opciones[1].valor)
		assert_false(campana.resolver_recompensa(0))
	assert_true(campana.iniciar("dueno"))
	campana.cerrar(true, 0)
	assert_false(campana.hay_recompensa())
	assert_eq(campana.baraja.size(), 27)

func test_omitir_o_perder_no_agrega_cartas() -> void:
	var campana := CampanaCasino.new()
	campana.recibir_invitacion()
	campana.iniciar("custodio")
	campana.cerrar(true, 0)
	assert_true(campana.resolver_recompensa())
	campana.iniciar("recaudador")
	campana.cerrar(false, 0)
	assert_false(campana.hay_recompensa())
	assert_eq(campana.baraja.size(), 24)
