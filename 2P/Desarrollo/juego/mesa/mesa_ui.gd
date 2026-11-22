extends Control
## Adaptador visual: toda decisión y cálculo pertenece al controlador.

const Controlador = preload("res://mesa/controlador_mesa.gd")
const Iniciar = preload("res://dominio/comandos/iniciar_mano.gd")
const Pedir = preload("res://dominio/comandos/pedir_carta.gd")
const ComandoPlantarse = preload("res://dominio/comandos/plantarse.gd")
const Devolver = preload("res://dominio/comandos/devolver_llave.gd")
const Carta = preload("res://cartas/carta.tscn")
const Guia = preload("res://mesa/guia_custodio.gd")
const Marco = preload("res://mesa/marco_casa.gd")
const Lectura = preload("res://mesa/lectura_mesa.gd")
const DURACION_CUENTA := 0.45
const ORO := Color("d5b578")
const MARFIL := Color("f1e4c9")
const MUTED := Color("b9c4a8")
const TINTA := Color("263a2b")
const BASE := Vector2(1440, 810)

signal salir_de_mesa(victoria: bool, exactos: int)
var campana: CampanaCasino
var boton_lente: Button

@export var conectar_controlador := true
var controlador: Node
var vista: Dictionary = {}
var lienzo: Control
var boton_iniciar_pedir: Button
var boton_plantarse: Button
var boton_ayuda: Button
var boton_reiniciar: Button
var boton_demostracion: Button
var boton_desglose: Button
var fila_cartas: HBoxContainer
var cartas_scroll: ScrollContainer
var _vacio: Control
var _titulo_estado: Label
var _contador: Label
var _presupuesto: Label
var _meta: Label
var _puntos: Label
var _umbral: Label
var _lectura: Label
var _lectura_titulo: Label
var _explicacion: Label
var _mensaje: Label
var _mazo: Label
var _subtitulo: Label
var _modal: Control
var _panel_modal: Panel
var _contenido_modal: Control
var _foco_anterior: Control
var _focos_suspendidos: Dictionary = {}
var _accion_confirmada: Callable
var _revision_vista := 0
var movimiento_reducido := false
var _progreso: ProgressBar
var _transicion_progreso: Tween
var _llave_seleccionada := ""
var _acciones_llave: Panel
var _confirmacion_llave: Label
var _boton_confirmar_llave: Button
var _boton_cancelar_llave: Button
var _patrones_ui: HBoxContainer
var _patron_raton := -1
var _patron_foco := -1
var _revelando := false
var _revision_revelacion := 0
var _vista_por_revelar: Dictionary = {}
## Respuesta visual al resolver: cuenta de puntos y gesto de las cartas. Nunca altera la vista.
var _feedback: Tween
## Placa con la regla del crupier sobre el pie del retrato, y su aviso de cambio de umbral.
var _regla: PanelContainer
var _regla_texto: Label
var _nota_umbral: Label
var _aviso_umbral: Tween
var _textos_finales: Dictionary = {}

func _ready() -> void:
	_construir()
	resized.connect(_adaptar)
	_adaptar()
	if conectar_controlador:
		controlador = Controlador.new()
		if campana != null: controlador.configurar_campana(campana)
		controlador.name = "ControladorMesa"
		add_child(controlador)
		controlador.vista_actualizada.connect(presentar_vista)
		presentar_vista(controlador.obtener_vista())
	boton_iniciar_pedir.grab_focus()

func _adaptar() -> void:
	if not is_instance_valid(lienzo):
		return
	var factor: float = minf(size.x / BASE.x, size.y / BASE.y)
	lienzo.scale = Vector2.ONE * factor
	lienzo.position = (size - BASE * factor) * 0.5

func _construir() -> void:
	var fondo := ColorRect.new()
	fondo.color = Color("0b2119")
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fondo)
	lienzo = Control.new()
	lienzo.name = "LienzoMesa"
	lienzo.size = BASE
	add_child(lienzo)
	_imagen(lienzo, "res://recursos/figma/marco-casino.svg", Rect2(24, 24, 1391, 761))
	_etiqueta(lienzo, "LA ÚLTIMA MESA", Rect2(40, 29, 490, 44), 29, ORO, true)
	_subtitulo = _etiqueta(lienzo, "MESA I  /  EL PRIMER SELLO", Rect2(530, 39, 430, 22), 13, MUTED)
	boton_reiniciar = _boton_texto(lienzo, "boton_reiniciar", "REINICIAR · R", Rect2(1025, 32, 158, 38), _solicitar_reinicio, 13)
	boton_ayuda = _boton_texto(lienzo, "boton_ayuda", "CÓMO JUGAR · H", Rect2(1210, 32, 185, 38), mostrar_ayuda, 14)
	boton_demostracion = _boton_texto(lienzo, "boton_demostracion", "DEMOSTRACIÓN GUIADA", Rect2(531, 68, 245, 25), _solicitar_demostracion, 11)
	boton_demostracion.tooltip_text = "Cargar una secuencia preparada para aprender las reglas. Reinicia el intento."
	var retrato := "res://recursos/arte/custodio-grabado.png"
	var nombre := "El Custodio"
	if campana != null:
		nombre = CampanaCasino.NOMBRES[campana.activa]
		if campana.activa != "custodio": retrato = "res://casino/arte/personaje_%s.webp" % campana.activa
		boton_demostracion.hide()
		boton_reiniciar.hide()
		_boton_texto(lienzo,"bolsa_campana","OBJETOS · I",Rect2(1025,32,158,38),_ver_objetos,15)
		boton_lente = _boton_texto(lienzo, "boton_lente", "LENTE", Rect2(510, 66, 340, 36), _usar_lente, 15)
	_imagen(lienzo, retrato, Rect2(22, 124, 356, 534), true)
	_construir_regla()
	_etiqueta(lienzo, nombre, Rect2(429, 119, 610, 75), 46, MARFIL, true)
	_titulo_estado = _etiqueta(lienzo, "", Rect2(431, 194, 680, 30), 16, ORO)
	_umbral = _etiqueta(lienzo, "", Rect2(32, 660, 115, 112), 88, ORO, true)
	_etiqueta(lienzo, "UMBRAL", Rect2(155, 671, 215, 28), 18, ORO)
	_nota_umbral = _etiqueta(lienzo, "No lo excedas.", Rect2(155, 703, 215, 29), 20, MUTED)
	_imagen(lienzo, "res://recursos/figma/dial.svg", Rect2(1210, 124, 180, 180))
	_contador = _etiqueta(lienzo, "", Rect2(1234, 168, 130, 78), 62, ORO, true)
	_contador.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_presupuesto = _etiqueta(lienzo, "", Rect2(1234, 250, 130, 23), 13, MUTED)
	_presupuesto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_etiqueta(lienzo, "CAMPANADAS", Rect2(1190, 306, 240, 32), 17, ORO)
	_imagen(lienzo, "res://recursos/figma/boleto.svg", Rect2(1157, 393, 238, 237))
	_etiqueta(lienzo, "META DE LA MESA", Rect2(1180, 416, 195, 24), 14, TINTA)
	_meta = _etiqueta(lienzo, "", Rect2(1182, 441, 190, 85), 68, TINTA, true)
	_etiqueta(lienzo, "PUNTOS", Rect2(1294, 485, 82, 22), 12, TINTA)
	_etiqueta(lienzo, "ACUMULADOS", Rect2(1181, 542, 195, 24), 12, TINTA)
	_puntos = _etiqueta(lienzo, "", Rect2(1181, 562, 196, 48), 35, TINTA, true)
	_progreso = ProgressBar.new()
	_progreso.position = Vector2(1182, 615)
	_progreso.show_percentage = false
	_progreso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pista := StyleBoxFlat.new()
	pista.bg_color = Color("b8aa89")
	_progreso.add_theme_stylebox_override("background", pista)
	var avance := StyleBoxFlat.new()
	avance.bg_color = TINTA
	_progreso.add_theme_stylebox_override("fill", avance)
	lienzo.add_child(_progreso)
	_progreso.size = Vector2(192, 5)
	boton_desglose = _boton_texto(lienzo, "boton_desglose", "VER DESGLOSE", Rect2(1157, 646, 238, 36), mostrar_desglose, 14)
	boton_desglose.hide()
	_construir_mano()
	_patrones_ui = HBoxContainer.new()
	_patrones_ui.position = Vector2(431, 552)
	_patrones_ui.size = Vector2(680, 43)
	_patrones_ui.add_theme_constant_override("separation", 6)
	lienzo.add_child(_patrones_ui)
	_patrones_ui.hide()
	_imagen(lienzo, "res://recursos/figma/filete.svg", Rect2(432, 599, 671, 1))
	_lectura_titulo = _etiqueta(lienzo, "SIGUIENTE PASO", Rect2(431, 607, 175, 23), 12, MUTED)
	_lectura = _etiqueta(lienzo, "—", Rect2(588, 606, 235, 50), 40, MARFIL, true)
	_explicacion = _etiqueta(lienzo, "", Rect2(827, 606, 284, 47), 16, MUTED)
	_explicacion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mensaje = _etiqueta(lienzo, "", Rect2(432, 660, 684, 40), 16, MUTED)
	_mensaje.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	boton_iniciar_pedir = _boton_accion("boton_iniciar_pedir", Rect2(417, 706, 278, 80), true, _iniciar_o_pedir, "P")
	boton_plantarse = _boton_accion("boton_plantarse", Rect2(713, 706, 278, 80), false, _plantarse, "S")
	_texto_accion(boton_plantarse, "PLANTARSE", "Gratis · revelar y puntuar")
	_mazo = _etiqueta(lienzo, "", Rect2(40, 780, 350, 24), 12, MUTED)
	_construir_eleccion_llave()
	_construir_modal()

func _construir_mano() -> void:
	cartas_scroll = ScrollContainer.new()
	cartas_scroll.name = "CartasScroll"
	cartas_scroll.position = Vector2(405, 235)
	cartas_scroll.size = Vector2(718, 325)
	cartas_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	cartas_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	lienzo.add_child(cartas_scroll)
	var centro := CenterContainer.new()
	centro.custom_minimum_size = Vector2(718, 311)
	centro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cartas_scroll.add_child(centro)
	fila_cartas = HBoxContainer.new()
	fila_cartas.name = "Mano"
	fila_cartas.add_theme_constant_override("separation", 16)
	centro.add_child(fila_cartas)
	_vacio = Control.new()
	_vacio.position = Vector2(432, 310)
	_vacio.size = Vector2(665, 150)
	lienzo.add_child(_vacio)
	var titulo := _etiqueta(_vacio, "La mesa te espera", Rect2(0, 40, 665, 50), 34, ORO, true)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _etiqueta(padre: Node, texto: String, rect: Rect2, tamano: int, color: Color, display := false) -> Label:
	var etiqueta := Label.new()
	# El texto no debe imponer su ancho mínimo antes de habilitar el ajuste.
	etiqueta.clip_text = true
	etiqueta.text = texto
	etiqueta.position = rect.position
	etiqueta.size = rect.size
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	if display:
		etiqueta.theme_type_variation = &"DisplayLabel"
	padre.add_child(etiqueta)
	return etiqueta

func _imagen(padre: Node, ruta: String, rect: Rect2, conservar := false) -> TextureRect:
	var imagen := TextureRect.new()
	imagen.texture = load(ruta)
	imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if conservar else TextureRect.STRETCH_SCALE
	imagen.position = rect.position
	imagen.size = rect.size
	imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	padre.add_child(imagen)
	return imagen

func _boton_texto(padre: Node, nombre: String, texto: String, rect: Rect2, accion: Callable, tamano := 16) -> Button:
	var boton := Button.new()
	boton.name = nombre
	boton.text = texto
	boton.position = rect.position
	boton.size = rect.size
	boton.add_theme_font_size_override("font_size", tamano)
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	boton.pressed.connect(accion)
	padre.add_child(boton)
	return boton

func _boton_accion(nombre: String, rect: Rect2, primario: bool, accion: Callable, tecla: String) -> Button:
	var boton := _boton_texto(lienzo, nombre, "", rect, accion)
	var ruta := "res://recursos/figma/accion-primaria.svg" if primario else "res://recursos/figma/accion-secundaria.svg"
	var imagen := _imagen(boton, ruta, Rect2(Vector2.ZERO, rect.size))
	imagen.name = "Fondo"
	var atajo := Panel.new()
	atajo.name = "Atajo"
	atajo.position = Vector2(12, 26)
	atajo.size = Vector2(28, 28)
	atajo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var borde := StyleBoxFlat.new()
	borde.bg_color = Color.TRANSPARENT
	borde.border_color = TINTA if primario else ORO
	borde.set_border_width_all(2)
	atajo.add_theme_stylebox_override("panel", borde)
	boton.add_child(atajo)
	var letra := _etiqueta(atajo, tecla, Rect2(0, 0, 28, 28), 16, TINTA if primario else MARFIL)
	letra.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	letra.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var titulo := _etiqueta(boton, "", Rect2(47, 14, rect.size.x - 59, 30), 17, TINTA if primario else MARFIL)
	titulo.name = "Etiqueta"
	titulo.theme_type_variation = &"BoldLabel"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var detalle := _etiqueta(boton, "", Rect2(47, 44, rect.size.x - 59, 24), 13, TINTA if primario else MUTED)
	detalle.name = "Coste"
	detalle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return boton

func _texto_accion(boton: Button, titulo: String, detalle: String) -> void:
	boton.get_node("Etiqueta").text = titulo
	boton.get_node("Coste").text = detalle
	boton.tooltip_text = "%s. %s" % [titulo, detalle]
	for propiedad in boton.get_property_list():
		if propiedad.name == "accessibility_name":
			boton.set("accessibility_name", boton.tooltip_text)

func presentar_vista(nueva_vista: Dictionary) -> void:
	var tiene_ocultas := false
	for carta in vista.get("cartas", []):
		if carta.get("oculta", false): tiene_ocultas = true
	if not movimiento_reducido and vista.get("fase", "") == "decision" and tiene_ocultas and not nueva_vista.get("ultima_mano", {}).is_empty() and nueva_vista.get("fase", "") != "decision":
		_descartar_revelacion()
		_revelar_mano(nueva_vista)
	else:
		_descartar_revelacion()
		_pintar_vista(nueva_vista)

func _descartar_revelacion() -> void:
	_revision_revelacion += 1
	_revelando = false
	_vista_por_revelar.clear()

func _terminar_revelacion() -> void:
	if not _revelando: return
	var final := _vista_por_revelar.duplicate(true)
	_descartar_revelacion()
	_pintar_vista(final)

func _revelar_mano(final: Dictionary) -> void:
	_limpiar_patron()
	_cancelar_seleccion_llave(false)
	_vista_por_revelar = final.duplicate(true)
	_revelando = true
	var revision := _revision_revelacion
	_titulo_estado.text = "LA CASA REVELA TU MANO"
	_lectura_titulo.text = "REVELANDO"
	_mensaje.hide()
	boton_iniciar_pedir.disabled = true
	boton_iniciar_pedir.get_node("Fondo").modulate.a = 0.55
	boton_plantarse.disabled = false
	_texto_accion(boton_plantarse, "MOSTRAR RESULTADO", "Saltar revelación")
	var indices: Array[int] = []
	for i in range(vista.get("cartas", []).size()):
		if vista.cartas[i].get("oculta", false): indices.append(i)
	var pausa: float = minf(0.18, 0.66 / maxf(1.0, float(indices.size())))
	for indice in indices:
		await get_tree().create_timer(pausa).timeout
		if revision != _revision_revelacion or not _revelando: return
		fila_cartas.get_child(indice).presentar(final.cartas[indice])
		var suma := 0
		var ocultas := 0
		for carta in fila_cartas.get_children():
			if carta._vista.get("oculta", false): ocultas += 1
			else: suma += int(carta._vista.get("valor_efectivo", 0))
		_lectura_titulo.text = "SUMA REVELADA"
		_lectura.text = str(suma) + (" + ?" if ocultas > 0 else "")
		_explicacion.text = "%s por revelar" % ocultas if ocultas > 0 else ""
	await get_tree().create_timer(0.22).timeout
	if revision == _revision_revelacion and _revelando: _terminar_revelacion()

func _pintar_vista(nueva_vista: Dictionary) -> void:
	if not is_instance_valid(lienzo):
		return
	_cancelar_seleccion_llave(false)
	_limpiar_patron()
	_detener_feedback()
	var umbral_previo: int = int(vista.get("umbral", 0))
	var mesa_previa: String = str(vista.get("mesa", ""))
	var recien_resuelta: bool = vista.get("fase", "") == "decision" and nueva_vista.get("fase", "") != "decision" and not nueva_vista.get("ultima_mano", {}).is_empty()
	var puntos_previos: int = int(vista.get("puntos", 0))
	var anteriores: Array = vista.get("cartas", [])
	var ultimo_anterior: String = str(anteriores.back().get("id", "")) if not anteriores.is_empty() else ""
	_revision_vista += 1
	vista = nueva_vista.duplicate(true)
	var acciones: Dictionary = vista.get("acciones", {})
	var fase: String = vista.get("fase", "preparado")
	var terminada: bool = vista.get("terminado", false)
	if _transicion_progreso != null and _transicion_progreso.is_valid():
		_transicion_progreso.kill()
	_progreso.max_value = float(vista.get("meta", 200))
	var destino := float(vista.get("puntos", 0))
	if movimiento_reducido or destino == 0:
		_progreso.value = destino
	else:
		_transicion_progreso = create_tween()
		_transicion_progreso.tween_property(_progreso, "value", destino, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_contador.text = str(vista.get("campanadas", 0))
	_presupuesto.text = "ÚLTIMA MANO" if fase == "decision" and int(vista.get("campanadas", 0)) == 0 else "DE %s" % vista.get("presupuesto", 10)
	_meta.text = str(vista.get("meta", 200))
	_puntos.text = "%s / %s" % [vista.get("puntos", 0), vista.get("meta", 200)]
	_umbral.text = str(vista.get("umbral", 17))
	_presentar_regla(umbral_previo, mesa_previa)
	_mazo.text = "MAZO %s  ·  DESCARTE %s" % [vista.get("mazo", 0), vista.get("descarte", 0)]
	_subtitulo.text = "MESA I  /  EL PRIMER SELLO" + ("  ·  DEMOSTRACIÓN" if vista.get("modo_demostracion", false) else "")
	boton_iniciar_pedir.disabled = not bool(acciones.get("iniciar", false) or acciones.get("pedir", false))
	boton_plantarse.disabled = not bool(acciones.get("plantarse", false))
	if campana != null:
		_subtitulo.text = "%s FICHAS  ·  %s / 3 SELLOS" % [campana.saldo, mini(3, campana.superadas)]
		boton_lente.text = "LENTE DE HUMO ×%s" % campana.lentes
		boton_lente.visible = campana.lentes > 0
		boton_lente.disabled = fase != "decision" or int(vista.intervalo.ocultas) == 0
	boton_reiniciar.disabled = not bool(acciones.get("reiniciar", true))
	_texto_accion(boton_iniciar_pedir, "PEDIR" if fase == "decision" else "INICIAR MANO", ("−1 ficha" if vista.get("comision", false) else "Gratis") if fase == "decision" else "−1 campanada")
	boton_plantarse.visible = fase == "decision"
	for boton in [boton_iniciar_pedir, boton_plantarse]:
		boton.get_node("Fondo").modulate.a = 0.55 if boton.disabled else 1.0
	_titulo_estado.text = "VICTORIA · EL PRIMER SELLO ES TUYO" if vista.get("victoria", false) else ("DERROTA · FIN DEL INTENTO" if terminada else ("MANO %s" % vista.get("numero_mano", 1) if fase == "decision" else ""))
	if campana != null and vista.get("victoria", false): _titulo_estado.text = "VICTORIA · MESA SUPERADA"
	var cartas: Array = vista.get("cartas", [])
	# La identidad visual conserva el foco al pedir o revelar; el orden lo dicta la vista.
	var existentes: Dictionary = {}
	for nodo in fila_cartas.get_children():
		existentes[str(nodo.get_meta("carta_id", ""))] = nodo
	_vacio.visible = cartas.is_empty()
	var ancho_carta := 184.0
	if cartas.size() >= 4 and cartas.size() <= 5:
		ancho_carta = floorf((704.0 - 16.0 * (cartas.size() - 1)) / cartas.size())
	for indice in range(cartas.size()):
		var datos: Dictionary = cartas[indice]
		var id := str(datos.get("id", "posicion-%s" % indice))
		var nueva := not existentes.has(id)
		var carta = Carta.instantiate() if nueva else existentes[id]
		existentes.erase(id)
		if nueva:
			carta.name = "Carta_%s" % indice
			carta.set_meta("carta_id", id)
			fila_cartas.add_child(carta)
			carta.ampliacion_solicitada.connect(_activar_carta.bind(id))
		carta.custom_minimum_size = Vector2(ancho_carta, 286)
		fila_cartas.move_child(carta, indice)
		carta.establecer_movimiento_reducido(movimiento_reducido)
		carta.presentar(datos)
		carta.establecer_devolucion_disponible(vista.get("llaves_disponibles", []).has(id))
		if nueva and not _modal.visible:
			carta.animar_entrada(minf(indice * 0.045, 0.09))
		if _modal.visible:
			if not _focos_suspendidos.has(carta):
				_focos_suspendidos[carta] = carta.focus_mode
			carta.focus_mode = Control.FOCUS_NONE
	for nodo in existentes.values():
		_focos_suspendidos.erase(nodo)
		fila_cartas.remove_child(nodo)
		nodo.queue_free()
	var intervalo: Dictionary = vista.get("intervalo", {})
	boton_desglose.visible = _hay_resultado_revelado()
	_lectura.position = Vector2(588, 606)
	_lectura.size = Vector2(235, 50)
	_lectura_titulo.visible = not cartas.is_empty() and not boton_desglose.visible
	_lectura.visible = not cartas.is_empty()
	_explicacion.position = Vector2(827, 606)
	_explicacion.size = Vector2(284, 47)
	_explicacion.tooltip_text = ""
	if boton_desglose.visible:
		var lectura: Dictionary = Lectura.resultado(vista)
		_lectura.position = Vector2(431, 600)
		_lectura.size = Vector2(680, 43)
		_lectura.text = lectura.formula
		_lectura.add_theme_font_size_override("font_size", 34)
		_explicacion.position = Vector2(432, 642)
		_explicacion.size = Vector2(680, 22)
		_explicacion.text = lectura.detalle
		_explicacion.tooltip_text = lectura.completo
	else:
		_lectura_titulo.text = "TOTAL POSIBLE" if intervalo.get("ocultas", 0) > 0 else ("SUMA EFECTIVA" if not cartas.is_empty() else "SIGUIENTE PASO")
		_lectura.text = "%s–%s" % [intervalo.get("minimo", 0), intervalo.get("maximo", 0)] if intervalo.get("ocultas", 0) > 0 else (str(intervalo.get("conocido", 0)) if not cartas.is_empty() else "—")
		_lectura.add_theme_font_size_override("font_size", 40)
		_explicacion.text = ""
		if intervalo.get("ocultas", 0) > 0:
			var conocidas := "%s + ?" % intervalo.get("conocido", 0)
			if int(intervalo.get("ocultas", 0)) > 1:
				conocidas += " × %s" % intervalo.get("ocultas", 0)
			var ocultas: int = int(intervalo.get("ocultas", 0))
			_explicacion.text = conocidas + "\n%s %s" % [ocultas, "oculta" if ocultas == 1 else "ocultas"]
	_explicacion.visible = not _explicacion.text.is_empty()
	_actualizar_orientacion()
	_presentar_patrones()
	if not _modal.visible:
		var actual := get_viewport().gui_get_focus_owner()
		if terminada or actual == null or not actual.is_visible_in_tree() or (actual is BaseButton and actual.disabled):
			_enfocar_accion_legal()
	if cartas.size() >= 6 and str(cartas.back().get("id", "")) != ultimo_anterior and not _modal.visible:
		_mostrar_ultima_carta(_revision_vista)
	if recien_resuelta and not movimiento_reducido and not _modal.visible:
		_celebrar_resultado(puntos_previos)

func _construir_regla() -> void:
	_regla = PanelContainer.new()
	_regla.name = "ReglaCrupier"
	var placa := StyleBoxFlat.new()
	placa.bg_color = Color(0.02, 0.06, 0.045, 0.86)
	placa.border_color = ORO
	placa.border_width_top = 1
	placa.content_margin_left = 14
	placa.content_margin_right = 14
	placa.content_margin_top = 8
	placa.content_margin_bottom = 9
	_regla.add_theme_stylebox_override("panel", placa)
	_regla.position = Vector2(22, 580)
	_regla.size = Vector2(356, 78)
	_regla.custom_minimum_size = Vector2(356, 0)
	_regla.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 2)
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_regla.add_child(columna)
	var rotulo := Label.new()
	rotulo.text = "REGLA DE LA MESA"
	rotulo.add_theme_font_size_override("font_size", 11)
	rotulo.add_theme_color_override("font_color", ORO)
	columna.add_child(rotulo)
	_regla_texto = Label.new()
	_regla_texto.name = "TextoRegla"
	_regla_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_regla_texto.custom_minimum_size = Vector2(328, 0)
	_regla_texto.add_theme_font_size_override("font_size", 15)
	_regla_texto.add_theme_color_override("font_color", MARFIL)
	columna.add_child(_regla_texto)
	lienzo.add_child(_regla)
	_regla.hide()

## La placa crece hacia arriba desde el pie del retrato para no tapar el umbral.
func _presentar_regla(umbral_previo: int, mesa_previa: String) -> void:
	var regla: Dictionary = Lectura.regla(vista)
	_regla_texto.text = regla.texto
	_nota_umbral.text = regla.nota
	_regla.visible = not str(regla.texto).is_empty()
	if _regla.visible:
		_regla.reset_size()
		_regla.position.y = 658.0 - _regla.get_combined_minimum_size().y
	var umbral := int(vista.get("umbral", 17))
	if umbral_previo > 0 and umbral != umbral_previo and mesa_previa == str(vista.get("mesa", "")):
		_avisar_cambio_umbral()

## El número del umbral late en oro al cambiar; el texto de la placa explica el cambio.
func _avisar_cambio_umbral() -> void:
	if _aviso_umbral != null and _aviso_umbral.is_valid(): _aviso_umbral.kill()
	_umbral.scale = Vector2.ONE
	_umbral.modulate = Color.WHITE
	if movimiento_reducido: return
	_umbral.pivot_offset = _umbral.size * 0.5
	_umbral.scale = Vector2.ONE * 1.3
	_umbral.modulate = Color(1.25, 1.12, 0.8)
	_aviso_umbral = create_tween().set_parallel(true)
	_aviso_umbral.tween_property(_umbral, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_aviso_umbral.tween_property(_umbral, "modulate", Color.WHITE, 0.9)

## Los textos ya contienen el resultado final; la animación solo los recorre y vuelve a ellos.
func _celebrar_resultado(puntos_previos: int) -> void:
	var mano: Dictionary = vista.get("ultima_mano", {})
	var cartas := fila_cartas.get_children()
	_textos_finales = {_lectura: _lectura.text, _puntos: _puntos.text}
	_lectura.pivot_offset = _lectura.size * 0.5
	_feedback = create_tween()
	if mano.get("quiebra", false):
		for carta in cartas:
			carta.sacudir(0.8)
		_feedback.tween_property(_lectura, "modulate", Color(1.0, 0.62, 0.55), 0.08)
		_feedback.tween_property(_lectura, "modulate", Color.WHITE, 0.4)
		_feedback.tween_callback(_detener_feedback)
		return
	var total: int = int(mano.get("total", 0))
	var multiplicador: int = int(mano.get("multiplicador", 1))
	var aporte: int = int(mano.get("puntos", 0))
	var meta: int = int(vista.get("meta", 200))
	var cuenta := func(valor: float) -> void:
		_lectura.text = "%s × %s = %s" % [total, multiplicador, roundi(valor)]
		_puntos.text = "%s / %s" % [puntos_previos + roundi(valor), meta]
	cuenta.call(0.0)
	_feedback.tween_method(cuenta, 0.0, float(aporte), DURACION_CUENTA).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_feedback.tween_property(_lectura, "scale", Vector2.ONE * 1.12, 0.07)
	_feedback.tween_property(_lectura, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_feedback.tween_callback(_detener_feedback)
	if mano.get("patrones", []).has("Punto exacto"):
		for i in range(cartas.size()):
			cartas[i].celebrar(DURACION_CUENTA * 0.6 + i * 0.05)

func _detener_feedback() -> void:
	if _feedback != null and _feedback.is_valid():
		_feedback.kill()
	_feedback = null
	for etiqueta in _textos_finales:
		etiqueta.text = _textos_finales[etiqueta]
	_textos_finales.clear()
	_lectura.scale = Vector2.ONE
	_lectura.modulate = Color.WHITE

func _mostrar_ultima_carta(revision: int) -> void:
	# Los Containers necesitan ordenar sus hijos antes de conocer el rango final.
	await get_tree().process_frame
	await get_tree().process_frame
	if revision != _revision_vista or _modal.visible:
		return
	cartas_scroll.scroll_horizontal = ceili(cartas_scroll.get_h_scroll_bar().max_value)

func _hay_resultado_revelado() -> bool:
	if vista.get("fase", "preparado") == "decision" or vista.get("ultima_mano", {}).is_empty():
		return false
	for carta in vista.get("cartas", []):
		if carta.get("oculta", false):
			return false
	return true

func mostrar_desglose() -> void:
	_terminar_revelacion()
	if not _hay_resultado_revelado():
		return
	_abrir_modal("DESGLOSE · MANO RESUELTA")
	_panel_modal.position = Vector2(250, 62)
	_panel_modal.size = Vector2(940, 686)
	_contenido_modal.size = _panel_modal.size
	var resultado: Dictionary = vista.get("ultima_mano", {})
	var valores: Array = resultado.get("valores", [])
	var partes := PackedStringArray()
	for valor in valores:
		partes.append(str(valor))
	var texto := RichTextLabel.new()
	texto.name = "DesgloseResultado"
	texto.position = Vector2(32, 95)
	texto.size = Vector2(536, 498)
	texto.bbcode_enabled = true
	texto.focus_mode = Control.FOCUS_ALL
	texto.add_theme_font_size_override("normal_font_size", 19)
	texto.add_theme_color_override("default_color", MARFIL)
	texto.text = "[b]VALORES EFECTIVOS · ORDEN DE ROBO[/b]\n%s = %s\nUmbral: %s\n\n" % [" + ".join(partes), resultado.get("total", 0), vista.get("umbral", 17)]
	if resultado.get("quiebra", false):
		texto.text += "[b]QUIEBRA[/b]\nEl total %s supera el umbral %s.\n\nBase del multiplicador: 1, sin aplicar.\nLas Velas y los patrones no producen bonificaciones en Quiebra.\nMultiplicador final: %s.\n\n[b]RESULTADO: 0 PUNTOS[/b]" % [resultado.get("total", 0), vista.get("umbral", 17), resultado.get("multiplicador", 0)]
	else:
		texto.text += "[b]MULTIPLICADOR[/b]\nBase: 1\nVelas conservadas: %s × +1\n" % resultado.get("velas", 0)
		var bonos: Dictionary = resultado.get("bonos", {})
		var patrones: Array = resultado.get("patrones", [])
		var formula := "1 + %s" % resultado.get("velas", 0)
		if patrones.is_empty():
			texto.text += "Sin patrones activados.\n"
		for patron in patrones:
			var bono: String = str(bonos.get(patron, "—"))
			texto.text += "%s: +%s\n" % [patron, bono]
			formula += " + " + bono
		if resultado.get("corona", 0) > 0:
			texto.text += "Corona del riesgo: +2\n"
			formula += " + 2"
		texto.text += "\nMultiplicador final: %s = %s\n\n[b]%s × %s = %s PUNTOS[/b]" % [formula, resultado.get("multiplicador", 1), resultado.get("total", 0), resultado.get("multiplicador", 1), resultado.get("puntos", 0)]
	_contenido_modal.add_child(texto)
	_imagen(_contenido_modal, "res://recursos/figma/boleto.svg", Rect2(595, 108, 310, 460))
	_etiqueta(_contenido_modal, "APORTE DE ESTA MANO", Rect2(617, 135, 266, 26), 13, TINTA)
	var aporte := _etiqueta(_contenido_modal, str(resultado.get("puntos", 0)), Rect2(615, 175, 270, 120), 80, TINTA, true)
	aporte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var concepto := _etiqueta(_contenido_modal, "QUIEBRA" if resultado.get("quiebra", false) else "PUNTOS", Rect2(615, 306, 270, 30), 18, TINTA)
	concepto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_etiqueta(_contenido_modal, "ACUMULADO / META", Rect2(617, 387, 266, 28), 13, TINTA)
	_etiqueta(_contenido_modal, "%s / %s" % [vista.get("puntos", 0), vista.get("meta", 200)], Rect2(617, 421, 266, 62), 36, TINTA, true)
	_etiqueta(_contenido_modal, "SELLO CONSEGUIDO" if vista.get("victoria", false) else "LA CUENTA CONTINÚA", Rect2(617, 511, 266, 30), 12, TINTA)
	var cerrar := _cerrar_boton()
	cerrar.size.x = 876

func _enfocar_accion_legal() -> void:
	var candidatos: Array = [boton_iniciar_pedir, boton_plantarse, boton_reiniciar]
	if vista.get("terminado", false):
		candidatos = [boton_iniciar_pedir, boton_reiniciar]
	for boton in candidatos:
		if boton.visible and not boton.disabled and boton.focus_mode != Control.FOCUS_NONE:
			boton.grab_focus()
			return
	boton_ayuda.grab_focus()

func _enviar(comando: RefCounted) -> void:
	if _revelando or not is_instance_valid(controlador):
		return
	var resultado = controlador.procesar_comando(comando)
	if not resultado.aceptado:
		_mensaje.text = resultado.motivo
		_mensaje.show()

func _iniciar_o_pedir() -> void:
	if boton_iniciar_pedir.disabled:
		return
	if vista.get("terminado", false):
		if campana != null: salir_de_mesa.emit(vista.victoria, controlador.exactos)
		else: _reiniciar()
	elif vista.get("fase", "preparado") == "decision":
		_enviar(Pedir.new())
	else:
		_enviar(Iniciar.new())

func _ver_objetos() -> void:
	if campana == null or _revelando or _modal.visible: return
	_abrir_modal("Inventario de la mesa")
	var datos := PackedStringArray()
	datos.append("Fichas: %s     ·     Lentes de humo: %s / 2" % [campana.saldo,campana.lentes])
	datos.append("La Lente revela las Máscaras actuales. Úsala desde la mesa antes de plantarte.")
	for id in campana.amuletos:
		var objeto := CampanaCasino.TIENDA.buscar(id)
		datos.append("%s  ·  %s" % [objeto.nombre,objeto.descripcion])
	match campana.activa:
		"recaudador": datos.append("Comisión de la casa: una ficha al pedir.")
		"coleccionista": datos.append("Cartas retenidas hasta superar esta mesa: %s." % controlador.retenidas.size())
		"dueno": datos.append("Cada mano cerrada sin Quiebra reduce el umbral un punto, hasta 17.")
	var ficha := _etiqueta(_contenido_modal,"",Rect2(38,100,716,340),20,MARFIL)
	ficha.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ficha.text = "\n\n".join(datos)
	_cerrar_boton()

func _usar_lente() -> void:
	if not _revelando and not _modal.visible and campana != null: controlador.usar_lente()

func _plantarse() -> void:
	if _revelando:
		_terminar_revelacion()
		return
	if not boton_plantarse.disabled:
		_enviar(ComandoPlantarse.new())

func _solicitar_reinicio() -> void:
	if boton_reiniciar.disabled:
		return
	if vista.get("fase") == "decision" or int(vista.get("campanadas", 10)) < int(vista.get("presupuesto", 10)):
		_confirmar("¿REINICIAR EL INTENTO?", "Volverás a la mesa con tu baraja completa, cero puntos y diez campanadas.", _reiniciar)
	else:
		_reiniciar()

func _reiniciar() -> void:
	if is_instance_valid(controlador):
		controlador.reiniciar()
	boton_iniciar_pedir.grab_focus()

func _solicitar_demostracion() -> void:
	_confirmar("DEMOSTRACIÓN GUIADA", "Reinicia el intento y prepara tres manos: 102 puntos, una Quiebra y 119 puntos. Tú decides cuándo pedir y plantarte; la baraja está preparada para aprender.", _demostracion)

func _demostracion() -> void:
	if is_instance_valid(controlador) and controlador.has_method("cargar_demostracion"):
		controlador.cargar_demostracion()

func _construir_modal() -> void:
	_modal = Control.new()
	_modal.name = "Modal"
	_modal.size = BASE
	_modal.visible = false
	lienzo.add_child(_modal)
	var sombra := ColorRect.new()
	sombra.color = Color(0.008, 0.025, 0.018, 0.93)
	sombra.size = BASE
	_modal.add_child(sombra)
	_panel_modal = Panel.new()
	_panel_modal.position = Vector2(340, 62)
	_panel_modal.size = Vector2(760, 686)
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("10291e")
	estilo.border_color = ORO
	estilo.set_border_width_all(1)
	estilo.set_corner_radius_all(2)
	_panel_modal.add_theme_stylebox_override("panel", estilo)
	_modal.add_child(_panel_modal)
	var marco := Marco.new()
	marco.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel_modal.add_child(marco)
	_contenido_modal = Control.new()
	_contenido_modal.size = _panel_modal.size
	_panel_modal.add_child(_contenido_modal)

func _abrir_modal(titulo: String) -> void:
	_terminar_revelacion()
	_detener_feedback()
	_cancelar_seleccion_llave()
	_limpiar_patron()
	_panel_modal.position = Vector2(340, 62)
	_panel_modal.size = Vector2(760, 686)
	_contenido_modal.size = _panel_modal.size
	_foco_anterior = get_viewport().gui_get_focus_owner()
	_focos_suspendidos.clear()
	for control in lienzo.find_children("*", "Control", true, false):
		if not _modal.is_ancestor_of(control) and control != _modal and control.focus_mode != Control.FOCUS_NONE:
			_focos_suspendidos[control] = control.focus_mode
			control.focus_mode = Control.FOCUS_NONE
	for nodo in _contenido_modal.get_children():
		_contenido_modal.remove_child(nodo)
		nodo.queue_free()
	_etiqueta(_contenido_modal, titulo, Rect2(32, 22, 660, 54), 32, ORO, true)
	_modal.show()

func cerrar_modal() -> void:
	_modal.hide()
	for control in _focos_suspendidos:
		if is_instance_valid(control):
			control.focus_mode = _focos_suspendidos[control]
	_focos_suspendidos.clear()
	if is_instance_valid(_foco_anterior) and not (_foco_anterior is BaseButton and _foco_anterior.disabled):
		_foco_anterior.grab_focus()
	else:
		_enfocar_accion_legal()

func _cerrar_boton(texto := "VOLVER A LA MESA") -> Button:
	var boton := _boton_texto(_contenido_modal, "boton_cerrar_modal", texto + "  ·  Esc", Rect2(32, 618, 696, 42), cerrar_modal)
	_estilo_modal(boton)
	boton.grab_focus()
	return boton

func _estilo_modal(boton: Button, principal := false) -> void:
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = ORO if principal else Color("1d3628")
	fondo.border_color = ORO if principal else Color("6c7951")
	fondo.set_border_width_all(1)
	boton.add_theme_stylebox_override("normal", fondo)
	var hover := fondo.duplicate() as StyleBoxFlat
	hover.bg_color = Color("e7c993") if principal else Color("2c4532")
	boton.add_theme_stylebox_override("hover", hover)
	boton.add_theme_stylebox_override("pressed", hover)
	for estado in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		boton.add_theme_color_override(estado, TINTA if principal else MARFIL)

func mostrar_ayuda() -> void:
	_abrir_modal("El libro de la casa" if campana != null else "El libro del Custodio")
	_panel_modal.position = Vector2(160, 47)
	_panel_modal.size = Vector2(1120, 716)
	_contenido_modal.size = _panel_modal.size
	var guia := Guia.new()
	guia.name = "Reglamento"
	if controlador != null and controlador.has_method("reglas_ayuda"): guia.reglas = controlador.reglas_ayuda()
	guia.position = Vector2(32, 100)
	_contenido_modal.add_child(guia)
	guia.movimiento.set_pressed_no_signal(movimiento_reducido)
	guia.movimiento_cambiado.connect(_cambiar_movimiento_reducido)
	var cerrar := _cerrar_boton()
	cerrar.position = Vector2(278, 649)
	cerrar.size = Vector2(810, 42)
	_etiqueta(_contenido_modal, "REGLAMENTO DE LA CASA", Rect2(32, 650, 220, 39), 12, MUTED)
	guia.navegacion[0].grab_focus()

## Elección de la persona en el libro: se aplica y se recuerda para la próxima sesión.
func _cambiar_movimiento_reducido(reducido: bool) -> void:
	establecer_movimiento_reducido(reducido)
	AjustesJuego.guardar_movimiento_reducido(reducido)

func establecer_movimiento_reducido(reducido: bool) -> void:
	movimiento_reducido = reducido
	if reducido:
		_terminar_revelacion()
		_detener_feedback()
		if _aviso_umbral != null and _aviso_umbral.is_valid(): _aviso_umbral.kill()
		_umbral.scale = Vector2.ONE
		_umbral.modulate = Color.WHITE
	for carta in fila_cartas.get_children():
		carta.establecer_movimiento_reducido(reducido)
	if reducido:
		if _transicion_progreso != null and _transicion_progreso.is_valid():
			_transicion_progreso.kill()
		_progreso.value = float(vista.get("puntos", 0))

func mostrar_carta(carta: Dictionary) -> void:
	_abrir_modal("Los símbolos de tu mano")
	var ampliada = Carta.instantiate()
	ampliada.position = Vector2(50, 110)
	ampliada.size = Vector2(260, 470)
	ampliada.focus_mode = Control.FOCUS_NONE
	ampliada.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_contenido_modal.add_child(ampliada)
	ampliada.establecer_movimiento_reducido(true)
	ampliada.presentar(carta)
	var palo := str(carta.get("palo", Palos.MASCARAS))
	var nombres := Palos.NOMBRES
	_etiqueta(_contenido_modal, nombres.get(palo, "Carta"), Rect2(350, 144, 370, 58), 40, ORO, true)
	var efectos := {
		Palos.VELAS: "Cada Vela conservada suma +1 al multiplicador, siempre que la mano no quiebre.",
		Palos.LLAVES: "Puedes devolver una Llave elegible para recibir otra carta gratis. Solo una vez por mano; el reemplazo se añade al final.",
		Palos.RELOJES: "Su valor efectivo es el impreso menos uno, con mínimo uno. Pedirlo es gratis en campanadas, igual que las demás cartas.",
		Palos.MASCARAS: "Su valor permanece oculto hasta plantarte. El intervalo usa de 1 a 10 por Máscara y no predice el valor real.",
	}
	var detalle := _etiqueta(_contenido_modal, efectos.get(palo, ""), Rect2(350, 230, 362, 220), 21, MARFIL)
	detalle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var lectura := "VALOR OCULTO · 1–10" if carta.get("oculta", false) else "VALOR EFECTIVO: %s" % carta.get("valor_efectivo", carta.get("valor", "—"))
	_etiqueta(_contenido_modal, lectura, Rect2(350, 489, 362, 65), 18, ORO)
	_cerrar_boton()

func mostrar_devolucion() -> void:
	var disponibles: Array = vista.get("llaves_disponibles", [])
	if _revelando or _modal.visible or disponibles.is_empty() or not vista.get("acciones", {}).get("devolver", false):
		return
	var indice := disponibles.find(_llave_seleccionada)
	_seleccionar_llave(str(disponibles[(indice + 1) % disponibles.size()]))

func _construir_eleccion_llave() -> void:
	_acciones_llave = Panel.new()
	_acciones_llave.name = "EleccionLlave"
	_acciones_llave.size = Vector2(280, 60)
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Color("10291e")
	fondo.border_color = ORO
	fondo.set_border_width_all(1)
	_acciones_llave.add_theme_stylebox_override("panel", fondo)
	lienzo.add_child(_acciones_llave)
	_confirmacion_llave = _etiqueta(_acciones_llave, "", Rect2(5, 0, 270, 21), 12, ORO)
	_confirmacion_llave.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boton_confirmar_llave = _boton_texto(_acciones_llave, "ConfirmarLlave", "Confirmar", Rect2(4, 22, 132, 36), _confirmar_llave, 13)
	_boton_cancelar_llave = _boton_texto(_acciones_llave, "CancelarLlave", "Cancelar", Rect2(144, 22, 132, 36), _cancelar_seleccion_llave, 13)
	_boton_confirmar_llave.icon = preload("res://recursos/figma/confirmar-llave.svg")
	_boton_cancelar_llave.icon = preload("res://recursos/figma/cancelar-llave.svg")
	for boton in [_boton_confirmar_llave, _boton_cancelar_llave]:
		boton.add_theme_constant_override("icon_max_width", 22)
	_estilo_modal(_boton_confirmar_llave, true)
	_estilo_modal(_boton_cancelar_llave)
	_boton_cancelar_llave.tooltip_text = "Cancelar elección sin cambiar cartas ni campanadas. Esc."
	_acciones_llave.hide()
	cartas_scroll.get_h_scroll_bar().value_changed.connect(func(_valor: float) -> void: _posicionar_eleccion_llave())

func _activar_carta(carta: Dictionary, id: String) -> void:
	if _revelando:
		_terminar_revelacion()
		return
	if _modal.visible:
		return
	if vista.get("llaves_disponibles", []).has(id):
		_seleccionar_llave(id)
	else:
		mostrar_carta(carta)

func _carta_por_id(id: String) -> Control:
	for carta in fila_cartas.get_children():
		if str(carta.get_meta("carta_id", "")) == id:
			return carta
	return null

func _seleccionar_llave(id: String) -> void:
	if _revelando or _modal.visible or not vista.get("acciones", {}).get("devolver", false) or not vista.get("llaves_disponibles", []).has(id):
		return
	var carta := _carta_por_id(id)
	if carta == null:
		return
	_limpiar_patron()
	_cancelar_seleccion_llave(false)
	_llave_seleccionada = id
	carta.establecer_seleccionada(true)
	_confirmacion_llave.text = "DEVOLVER LLAVE %s · GRATIS" % carta._vista.get("valor", "—")
	_boton_confirmar_llave.tooltip_text = _confirmacion_llave.text + ". Un reemplazo por mano."
	_acciones_llave.show()
	_patrones_ui.hide()
	_posicionar_eleccion_llave()
	_ajustar_eleccion_tras_layout(id)
	_boton_confirmar_llave.grab_focus()
	_mensaje.hide()

func _ajustar_eleccion_tras_layout(id: String) -> void:
	# Un reparto puede iniciar otro ordenamiento de Containers al terminar el frame.
	await get_tree().process_frame
	await get_tree().process_frame
	if _llave_seleccionada == id and not _modal.visible:
		_posicionar_eleccion_llave()

func _posicionar_eleccion_llave() -> void:
	if _llave_seleccionada.is_empty():
		return
	var carta := _carta_por_id(_llave_seleccionada)
	if carta == null:
		return
	var centro: Vector2 = lienzo.get_global_transform().affine_inverse() * carta.get_global_rect().get_center()
	_acciones_llave.position = Vector2(clampf(centro.x - 140, 405, 843), 537)

func _cancelar_seleccion_llave(reponer_foco := true) -> void:
	if _llave_seleccionada.is_empty():
		return
	var carta := _carta_por_id(_llave_seleccionada)
	_llave_seleccionada = ""
	_acciones_llave.hide()
	_patrones_ui.visible = not vista.get("cartas", []).is_empty()
	if carta != null:
		carta.establecer_seleccionada(false)
		if reponer_foco and not _modal.visible:
			carta.grab_focus()
	if not _revelando: _actualizar_orientacion()

func _confirmar_llave() -> void:
	var id := _llave_seleccionada
	if id.is_empty() or _modal.visible:
		return
	var legal: bool = vista.get("llaves_disponibles", []).has(id) and vista.get("acciones", {}).get("devolver", false)
	_cancelar_seleccion_llave()
	if legal:
		_enviar(Devolver.new(id))

func _actualizar_orientacion() -> void:
	_mensaje.position = Vector2(1015, 714) if vista.get("terminado", false) else Vector2(432, 660)
	_mensaje.size = Vector2(380, 58) if vista.get("terminado", false) else Vector2(684, 40)
	_mensaje.text = Lectura.pista(vista)
	_mensaje.visible = not _mensaje.text.is_empty()
	_texto_accion(boton_plantarse, "PLANTARSE", "Revelar y puntuar")
	boton_plantarse.tooltip_text += ". Sin coste en campanadas."
	if vista.get("fase", "preparado") == "decision":
		var resultado: Dictionary = vista.get("resultado_visible", {})
		if not resultado.is_empty():
			_texto_accion(boton_plantarse, "PLANTARSE", "%s puntos" % resultado.puntos)
	elif vista.get("terminado", false):
		boton_iniciar_pedir.disabled = false
		boton_iniciar_pedir.get_node("Fondo").modulate.a = 1.0
		if campana != null:
			_texto_accion(boton_iniciar_pedir, "LEVANTARSE", "Volver a la sala" if vista.victoria else "Fin del intento")
		else: _texto_accion(boton_iniciar_pedir, "VOLVER A JUGAR", "Nuevo intento")

func _presentar_patrones() -> void:
	# Conserva los botones: actualizar progreso no debe destruir el foco.
	var patrones: Array = vista.get("patrones_visibles", [])
	_patrones_ui.visible = not vista.get("cartas", []).is_empty() and not patrones.is_empty()
	for indice in range(patrones.size()):
		var datos: Dictionary = patrones[indice]
		var boton: Button
		if indice < _patrones_ui.get_child_count():
			boton = _patrones_ui.get_child(indice)
		else:
			boton = Button.new()
			boton.custom_minimum_size = Vector2(131, 43)
			boton.add_theme_font_size_override("font_size", 14)
			boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			boton.pressed.connect(_mostrar_patron.bind(indice))
			boton.mouse_entered.connect(_senalar_patron.bind(indice, true, true))
			boton.mouse_exited.connect(_senalar_patron.bind(indice, false, true))
			boton.focus_entered.connect(_senalar_patron.bind(indice, true, false))
			boton.focus_exited.connect(_senalar_patron.bind(indice, false, false))
			_patrones_ui.add_child(boton)
		boton.text = "%s +%s\n%s" % [datos.nombre, datos.bono, Lectura.progreso(datos)]
		boton.tooltip_text = "%s: %s. %s" % [datos.nombre, datos.detalle, datos.explicacion]
		if datos.condicionado: boton.tooltip_text += " Bono condicionado a no quebrar."
		var color := ORO if datos.estado == "activo" and not datos.condicionado else (MARFIL if datos.estado == "pendiente" or datos.condicionado else MUTED)
		boton.add_theme_color_override("font_color", color)
		boton.add_theme_color_override("font_focus_color", color)
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color.TRANSPARENT
		estilo.border_color = color if datos.estado == "activo" else Color("526043")
		estilo.border_width_bottom = 2 if datos.estado == "activo" else 1
		boton.add_theme_stylebox_override("normal", estilo)
		var hover := estilo.duplicate() as StyleBoxFlat
		hover.bg_color = Color("172d23")
		hover.border_color = ORO
		hover.border_width_bottom = 2
		boton.add_theme_stylebox_override("hover", hover)
		boton.add_theme_stylebox_override("pressed", hover)
		if _modal.visible and not _focos_suspendidos.has(boton):
			_focos_suspendidos[boton] = boton.focus_mode
			boton.focus_mode = Control.FOCUS_NONE
		if boton.has_focus(): _patron_foco = indice
	_refrescar_patron()

func _senalar_patron(indice: int, entrar: bool, raton: bool) -> void:
	if entrar and (_modal.visible or _revelando or not _llave_seleccionada.is_empty()): return
	if raton:
		if entrar: _patron_raton = indice
		elif _patron_raton == indice: _patron_raton = -1
	else:
		if entrar: _patron_foco = indice
		elif _patron_foco == indice: _patron_foco = -1
	_refrescar_patron()

func _limpiar_patron() -> void:
	_patron_raton = -1
	_patron_foco = -1
	for carta in fila_cartas.get_children(): carta.resaltar_patron(false)
	if not _revelando: _actualizar_orientacion()

func _refrescar_patron() -> void:
	var indice: int = _patron_raton if _patron_raton >= 0 else _patron_foco
	if _modal.visible or _revelando or not _llave_seleccionada.is_empty(): indice = -1
	var detalle: Dictionary = Lectura.patron(vista, indice)
	for i in range(fila_cartas.get_child_count()):
		fila_cartas.get_child(i).resaltar_patron(detalle.indices.has(i), indice >= 0 and not detalle.indices.has(i))
	if _revelando or not _llave_seleccionada.is_empty(): return
	_actualizar_orientacion()
	if not detalle.texto.is_empty() and indice >= 0:
		_mensaje.position = Vector2(432, 660)
		_mensaje.size = Vector2(684, 40)
		_mensaje.text = detalle.texto
		_mensaje.show()

func _mostrar_patron(indice: int) -> void:
	_terminar_revelacion()
	mostrar_ayuda()
	var guia = _contenido_modal.get_node("Reglamento")
	var patrones: Array = vista.get("patrones_visibles", [])
	if indice < patrones.size():
		guia.mostrar_patron(str(patrones[indice].nombre))
		_contenido_modal.get_child(0).text = str(patrones[indice].nombre) + " · cómo conseguirlo"
	guia.navegacion[2].grab_focus()

func _confirmar(titulo: String, mensaje: String, accion: Callable) -> void:
	_abrir_modal(titulo)
	_panel_modal.position = Vector2(310, 170)
	_panel_modal.size = Vector2(820, 470)
	_contenido_modal.size = _panel_modal.size
	_accion_confirmada = accion
	var detalle := _etiqueta(_contenido_modal, mensaje, Rect2(48, 112, 724, 175), 22, MARFIL)
	detalle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var confirmar := _boton_texto(_contenido_modal, "boton_confirmar", "CONFIRMAR", Rect2(424, 315, 348, 54), func() -> void:
		cerrar_modal()
		_accion_confirmada.call())
	_estilo_modal(confirmar, true)
	var cancelar := _cerrar_boton("CANCELAR")
	cancelar.position = Vector2(48, 315)
	cancelar.size = Vector2(348, 54)
	_etiqueta(_contenido_modal, "Tu partida solo cambia al confirmar.", Rect2(48, 406, 724, 32), 16, MUTED)

func _unhandled_key_input(evento: InputEvent) -> void:
	if not evento is InputEventKey or not evento.pressed or evento.echo:
		return
	if _modal.visible:
		if evento.keycode == KEY_ESCAPE:
			cerrar_modal()
			get_viewport().set_input_as_handled()
		return
	if _revelando and evento.keycode == KEY_ESCAPE:
		_terminar_revelacion()
		get_viewport().set_input_as_handled()
		return
	if evento.keycode == KEY_ESCAPE and not _llave_seleccionada.is_empty():
		_cancelar_seleccion_llave()
		get_viewport().set_input_as_handled()
		return
	match evento.keycode:
		KEY_P: _iniciar_o_pedir()
		KEY_S: _plantarse()
		KEY_L: mostrar_devolucion()
		KEY_H: mostrar_ayuda()
		KEY_I: _ver_objetos()
		KEY_R: _solicitar_reinicio()
		_: return
	get_viewport().set_input_as_handled()
