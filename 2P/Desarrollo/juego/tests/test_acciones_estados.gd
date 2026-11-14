extends GutTest

func _crear() -> ControladorMesa:
	var controlador := ControladorMesa.new()
	add_child_autofree(controlador)
	return controlador

func _comprobar_reinicio_final(victoria: bool) -> void:
	var c := _crear()
	c.cargar_demostracion()
	for robos in ([1, 1, 2] if victoria else [1]):
		c.procesar_comando(IniciarMano.new())
		for i in range(robos): c.procesar_comando(PedirCarta.new())
		if not victoria: c.partida.campanadas = 0
		c.procesar_comando(Plantarse.new())
	assert_true(c.obtener_vista().terminado)
	assert_eq(c.obtener_vista().victoria, victoria)
	c.reiniciar(34)
	assert_eq(c.estado_activo.nombre, "preparado")
	assert_eq(c.partida.mazo.size(), 24)
	assert_eq(c.partida.puntos, 0)
	assert_eq(c.partida.campanadas, 10)
	assert_false(c.obtener_vista().terminado)
	assert_false(c.obtener_vista().modo_demostracion)
	assert_true(c.obtener_vista().ultima_mano.is_empty())
	assert_true(c.procesar_comando(IniciarMano.new()).aceptado)
	assert_eq(c.partida.campanadas, 9)

func test_R18_reiniciar_desde_victoria_permite_otro_intento() -> void:
	_comprobar_reinicio_final(true)

func test_R18_reiniciar_desde_derrota_permite_otro_intento() -> void:
	_comprobar_reinicio_final(false)

func _ordenar(c: ControladorMesa, ids: Array) -> void:
	var orden: Array[CartaEnPartida] = []
	for id: String in ids:
		for carta: CartaEnPartida in c.partida.mazo:
			if carta.definicion.id == id:
				orden.append(carta)
	for carta: CartaEnPartida in c.partida.mazo:
		if not orden.has(carta):
			orden.append(carta)
	c.partida.mazo = orden

func _iniciar(c: ControladorMesa) -> bool:
	var resultado := c.procesar_comando(IniciarMano.new())
	assert_true(resultado.aceptado, resultado.motivo)
	return resultado.aceptado

func _instantanea_interna(c: ControladorMesa) -> Dictionary:
	var zonas: Array = []
	for zona in [c.partida.mazo, c.partida.mano, c.partida.descarte]:
		var ids: Array = []
		for carta: CartaEnPartida in zona: ids.append(carta.id_instancia)
		zonas.append(ids)
	return {"zonas": zonas, "rng": c.partida._rng.state, "llave": c.partida.llave_usada}

func _rechazo_sin_cambio(c: ControladorMesa, comando: ComandoMesa) -> void:
	var antes := c.obtener_vista().duplicate(true)
	var interno := _instantanea_interna(c)
	var resultado := c.procesar_comando(comando)
	assert_false(resultado.aceptado)
	assert_false(resultado.motivo.is_empty())
	assert_eq(c.obtener_vista(), antes, "Una acción rechazada no cambia la vista")
	assert_eq(_instantanea_interna(c), interno, "No cambia zonas, orden ni RNG")

func test_R02_iniciar_reparte_dos_y_cobra_una() -> void:
	var c := _crear()
	c.cargar_demostracion()
	if not _iniciar(c): return
	assert_eq(c.partida.mano.size(), 2)
	assert_eq(c.partida.campanadas, 9)
	assert_eq(c.estado_activo.nombre, "decision")
	assert_eq(c.partida.mazo.size(), 22)

func test_R03_pedir_cobra_una_incluido_reloj() -> void:
	var c := _crear()
	_ordenar(c, ["llaves_01", "velas_02", "relojes_06"])
	if not _iniciar(c): return
	assert_true(c.procesar_comando(PedirCarta.new()).aceptado)
	assert_eq(c.partida.campanadas, 8)
	assert_eq(c.partida.mano.size(), 3)
	assert_eq(c.partida.mano[-1].valor_efectivo(), 5)

func test_R04_R05_plantarse_gratis_y_no_puede_resolver_dos_veces() -> void:
	var c := _crear()
	c.cargar_demostracion()
	if not _iniciar(c): return
	c.procesar_comando(PedirCarta.new())
	assert_true(c.procesar_comando(Plantarse.new()).aceptado)
	assert_eq(c.partida.campanadas, 8)
	assert_eq(c.partida.puntos, 102)
	assert_eq(c.partida.mano.size(), 0)
	assert_eq(c.partida.descarte.size(), 3)
	_rechazo_sin_cambio(c, Plantarse.new())

func test_R04_sin_campanadas_rechaza_pedir_pero_permite_plantarse() -> void:
	var c := _crear()
	c.cargar_demostracion()
	if not _iniciar(c): return
	c.partida.campanadas = 0
	_rechazo_sin_cambio(c, PedirCarta.new())
	assert_true(c.procesar_comando(Plantarse.new()).aceptado)
	assert_eq(c.estado_activo.nombre, "finalizada")

func test_iniciar_sin_recursos_o_sin_dos_cartas_no_muta() -> void:
	var c := _crear()
	c.partida.campanadas = 0
	_rechazo_sin_cambio(c, IniciarMano.new())
	c.partida.campanadas = 10
	while c.partida.mazo.size() > 1:
		c.partida.mano.append(c.partida.mazo.pop_back())
	_rechazo_sin_cambio(c, IniciarMano.new())

func test_R07_llave_inicial_reemplazo_al_final_gratis_y_unico() -> void:
	var c := _crear()
	_ordenar(c, ["llaves_04", "velas_02", "llaves_03"])
	if not _iniciar(c): return
	var devuelta := c.partida.mano[0]
	assert_true(c.procesar_comando(DevolverLlave.new(devuelta.id_instancia)).aceptado)
	assert_eq(c.partida.mano[0].definicion.id, "velas_02")
	assert_eq(c.partida.mano[-1].definicion.id, "llaves_03")
	assert_same(c.partida.mazo[-1], devuelta)
	assert_eq(c.partida.campanadas, 9)
	assert_true(c.partida.llave_usada)
	_rechazo_sin_cambio(c, DevolverLlave.new(c.partida.mano[-1].id_instancia))
	assert_eq(c.partida.mazo.size() + c.partida.mano.size() + c.partida.descarte.size(), 24)

func test_R07_solo_llave_recien_pedida_tras_otra_accion() -> void:
	var c := _crear()
	_ordenar(c, ["llaves_01", "velas_02", "llaves_03", "relojes_01"])
	if not _iniciar(c): return
	var inicial := c.partida.mano[0].id_instancia
	c.procesar_comando(PedirCarta.new())
	_rechazo_sin_cambio(c, DevolverLlave.new(inicial))
	assert_true(c.procesar_comando(DevolverLlave.new(c.partida.mano[-1].id_instancia)).aceptado)
	assert_eq(c.partida.mano[-1].definicion.id, "relojes_01")
	assert_eq(c.partida.campanadas, 8)

func test_R07_se_puede_conservar_uso_para_una_llave_posterior() -> void:
	var c := _crear()
	_ordenar(c, ["llaves_01", "velas_02", "relojes_01", "llaves_03", "velas_01"])
	if not _iniciar(c): return
	c.procesar_comando(PedirCarta.new())
	assert_false(c.partida.llave_usada)
	assert_true(c.obtener_vista().get("llaves_disponibles", []).is_empty())
	c.procesar_comando(PedirCarta.new())
	assert_true(c.procesar_comando(DevolverLlave.new(c.partida.mano[-1].id_instancia)).aceptado)
	assert_eq(c.partida.campanadas, 7)

func test_R08_no_puede_reemplazarse_por_si_misma() -> void:
	var c := _crear()
	_ordenar(c, ["llaves_01", "velas_02"])
	if not _iniciar(c): return
	# Las demás cartas se mantienen en mano: no existe otra zona disponible.
	while not c.partida.mazo.is_empty():
		c.partida.mano.append(c.partida.mazo.pop_front())
	_rechazo_sin_cambio(c, DevolverLlave.new(c.partida.mano[0].id_instancia))

func test_R10_ofrece_devolucion_antes_de_confirmar_quiebra() -> void:
	var c := _crear()
	_ordenar(c, ["velas_08", "relojes_06", "llaves_09", "relojes_01"])
	if not _iniciar(c): return
	c.procesar_comando(PedirCarta.new())
	assert_eq(c.estado_activo.nombre, "decision")
	assert_true(c.obtener_vista().get("acciones", {}).get("devolver", false))
	_rechazo_sin_cambio(c, PedirCarta.new())
	assert_true(c.procesar_comando(DevolverLlave.new(c.partida.mano[-1].id_instancia)).aceptado)
	assert_eq(c.estado_activo.nombre, "decision")
	assert_eq(c.partida.campanadas, 8)
	assert_true(c.procesar_comando(Plantarse.new()).aceptado)
	assert_false(c.obtener_vista().get("ultima_mano", {}).get("quiebra", true))

func test_R10_quiebra_demostrable_sin_llave_resuelve_sola() -> void:
	var c := _crear()
	_ordenar(c, ["velas_10", "relojes_09"])
	if not _iniciar(c): return
	assert_eq(c.estado_activo.nombre, "preparado")
	assert_eq(c.partida.puntos, 0)
	assert_true(c.obtener_vista().get("ultima_mano", {}).get("quiebra", false))
	_rechazo_sin_cambio(c, Plantarse.new())

func test_R15_ejemplo_completo_221_puntos_y_tres_campanadas() -> void:
	var c := _crear()
	c.cargar_demostracion()
	if not _iniciar(c): return
	c.procesar_comando(PedirCarta.new())
	c.procesar_comando(Plantarse.new())
	assert_eq(c.partida.puntos, 102)
	if not _iniciar(c): return
	c.procesar_comando(PedirCarta.new())
	c.procesar_comando(Plantarse.new())
	assert_eq(c.partida.puntos, 102)
	assert_true(c.obtener_vista().ultima_mano.quiebra)
	if not _iniciar(c): return
	c.procesar_comando(PedirCarta.new())
	c.procesar_comando(PedirCarta.new())
	c.procesar_comando(Plantarse.new())
	assert_eq(c.partida.puntos, 221)
	assert_eq(c.partida.campanadas, 3)
	assert_true(c.obtener_vista().get("victoria", false))
	assert_eq(c.estado_activo.nombre, "finalizada")
	assert_eq(c.partida.descarte.size() + c.partida.mazo.size(), 24)

func test_R16_la_meta_se_comprueba_antes_de_derrota_con_cero() -> void:
	var c := _crear()
	c.cargar_demostracion()
	if not _iniciar(c): return
	c.procesar_comando(PedirCarta.new())
	c.partida.puntos = 98
	c.partida.campanadas = 0
	assert_true(c.procesar_comando(Plantarse.new()).aceptado)
	assert_eq(c.partida.puntos, 200)
	assert_true(c.obtener_vista().get("victoria", false))
	_rechazo_sin_cambio(c, IniciarMano.new())

func test_R16_derrota_cero_oportunidades_y_puntos_insuficientes() -> void:
	var c := _crear()
	c.cargar_demostracion()
	if not _iniciar(c): return
	c.partida.campanadas = 0
	c.procesar_comando(Plantarse.new())
	assert_true(c.obtener_vista().get("terminado", false))
	assert_false(c.obtener_vista().get("victoria", true))
	_rechazo_sin_cambio(c, PedirCarta.new())

func test_R17_sin_cartas_pedir_rechaza_y_plantarse_sigue_disponible() -> void:
	var c := _crear()
	c.cargar_demostracion()
	if not _iniciar(c): return
	c.partida.mazo.clear()
	c.partida.descarte.clear()
	_rechazo_sin_cambio(c, PedirCarta.new())
	assert_true(c.obtener_vista().get("acciones", {}).get("plantarse", false))

func test_R18_reiniciar_restaurar_sin_duplicar_eventos() -> void:
	var c := _crear()
	var eventos: Array = []
	c.vista_actualizada.connect(func(vista: Dictionary): eventos.append(vista))
	for i in range(5): c.reiniciar(23)
	assert_eq(eventos.size(), 5)
	if not _iniciar(c): return
	assert_eq(eventos.size(), 6)
	c.procesar_comando(Plantarse.new())
	c.reiniciar(23)
	assert_eq(c.partida.mazo.size(), 24)
	assert_eq(c.partida.mano.size(), 0)
	assert_eq(c.partida.descarte.size(), 0)
	assert_eq(c.partida.campanadas, 10)
	assert_eq(c.partida.puntos, 0)
	assert_false(c.partida.llave_usada)

func test_R20_sin_actuar_los_frames_no_consumen_recursos() -> void:
	var c := _crear()
	var antes := c.obtener_vista().duplicate(true)
	var limite_anterior := Engine.max_fps
	for limite in [30, 144]:
		Engine.max_fps = limite
		for i in range(4): await get_tree().process_frame
		assert_eq(c.obtener_vista(), antes)
	Engine.max_fps = limite_anterior

func test_evento_unico_por_accion_y_rechazos_sin_evento() -> void:
	var c := _crear()
	c.cargar_demostracion()
	var vistas: Array = []
	var finales: Array = []
	c.vista_actualizada.connect(func(v: Dictionary): vistas.append(v))
	c.encuentro_finalizado.connect(func(v: bool): finales.append(v))
	_rechazo_sin_cambio(c, PedirCarta.new())
	assert_eq(vistas.size(), 0)
	if not _iniciar(c): return
	assert_eq(vistas.size(), 1)
	c.partida.campanadas = 0
	c.procesar_comando(Plantarse.new())
	assert_eq(vistas.size(), 2)
	assert_eq(finales.size(), 1)
	_rechazo_sin_cambio(c, Plantarse.new())
	assert_eq(finales.size(), 1)

func test_senal_no_reintroduce_comandos_durante_aceptacion() -> void:
	var c := _crear()
	c.cargar_demostracion()
	var reentrantes: Array = []
	c.vista_actualizada.connect(func(_v: Dictionary): reentrantes.append(c.procesar_comando(PedirCarta.new()).aceptado))
	if not _iniciar(c): return
	assert_eq(reentrantes, [false])
	assert_eq(c.partida.campanadas, 9)

func test_reset_y_demo_no_aceptan_comandos_durante_su_notificacion() -> void:
	for metodo in ["reiniciar", "cargar_demostracion"]:
		var c := _crear()
		var anidadas: Array = []
		c.vista_actualizada.connect(func(v: Dictionary):
			if v.numero_mano == 0:
				anidadas.append(c.procesar_comando(IniciarMano.new()).aceptado)
		)
		c.call(metodo)
		assert_eq(anidadas, [false], metodo)
		assert_eq(c.partida.campanadas, 10)
		assert_eq(c.partida.mano.size(), 0)

func test_reset_reentrante_no_duplica_notificaciones() -> void:
	var c := _crear()
	var notificaciones: Array = []
	c.vista_actualizada.connect(func(v: Dictionary):
		notificaciones.append(v)
		if notificaciones.size() == 1:
			c.reiniciar(99)
	)
	c.reiniciar(23)
	assert_eq(notificaciones.size(), 1)

func test_R07_se_puede_elegir_la_segunda_llave_inicial() -> void:
	var c := _crear()
	_ordenar(c, ["llaves_01", "llaves_02", "velas_01"])
	if not _iniciar(c): return
	var primera := c.partida.mano[0].id_instancia
	var segunda := c.partida.mano[1].id_instancia
	assert_eq(c.obtener_vista().llaves_disponibles.size(), 2)
	assert_true(c.procesar_comando(DevolverLlave.new(segunda)).aceptado)
	assert_eq(c.partida.mano[0].id_instancia, primera)
	assert_eq(c.partida.mazo[-1].id_instancia, segunda)
	assert_eq(c.partida.campanadas, 9)

func test_R07_devolver_recicla_descarte_sin_usar_la_propia_llave() -> void:
	var c := _crear()
	_ordenar(c, ["llaves_01", "velas_02"])
	if not _iniciar(c): return
	var devuelta := c.partida.mano[0].id_instancia
	c.partida.descarte.append_array(c.partida.mazo)
	c.partida.mazo.clear()
	assert_true(c.procesar_comando(DevolverLlave.new(devuelta)).aceptado)
	assert_ne(c.partida.mano[-1].id_instancia, devuelta)
	assert_eq(c.partida.mazo[-1].id_instancia, devuelta)
	assert_eq(c.partida.mazo.size() + c.partida.mano.size() + c.partida.descarte.size(), 24)
	assert_eq(c.partida.campanadas, 9)
