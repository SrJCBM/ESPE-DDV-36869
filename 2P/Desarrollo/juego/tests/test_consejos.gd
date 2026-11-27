extends GutTest
## Tutorial en contexto (26 nov 2026): frases cortas, una vez cada una, en el momento en que
## hacen falta y señalando su sitio. Se apagan en Opciones y pueden repetirse.

var _ruta_original := ""

func before_each() -> void:
	_ruta_original = AjustesJuego.ruta
	AjustesJuego.ruta = "user://ajustes_prueba_consejos.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(AjustesJuego.ruta))

func after_each() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(AjustesJuego.ruta))
	AjustesJuego.ruta = _ruta_original
	await get_tree().process_frame

func _casino():
	var juego = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	juego.guardado_activo = false
	juego._entregar()
	juego._cerrar()
	return juego

func _sentar(juego, jefe := "custodio") -> void:
	juego.campana.superadas = CampanaCasino.MESAS.find(jefe)
	juego.entrar(jefe)
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	juego.mesa.establecer_movimiento_reducido(true)

func _mazo(juego, cartas: Array) -> void:
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.mazo.clear()
	for d in cartas:
		m.partida.mazo.append(FabricaCartas.crear_carta(d[0], d[1]))

func _dentro(globo: GloboConsejo) -> bool:
	return Rect2(Vector2.ZERO, GloboConsejo.LIENZO).encloses(globo._caja)

func test_cada_frase_es_corta() -> void:
	for id in Consejos.TEXTOS:
		var palabras: int = Consejos.TEXTOS[id].split(" ", false).size()
		assert_lte(palabras, 8, "«%s» tiene %s palabras" % [Consejos.TEXTOS[id], palabras])

func test_orden_y_una_vez() -> void:
	var preparado := {"fase": "preparado", "cartas": [], "campanadas": 9}
	assert_eq(Consejos.en_mesa({}, preparado, []), "umbral")
	assert_eq(Consejos.en_mesa({}, preparado, ["umbral"]), "")
	var decision := {"fase": "decision", "cartas": [{}, {}], "campanadas": 8, "llaves_disponibles": ["a"], "intervalo": {"ocultas": 1}}
	assert_eq(Consejos.en_mesa(preparado, decision, ["umbral"]), "pedir", "Lo básico primero")
	assert_eq(Consejos.en_mesa(preparado, decision, ["umbral", "pedir"]), "llave")
	assert_eq(Consejos.en_mesa(preparado, decision, ["umbral", "pedir", "llave"]), "mascara")
	var quiebra := {"fase": "resuelta", "cartas": [{}, {}, {}], "campanadas": 2, "ultima_mano": {"quiebra": true, "patrones": []}}
	assert_eq(Consejos.en_mesa(decision, quiebra, []), "quiebra", "Lo que acaba de pasar va antes")
	assert_eq(Consejos.en_mesa(decision, quiebra, ["quiebra"]), "campanadas")
	var patron := {"fase": "resuelta", "cartas": [{}, {}], "campanadas": 7, "ultima_mano": {"quiebra": false, "patrones": ["Punto exacto"]}}
	assert_eq(Consejos.en_mesa(decision, patron, []), "patron")
	var fin := patron.duplicate()
	fin.terminado = true
	assert_eq(Consejos.en_mesa(decision, fin, []), "", "Nada sobre el final del intento")

func test_la_primera_mesa_ensena_el_umbral_y_luego_los_botones() -> void:
	var juego = _casino()
	_sentar(juego)
	var globo: GloboConsejo = juego.mesa.globo
	assert_true(globo.visible, "Al sentarse, un consejo")
	assert_eq(globo.id, "umbral")
	assert_eq(globo.texto.text, Consejos.TEXTOS.umbral)
	assert_true(_dentro(globo), "El globo cabe en la pantalla")
	assert_eq(globo.mouse_filter, Control.MOUSE_FILTER_IGNORE, "No bloquea el ratón")
	_mazo(juego, [["velas", 5], ["relojes", 6], ["velas", 2]])
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	assert_eq(globo.id, "pedir", "Al repartir, cómo pedir o plantarse")
	assert_true(globo.anillo.get_rect().intersects(juego.mesa._rect_en_lienzo(juego.mesa.boton_iniciar_pedir)), "y rodea los botones")
	assert_true(_dentro(globo))
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	assert_ne(globo.id, "pedir", "Actuar lo retira")
	assert_true(AjustesJuego.consejos_vistos().has("umbral"))

func test_no_se_repiten_en_la_siguiente_mesa() -> void:
	var juego = _casino()
	_sentar(juego)
	juego.mesa.queue_free()
	juego.mesa = null
	var otro = _casino()
	_sentar(otro, "recaudador")
	assert_false(otro.mesa.globo.visible, "El Umbral ya se explicó")

func test_la_quiebra_se_explica_la_primera_vez() -> void:
	var juego = _casino()
	AjustesJuego.marcar_consejo("umbral")
	AjustesJuego.marcar_consejo("pedir")
	_sentar(juego)
	_mazo(juego, [["velas", 9], ["relojes", 8], ["velas", 10]])
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	juego.mesa.boton_plantarse.pressed.emit()
	assert_eq(juego.mesa.globo.id, "quiebra")
	assert_true(_dentro(juego.mesa.globo))

func test_apagados_en_opciones_no_salen() -> void:
	AjustesJuego.guardar_consejos(false)
	var juego = _casino()
	_sentar(juego)
	assert_false(juego.mesa.globo.visible)
	assert_eq(AjustesJuego.consejos_vistos(), [])

func test_la_recompensa_y_la_tienda_tienen_su_consejo() -> void:
	var juego = _casino()
	AjustesJuego.marcar_consejo("umbral")
	_sentar(juego)
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.meta = 1
	_mazo(juego, [["llaves", 7], ["velas", 10]])
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	juego.mesa.boton_plantarse.pressed.emit()
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	assert_true(juego.recompensa.visible)
	assert_eq(juego.globo.id, "recompensa")
	assert_true(_dentro(juego.globo))
	juego.recompensa.boton_omitir.pressed.emit()
	assert_false(juego.globo.visible, "Se retira al decidir")
	juego.entrar("tienda")
	juego.tienda()
	await get_tree().process_frame
	assert_eq(juego.globo.id, "tienda")
	assert_true(_dentro(juego.globo))

func test_repetir_los_consejos_desde_opciones() -> void:
	AjustesJuego.marcar_consejo("umbral")
	var panel = load("res://casino/interfaz/menus/panel_opciones.gd").new()
	add_child_autofree(panel)
	panel.construir(null)
	assert_not_null(panel.consejos)
	panel.repetir_consejos.pressed.emit()
	assert_eq(AjustesJuego.consejos_vistos(), [])
	panel.consejos.button_pressed = false
	assert_false(AjustesJuego.consejos())
