extends GutTest
## I5: partida guardada. Guardado automático entre encuentros, continuar desde el inicio,
## nunca a mitad de una mesa y borrado al perder. Las pruebas usan su propio archivo.

const RUTA_PRUEBA := "user://partida_prueba.json"
var _ruta_original := ""
var _ruta_ajustes := ""

func before_each() -> void:
	_ruta_original = PartidaGuardada.ruta
	_ruta_ajustes = AjustesJuego.ruta
	PartidaGuardada.ruta = RUTA_PRUEBA
	AjustesJuego.ruta = "user://ajustes_prueba_guardado.cfg"
	PartidaGuardada.borrar()

func after_each() -> void:
	PartidaGuardada.borrar()
	PartidaGuardada.ruta = _ruta_original
	DirAccess.remove_absolute(ProjectSettings.globalize_path(AjustesJuego.ruta))
	AjustesJuego.ruta = _ruta_ajustes
	await get_tree().process_frame

func _casino(con_guardado := true):
	var juego = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	juego.guardado_activo = con_guardado
	return juego

func _esc(juego) -> void:
	var tecla := InputEventKey.new()
	tecla.keycode = KEY_ESCAPE
	tecla.physical_keycode = KEY_ESCAPE
	tecla.pressed = true
	juego.get_viewport().push_input(tecla)

func _textos(juego) -> Array:
	return juego.menu.botones.map(func(b: Button) -> String: return b.text)

func _ids(c: CampanaCasino) -> Array:
	return c.baraja.map(func(carta: CartaEnPartida) -> String: return carta.id_instancia)

func _terminar_mano(juego, palos: Array, valores: Array) -> void:
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.mazo.clear()
	for i in palos.size(): m.partida.mazo.append(FabricaCartas.crear_carta(palos[i], valores[i]))
	m.procesar_comando(IniciarMano.new())
	m.procesar_comando(Plantarse.new())
	juego.mesa.boton_iniciar_pedir.pressed.emit()

# --- Datos de la campaña --------------------------------------------------------------

func test_la_campana_se_reconstruye_igual_tras_pasar_por_json() -> void:
	var c := CampanaCasino.new()
	c.atender("objeto_inicial:moneda")
	c.saldo = 100
	c.azar_recompensas.seed = 5
	assert_true(c.comprar("subir", c.baraja[0]))
	assert_true(c.comprar("eliminar", c.baraja[1]))
	assert_true(c.comprar("lente"))
	c.iniciar("custodio")
	c.cerrar(true, 1)
	assert_true(c.hay_recompensa())
	var datos = JSON.parse_string(JSON.stringify(c.a_datos()))
	var copia := CampanaCasino.desde_datos(datos)
	assert_eq(copia.a_datos(), c.a_datos())
	assert_eq(_ids(copia), _ids(c), "Las cartas conservan su identidad: ajustes y ganadas siguen ligados a ellas")
	assert_eq(copia.opciones_recompensa(), c.opciones_recompensa(), "La recompensa pendiente se conserva")
	assert_eq([copia.saldo, copia.superadas, copia.lentes], [c.saldo, c.superadas, c.lentes])

func test_los_datos_invalidos_se_descartan_sin_fallar() -> void:
	var copia := CampanaCasino.desde_datos({
		"recibida": true, "saldo": -5, "superadas": 9, "lentes": 7,
		"amuletos": ["moneda", "trampa", "moneda", "lente"],
		"baraja": [{"palo": "velas", "valor": 3}, {"palo": "oros", "valor": 3}, {"palo": "llaves", "valor": 0}, "carta"],
		"ajustadas": {"x": 5}, "recompensas": [{"palo": "relojes", "valor": 11}],
	})
	assert_eq(copia.saldo, 0)
	assert_eq(copia.superadas, 4)
	assert_eq(copia.lentes, 2)
	assert_eq(copia.amuletos, ["moneda"] as Array[String])
	assert_eq(copia.baraja.size(), 1)
	assert_eq(copia.ajustadas["x"], 1)
	assert_false(copia.hay_recompensa())

# --- Archivo ----------------------------------------------------------------------------

func test_el_archivo_se_guarda_se_lee_y_se_borra() -> void:
	assert_false(PartidaGuardada.existe())
	assert_true(PartidaGuardada.guardar({"campana": {"recibida": true}, "sala": "vestibulo"}))
	var datos := PartidaGuardada.cargar()
	assert_eq(datos.sala, "vestibulo")
	assert_eq(int(datos.version), PartidaGuardada.VERSION)
	assert_false(FileAccess.file_exists(RUTA_PRUEBA + ".tmp"), "No queda el temporal")
	PartidaGuardada.borrar()
	assert_false(PartidaGuardada.existe())

func test_un_archivo_danado_o_de_otra_version_no_se_carga() -> void:
	var archivo := FileAccess.open(RUTA_PRUEBA, FileAccess.WRITE)
	archivo.store_string("{ esto no es json")
	archivo.close()
	assert_eq(PartidaGuardada.cargar(), {})
	archivo = FileAccess.open(RUTA_PRUEBA, FileAccess.WRITE)
	archivo.store_string(JSON.stringify({"version": 99, "campana": {}}))
	archivo.close()
	assert_eq(PartidaGuardada.cargar(), {})

# --- Guardado automático ----------------------------------------------------------------

func test_sin_guardado_activo_el_casino_no_escribe_nada() -> void:
	var juego = _casino(false)
	juego._entregar()
	juego.entrar("pasillo_custodio", "vestibulo")
	assert_false(FileAccess.file_exists(RUTA_PRUEBA), "Las pruebas y escenas sueltas no tocan la partida de quien juega")

func test_antes_de_la_invitacion_no_hay_nada_que_guardar() -> void:
	var juego = _casino()
	juego.entrar("vestibulo", "entrada")
	assert_false(PartidaGuardada.existe())

func test_moverse_y_comprar_guardan_y_continuar_lo_restaura() -> void:
	var juego = _casino()
	juego._entregar()
	assert_true(PartidaGuardada.existe(), "Recibir la invitación guarda")
	juego.campana.superadas = 1
	juego.entrar("pasillo_custodio", "vestibulo")
	juego.entrar("tienda", "pasillo_recaudador")
	juego.campana.saldo = 30
	assert_true(juego.campana.comprar("lente"))
	juego._refrescar()
	var ids := _ids(juego.campana)
	var otro = _casino()
	assert_true(otro.continuar())
	assert_eq(otro.sala, "tienda")
	assert_eq([otro.campana.saldo, otro.campana.superadas, otro.campana.lentes], [24, 1, 1])
	assert_eq(_ids(otro.campana), ids)
	assert_true(otro.campana.recibida)

func test_continuar_respeta_la_posicion_del_visitante() -> void:
	var juego = _casino()
	juego._entregar()
	juego.entrar("pasillo_custodio", "vestibulo")
	juego.visitante.position = Vector2(400, 420)
	juego.pausar()
	var otro = _casino()
	otro.continuar()
	assert_eq(otro.visitante.position, Vector2(400, 420))

func test_cerrar_a_mitad_de_una_mesa_vuelve_frente_al_crupier_como_al_sentarse() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.campana.superadas = 1
	juego.campana.saldo = 10
	juego.entrar("recaudador", "pasillo_recaudador")
	juego._jugar()
	assert_eq(juego.campana.saldo, 25, "El Recaudador entrega 15 fichas al sentarse")
	juego.mesa.controlador.procesar_comando(IniciarMano.new())
	juego._refrescar()
	var otro = _casino()
	otro.continuar()
	assert_eq(otro.sala, "recaudador")
	assert_eq(otro.campana.activa, "", "Ninguna mesa en curso")
	assert_eq(otro.campana.saldo, 10, "Lo que tenía al sentarse: sin las 15 fichas de cortesía")
	assert_false(is_instance_valid(otro.mesa))

func test_perder_borra_la_partida() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._jugar()
	juego.mesa.controlador.partida.campanadas = 1
	_terminar_mano(juego, ["llaves", "velas"], [9, 10])
	assert_true(juego.campana.derrota)
	assert_false(PartidaGuardada.existe(), "La derrota termina el intento")

func test_una_recompensa_pendiente_se_vuelve_a_ofrecer() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._jugar()
	juego.mesa.controlador.partida.meta = 1
	_terminar_mano(juego, ["llaves", "velas"], [2, 3])
	assert_true(juego.campana.hay_recompensa())
	var opciones: Array = juego.campana.opciones_recompensa()
	var otro = _casino()
	otro.continuar()
	assert_eq(otro.campana.superadas, 1)
	assert_eq(otro.campana.opciones_recompensa(), opciones)
	assert_true(otro.recompensa.visible, "La oferta vuelve a abrirse")
	otro.recompensa.cartas[1].pressed.emit()
	otro.recompensa.boton_confirmar.pressed.emit()
	assert_false(otro.campana.hay_recompensa())
	assert_eq(otro.campana.baraja.size(), 25)

# --- Menú de inicio -------------------------------------------------------------------

func test_sin_partida_el_inicio_ofrece_entrar() -> void:
	var juego = _casino()
	juego.abrir_inicio()
	assert_eq(_textos(juego), ["Entrar al casino", "Cómo jugar", "Opciones", "Créditos", "Salir"])

func test_con_partida_el_inicio_ofrece_continuar_y_nueva_partida() -> void:
	var juego = _casino()
	juego._entregar()
	juego.campana.saldo = 42
	juego._refrescar()
	var otro = _casino()
	otro.abrir_inicio()
	assert_eq(_textos(otro), ["Continuar", "Nueva partida", "Cómo jugar", "Opciones", "Créditos", "Salir"])
	assert_eq(otro.get_viewport().gui_get_focus_owner(), otro.menu.botones[0], "Continuar viene enfocado")
	otro.menu.botones[0].pressed.emit()
	assert_false(otro.menu.visible)
	assert_eq(otro.campana.saldo, 42)
	assert_eq(otro.pagina.process_mode, Node.PROCESS_MODE_INHERIT)

func test_nueva_partida_pide_confirmacion_y_borra_la_anterior() -> void:
	var juego = _casino()
	juego._entregar()
	var otro = _casino()
	otro.abrir_inicio()
	otro.menu.botones[1].pressed.emit()
	assert_eq(otro.menu.pantalla, "confirmar_nueva")
	_esc(otro)
	assert_eq(otro.menu.pantalla, "inicio", "Esc cancela")
	assert_true(PartidaGuardada.existe())
	otro.menu.botones[1].pressed.emit()
	assert_eq(_textos(otro), ["Cancelar", "Empezar de nuevo"])
	otro.menu.botones[1].pressed.emit()
	assert_false(otro.menu.visible)
	assert_false(PartidaGuardada.existe())
	assert_false(otro.campana.recibida)
	assert_eq(otro.sala, "entrada")

func test_volver_al_inicio_explorando_guarda_sin_pedir_confirmacion() -> void:
	var juego = _casino()
	juego._entregar()
	juego.campana.saldo = 17
	juego.pausar()
	juego.menu.botones[4].pressed.emit()
	assert_eq(juego.menu.pantalla, "inicio", "Explorando no se pierde nada")
	assert_eq(_textos(juego)[0], "Continuar")
	juego.menu.botones[0].pressed.emit()
	assert_eq(juego.campana.saldo, 17)

func test_volver_al_inicio_desde_una_mesa_avisa_de_la_mano_en_curso() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._jugar()
	juego.pausar()
	juego.menu.botones[4].pressed.emit()
	assert_eq(juego.menu.pantalla, "confirmar")
	var textos := PackedStringArray()
	for hijo in juego.menu._contenido.get_children():
		if hijo is Label: textos.append(hijo.text)
	assert_string_contains("\n".join(textos), "volverás frente al crupier")
	juego.menu.botones[1].pressed.emit()
	assert_false(is_instance_valid(juego.mesa))
	juego.menu.botones[0].pressed.emit()
	assert_eq(juego.sala, "custodio")
	assert_eq(juego.campana.activa, "")
