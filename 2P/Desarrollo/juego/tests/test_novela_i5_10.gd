extends GutTest
## I5-10: prólogo ilustrado antes del casino y conversaciones de novela visual con los
## crupieres y la anfitriona, a partir del guion v4.

const PROLOGO: Conversacion = preload("res://datos/dialogos/prologo.tres")

func after_each() -> void:
	await get_tree().process_frame

func _casino():
	var juego = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	return juego

## Avanza eligiendo siempre la primera respuesta, hasta que la escena se cierre.
func _recorrer(dialogo, maximo := 200) -> int:
	var pasos := 0
	while dialogo.visible and pasos < maximo:
		dialogo.completar()
		if dialogo.botones.is_empty():
			dialogo.avanzar()
		else:
			dialogo.elegir(0)
		pasos += 1
	return pasos

func test_los_dialogos_del_guion_no_tienen_referencias_rotas() -> void:
	for nombre in ["prologo", "anfitriona", "custodio", "recaudador", "coleccionista", "dueno",
			"amparo", "tobias", "benavides", "fb_campanario", "fb_deuda_muerto",
			"fb_habitacion_cristal", "fb_apuesta_alba", "derrota_v5"]:
		var conversacion: Conversacion = load("res://datos/dialogos/%s.tres" % nombre)
		assert_eq(conversacion.errores(), PackedStringArray(), nombre)

func test_el_recuerdo_de_cada_jefe_vuelve_a_las_preguntas_pendientes(indice = use_parameters([0, 1, 2, 3])) -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.campana.superadas = indice + 1
	var jefe: String = CampanaCasino.MESAS[indice]
	juego.entrar(jefe)
	juego._presentar_jefe()
	juego.dialogo.completar()
	juego.dialogo.avanzar()
	juego.dialogo.completar()
	assert_eq(juego.dialogo.botones.size(), 4, "Tres preguntas y una salida")
	var memoria := [0, 2, 0, 1]
	juego.dialogo.elegir(memoria[indice])
	juego.dialogo.completar()
	assert_eq(juego.dialogo.botones.size(), 2, "Abrir el recuerdo u otra pregunta")
	juego.dialogo.elegir(0)
	assert_true(juego.cinematica.activa)
	assert_not_null(juego.historia.fondo.texture, "El recuerdo tiene su ilustración")
	assert_lt(_recorrer(juego.historia, 20), 20)
	assert_eq(juego.dialogo.actual, "pos_fin_recuerdo")
	juego.dialogo.completar()
	juego.dialogo.avanzar()
	juego.dialogo.completar()
	assert_eq(juego.dialogo.botones.size(), 3)
	assert_eq(juego.sala, jefe)
	assert_true(juego.visitante.bloqueado)

func test_los_visitantes_conversan_y_la_porcelana_avanza_con_los_sellos() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	var encuentros := {"vestibulo": "amparo", "pasillo_custodio": "tobias", "pasillo_recaudador": "benavides"}
	for sala in encuentros:
		juego.campana.superadas = 1
		juego.entrar(sala)
		var id: String = encuentros[sala]
		var puntos: Array = juego.exploracion.puntos.filter(func(p): return p.destino == id)
		assert_eq(puntos.size(), 1)
		juego.visitante.position = puntos[0].pos
		juego.interactuar(juego.cercano())
		juego.dialogo.completar()
		assert_eq(juego.dialogo.actual, "saludo")
		assert_string_contains(juego.dialogo.conversacion.retrato("saludo"), id + "_neutral_p2")
		juego.dialogo.elegir(0)
		assert_eq(juego.dialogo.actual, "respuesta_1")
		juego.dialogo.cerrar()
		juego.campana.superadas = 3
		juego.interactuar(juego.cercano())
		assert_eq(juego.dialogo.actual, "porcelana")
		assert_string_contains(juego._pista(juego.cercano()), "Examinar")
		juego.dialogo.cerrar()

func test_las_intervenciones_largas_dejan_libre_la_barra_al_ciento_cuarenta_por_ciento() -> void:
	var novela = load("res://casino/dialogos/dialogo_novela.gd").new()
	add_child_autofree(novela)
	novela.configurar({"escala_texto": 1.4})
	var dueno: Conversacion = load("res://datos/dialogos/dueno.tres")
	for caso in [[PROLOGO, "p2_ventana"], [dueno, "respuesta_0_1"]]:
		novela.abrir(caso[0], func(_condicion): return true, true)
		novela._mostrar(caso[1])
		await get_tree().process_frame
		var etiqueta: Label = novela._activa()
		var fin := etiqueta.position.y + etiqueta.get_line_height() * etiqueta.get_line_count()
		assert_gte(etiqueta.get_line_count(), 3, caso[1])
		assert_lte(fin, novela.barra.position.y - 8, caso[1])
		novela.cerrar()

func test_el_prologo_se_recorre_entero_y_guarda_las_elecciones() -> void:
	var juego = _casino()
	juego.historia.reducido = true
	juego.iniciar_prologo()
	assert_true(juego.historia.visible)
	assert_true(juego.visitante.bloqueado, "Durante el prólogo no se camina")
	assert_false(juego.indicador_objetivo.visible, "El objetivo espera al final del prólogo")
	var pasos := _recorrer(juego.historia)
	assert_lt(pasos, 200, "El prólogo termina")
	assert_false(juego.historia.visible)
	assert_false(juego.visitante.bloqueado, "Al terminar, el jugador recupera el control")
	assert_eq(juego.sala, "entrada", "Aparece frente a la fachada")
	var h: Dictionary = juego.campana.historia
	assert_eq(h.get("motivo"), "taller")
	assert_eq(h.get("farolero"), "escucho")
	assert_true(h.has("quemo_invitacion"))
	assert_true(h.has("prologo_visto"))

func test_saltar_el_prologo_no_lo_marca_como_visto() -> void:
	var juego = _casino()
	juego.iniciar_prologo()
	juego.historia.saltar()
	assert_false(juego.historia.visible)
	assert_false(juego.visitante.bloqueado)
	assert_false(juego.campana.historia.has("prologo_visto"))

func test_esc_no_cierra_el_prologo() -> void:
	var juego = _casino()
	juego.iniciar_prologo()
	var tecla := InputEventKey.new()
	tecla.keycode = KEY_ESCAPE
	tecla.physical_keycode = KEY_ESCAPE
	tecla.pressed = true
	juego.get_viewport().push_input(tecla)
	assert_true(juego.historia.visible, "Solo «Saltar» deja la historia")
	assert_false(juego.menu.visible, "Ni abre la pausa")
	assert_true(juego.historia.boton_saltar.visible)

func test_una_ilustracion_pendiente_muestra_su_id_y_descripcion() -> void:
	var juego = _casino()
	juego.iniciar_prologo()
	var ruta := str(PROLOGO.fondo("sala_dueno_noche").get("ruta", ""))
	if ResourceLoader.exists(ruta):
		pass_test("La ilustración ya existe")
		return
	assert_true(juego.historia.pendiente.visible)
	assert_string_contains(juego.historia._texto_pendiente.text, "sala_dueno_noche")
	assert_false(juego.historia.fondo.visible, "Sin imágenes provisionales: se ve como pendiente")

func test_la_narracion_avanza_un_parrafo_por_clic_sobre_la_ilustracion() -> void:
	var juego = _casino()
	juego.iniciar_prologo()
	assert_eq(juego.historia.modo, "nvl")
	assert_true(juego.historia.franja.visible, "La narración va en la franja inferior")
	var primero: String = juego.historia.texto_nvl.text
	juego.historia.completar()
	juego.historia.avanzar()
	assert_false(juego.historia.texto_nvl.text.contains(primero), "El párrafo anterior no se acumula")
	assert_true(juego.historia.texto_nvl.position.y > 500, "El texto no ocupa la parte de arriba")
	for i in range(2):
		juego.historia.completar()
		juego.historia.avanzar()
	assert_eq(juego.historia.modo, "adv", "El diálogo con retrato usa el cuadro inferior")
	assert_eq(juego.historia.nombre.text, "Dueño de la Casa")

func test_los_efectos_no_se_aplican_con_movimiento_reducido() -> void:
	var juego = _casino()
	juego.iniciar_prologo()
	juego.historia.reducido = true
	juego.historia.aplicar_efecto("destello")
	juego.historia.aplicar_efecto("temblor_fuerte")
	assert_eq(juego.historia.destello.color.a, 0.0)
	assert_eq(juego.historia.escena.position, Vector2.ZERO)
	juego.historia.reducido = false
	juego.historia.aplicar_efecto("destello")
	assert_gt(juego.historia.destello.color.a, 0.5)
	assert_true(juego.historia.vineta.visible, "Las cinemáticas llevan viñeta")

func test_el_crupier_presenta_su_mesa_con_las_marcas_sustituidas() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.campana.superadas = 1
	juego.entrar("recaudador")
	juego._presentar_jefe()
	assert_true(juego.dialogo.visible)
	assert_eq(juego.dialogo.nombre.text, "El Recaudador")
	assert_string_contains(juego.dialogo.texto.text, "Moretti, Klein")
	juego.dialogo.completar()
	juego.dialogo.avanzar()
	assert_string_contains(juego.dialogo.texto.text, "Umbral 21, meta 400, 12 campanadas")

func test_preguntar_al_crupier_y_volver_a_la_mesa() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._presentar_jefe()
	for i in range(6):
		if not juego.dialogo.botones.is_empty(): break
		juego.dialogo.completar()
		juego.dialogo.avanzar()
	juego.dialogo.elegir(1)
	assert_eq(juego.dialogo.actual, "preguntas")
	var textos: Array = juego.dialogo.botones.map(func(b): return b.text)
	assert_false(textos.has("Conocí al farolero."), "Sin hablar con el farolero, esa pregunta no aparece")
	juego.dialogo.elegir(0)
	juego.dialogo.completar()
	juego.dialogo.avanzar()
	juego.dialogo.completar()
	juego.dialogo.elegir(juego.dialogo.botones.size() - 1)
	assert_eq(juego.dialogo.actual, "asiento_otra")
	juego.dialogo.completar()
	assert_eq(juego.dialogo.botones[0].text, "Tomar asiento")

func test_tras_vencerlo_el_crupier_ofrece_la_revisita_sin_cifras() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.campana.superadas = 1
	juego.entrar("custodio")
	juego._presentar_jefe()
	assert_eq(juego.dialogo.actual, "revisita")
	assert_null(juego.dialogo.get_node_or_null("CifrasMesa"), "La mesa cerrada no muestra cifras")

func test_la_victoria_trae_la_linea_del_crupier() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.meta = 1
	m.partida.mazo.clear()
	for datos in [["llaves", 2], ["velas", 3]]:
		m.partida.mazo.append(FabricaCartas.crear_carta(datos[0], datos[1]))
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	juego.mesa.boton_plantarse.pressed.emit()
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	juego.libro.primero.pressed.emit()
	assert_string_contains(juego.libro.cuerpo.text, "Has contado bien")

func test_la_historia_se_guarda_con_la_partida() -> void:
	var campana := CampanaCasino.new()
	campana.recibir_invitacion()
	assert_true(campana.atender("historia:motivo=ignacio"))
	assert_true(campana.atender("historia:garantia"))
	assert_true(campana.cumple("historia:motivo=ignacio"))
	assert_true(campana.cumple("historia:garantia"))
	assert_true(campana.cumple("no:historia:tono"))
	var copia := CampanaCasino.desde_datos(JSON.parse_string(JSON.stringify(campana.a_datos())))
	assert_eq(copia.historia, {"motivo": "ignacio", "garantia": "si"})

func test_la_anfitriona_saluda_segun_el_tono() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.campana.historia = {"vio_vestibulo": "si", "tono": "burlon"}
	juego.entrar("vestibulo")
	juego._recepcion()
	assert_eq(juego.dialogo.actual, "pista_0")
	assert_true(juego.dialogo.texto.text.begins_with("«¿Vienes a burlarte de otro reloj?"))

func test_la_cinematica_ocupa_su_propia_escena_y_devuelve_la_exploracion() -> void:
	var juego = _casino()
	juego.iniciar_prologo()
	assert_true(juego.cinematica.activa)
	assert_true(juego.cinematica.visible, "Escena opaca a pantalla completa")
	assert_false(juego.dialogo.visible, "No usa el diálogo de la sala")
	juego.historia.saltar()
	assert_false(juego.cinematica.activa)
	assert_false(juego.visitante.bloqueado)

func test_tras_la_llegada_se_abre_la_conversacion_con_la_anfitriona() -> void:
	var juego = _casino()
	juego.entrar("vestibulo")
	juego.reproducir_cinematica(load("res://datos/dialogos/llegada_vestibulo.tres"), juego._recepcion)
	assert_true(juego.cinematica.activa)
	_recorrer(juego.historia)
	assert_true(juego.campana.historia.has("vio_vestibulo"))
	assert_true(juego.dialogo.visible, "La cinemática da paso a la anfitriona")
	assert_eq(juego.dialogo.actual, "llegada")

func test_el_historial_guarda_las_lineas_con_su_hablante() -> void:
	var juego = _casino()
	juego.campana.historia = {"vio_vestibulo": "si", "tono": "cortes"}
	juego._recepcion()
	juego.dialogo.completar()
	juego.dialogo.elegir(1)
	juego._recepcion()
	assert_eq(juego.dialogo.historial.size(), 2)
	assert_eq(juego.dialogo.historial[0].nombre, "La anfitriona")
	juego.dialogo.abrir_historial()
	assert_true(juego.dialogo.panel_historial.visible)
	var tecla := InputEventKey.new()
	tecla.keycode = KEY_ESCAPE
	tecla.physical_keycode = KEY_ESCAPE
	tecla.pressed = true
	juego.get_viewport().push_input(tecla)
	assert_false(juego.dialogo.panel_historial.visible, "Esc cierra primero el historial")
	assert_true(juego.dialogo.visible, "y no la conversación")

func test_saltar_adelanta_hasta_la_proxima_eleccion() -> void:
	var juego = _casino()
	juego.iniciar_prologo()
	juego.historia.alternar_salto()
	for i in range(100):
		await get_tree().create_timer(0.1).timeout
		if not juego.historia.botones.is_empty(): break
	assert_eq(juego.historia.actual, "p2_que", "Se detiene en la primera elección del prólogo")
	assert_false(juego.historia.saltando)

func test_auto_avanza_solo() -> void:
	var juego = _casino()
	juego.iniciar_prologo()
	juego.historia.configurar({"velocidad": 0.0, "espera_auto": 0.05})
	juego.historia.alternar_auto()
	var inicio: String = juego.historia.actual
	await get_tree().create_timer(1.5).timeout
	assert_ne(juego.historia.actual, inicio)

func test_los_personajes_entran_salen_y_se_resalta_al_que_habla() -> void:
	var juego = _casino()
	var h = juego.historia
	h.reducido = true
	juego.iniciar_prologo()
	h.reducido = true
	for i in range(80):
		if h.actual == "p0a_1": break
		h.completar()
		h.avanzar()
	assert_true(h.presentes.has("dueno"), "El Dueño entra a la derecha")
	assert_true(h.presentes.has("ignacio"), "Ignacio entra a la izquierda")
	assert_eq(h.presentes.ignacio.texture.resource_path, "res://historia/retratos/ignacio_desesperado.webp")
	assert_eq(h.presentes.dueno.self_modulate, Color.WHITE, "El que habla queda iluminado")
	assert_null(h.retrato.texture, "Con personajes en escena no hay retrato grande")
	assert_false(h.cara.visible, "I6-08: quien habla está en escena; su figura y su nombre bastan")
	for i in range(80):
		if h.actual == "p0c_2": break
		h.completar()
		h.avanzar()
	assert_true(h.presentes.has("anfitriona"), "La anfitriona aparece en la oscuridad")
	h.completar()
	h.avanzar()
	assert_eq(h.presentes.anfitriona.self_modulate, h.ATENUADO, "Mientras el Dueño habla, ella queda atenuada")
	assert_eq(h.presentes.dueno.self_modulate, Color.WHITE)
	for i in range(10):
		if h.actual == "p1": break
		h.completar()
		h.avanzar()
	assert_true(h.presentes.is_empty(), "La tarjeta del capítulo vacía el escenario")

func test_examinar_abre_una_escena_con_la_ilustracion_y_la_descripcion() -> void:
	var juego = _casino()
	juego.entrar("vestibulo")
	juego.examinar()
	assert_true(juego.cinematica.activa, "Examinar abre una escena de novela visual")
	assert_true(juego.visitante.bloqueado)
	var h = juego.historia
	assert_eq(h.modo, "nvl")
	h.completar()
	assert_string_contains(h.texto_nvl.text, "El reloj detenido")
	assert_false(h.pendiente.visible, "La nota muestra el grabado del reloj")
	assert_eq(h.fondo_actual, "nota_vestibulo")
	h.avanzar()
	assert_false(juego.cinematica.activa)
	assert_false(juego.visitante.bloqueado, "Al cerrar se vuelve a explorar")

func test_cada_nota_jugable_tiene_una_ilustracion_importada() -> void:
	var Casino := load("res://casino/casino.gd")
	for sala: String in Casino.NOTAS:
		assert_true(Casino.ILUSTRACIONES_NOTAS.has("nota_" + sala), sala)
		assert_true(ResourceLoader.exists("res://historia/ilustraciones/nota_%s.webp" % sala, "Texture2D"), sala)
	for variante: String in Casino.NOTAS_VARIANTES:
		assert_true(Casino.ILUSTRACIONES_NOTAS.has("nota_" + variante), variante)
		assert_true(ResourceLoader.exists("res://historia/ilustraciones/nota_%s.webp" % variante, "Texture2D"), variante)
	var conversacion: Conversacion = Casino.conversacion_nota("nota_tienda", "La vitrina de humo", "Texto")
	assert_eq(conversacion.errores(), PackedStringArray())

func test_las_notas_cambian_segun_la_historia() -> void:
	var juego = _casino()
	juego.campana.historia["farolero"] = "pregunto_ignacio"
	juego.entrar("entrada")
	juego.examinar()
	juego.historia.completar()
	assert_string_contains(juego.historia.texto_nvl.text, "I. F.")
	assert_eq(juego.historia.fondo_actual, "nota_entrada_ignacio")
	juego.historia.avanzar()
	juego._entregar()
	juego._cerrar()
	juego.campana.superadas = 2
	juego.entrar("vestibulo")
	juego.examinar()
	juego.historia.completar()
	assert_string_contains(juego.historia.texto_nvl.text, "Hay 2 sellos")
