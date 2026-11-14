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
const ORO := Color("d5b578")
const MARFIL := Color("f1e4c9")
const MUTED := Color("b9c4a8")
const TINTA := Color("263a2b")
const BASE := Vector2(1440, 810)

@export var conectar_controlador := true
var controlador: Node
var vista: Dictionary = {}
var lienzo: Control
var boton_iniciar_pedir: Button
var boton_plantarse: Button
var boton_llave: Button
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

func _ready() -> void:
	_construir()
	resized.connect(_adaptar)
	_adaptar()
	if conectar_controlador:
		controlador = Controlador.new()
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
	boton_reiniciar = _boton_texto(lienzo, "boton_reiniciar", "REINICIAR", Rect2(1025, 32, 140, 38), _solicitar_reinicio, 13)
	boton_ayuda = _boton_texto(lienzo, "boton_ayuda", "?  CÓMO JUGAR", Rect2(1210, 32, 185, 38), mostrar_ayuda, 14)
	boton_demostracion = _boton_texto(lienzo, "boton_demostracion", "DEMOSTRACIÓN GUIADA", Rect2(531, 68, 245, 25), _solicitar_demostracion, 11)
	boton_demostracion.tooltip_text = "Cargar una secuencia preparada para aprender las reglas. Reinicia el intento."
	_imagen(lienzo, "res://recursos/arte/custodio-grabado.png", Rect2(22, 124, 356, 534), true)
	_etiqueta(lienzo, "El Custodio", Rect2(429, 119, 610, 75), 46, MARFIL, true)
	_titulo_estado = _etiqueta(lienzo, "", Rect2(431, 194, 680, 30), 16, ORO)
	_umbral = _etiqueta(lienzo, "", Rect2(32, 660, 115, 112), 88, ORO, true)
	_etiqueta(lienzo, "UMBRAL", Rect2(155, 671, 215, 28), 18, ORO)
	_etiqueta(lienzo, "No lo excedas.", Rect2(155, 703, 215, 29), 20, MUTED)
	_imagen(lienzo, "res://recursos/figma/dial.svg", Rect2(1210, 124, 180, 180))
	_contador = _etiqueta(lienzo, "", Rect2(1234, 168, 130, 78), 62, ORO, true)
	_contador.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_presupuesto = _etiqueta(lienzo, "", Rect2(1234, 236, 130, 23), 13, MUTED)
	_presupuesto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_etiqueta(lienzo, "CAMPANADAS", Rect2(1190, 306, 240, 32), 17, ORO)
	_etiqueta(lienzo, "Solo se gastan al actuar.", Rect2(1163, 337, 250, 27), 16, MUTED)
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
	_etiqueta(lienzo, "ORDEN DE ROBO  ·  IZQUIERDA A DERECHA  ·  CLIC PARA AMPLIAR", Rect2(443, 559, 660, 25), 11, MUTED)
	_imagen(lienzo, "res://recursos/figma/filete.svg", Rect2(432, 599, 671, 1))
	_lectura_titulo = _etiqueta(lienzo, "SIGUIENTE PASO", Rect2(431, 607, 175, 23), 12, MUTED)
	_lectura = _etiqueta(lienzo, "—", Rect2(588, 606, 235, 50), 40, MARFIL, true)
	_explicacion = _etiqueta(lienzo, "", Rect2(827, 609, 284, 43), 16, MUTED)
	_explicacion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mensaje = _etiqueta(lienzo, "", Rect2(432, 654, 684, 47), 16, MUTED)
	_mensaje.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	boton_iniciar_pedir = _boton_accion("boton_iniciar_pedir", Rect2(417, 706, 278, 80), true, _iniciar_o_pedir)
	boton_plantarse = _boton_accion("boton_plantarse", Rect2(713, 706, 278, 80), false, _plantarse)
	boton_llave = _boton_accion("boton_llave", Rect2(1009, 706, 386, 80), false, mostrar_devolucion)
	_texto_accion(boton_plantarse, "PLANTARSE", "Gratis · revelar y puntuar")
	_texto_accion(boton_llave, "DEVOLVER LLAVE", "Gratis · una vez por mano")
	_mazo = _etiqueta(lienzo, "", Rect2(40, 780, 350, 24), 12, MUTED)
	_etiqueta(lienzo, "P Pedir / iniciar    S Plantarse    L Llave    H Ayuda    R Reiniciar", Rect2(430, 786, 950, 18), 11, MUTED)
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
	var titulo := _etiqueta(_vacio, "AÚN NO HAY CARTAS", Rect2(0, 25, 665, 50), 29, ORO, true)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var detalle := _etiqueta(_vacio, "Iniciar reparte dos cartas y cuesta una campanada.", Rect2(0, 80, 665, 50), 20, MUTED)
	detalle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

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

func _boton_accion(nombre: String, rect: Rect2, primario: bool, accion: Callable) -> Button:
	var boton := _boton_texto(lienzo, nombre, "", rect, accion)
	var ruta := "res://recursos/figma/accion-primaria.svg" if primario else "res://recursos/figma/accion-secundaria.svg"
	var imagen := _imagen(boton, ruta, Rect2(Vector2.ZERO, rect.size))
	imagen.name = "Fondo"
	var titulo := _etiqueta(boton, "", Rect2(14, 14, rect.size.x - 28, 30), 18, TINTA if primario else MARFIL)
	titulo.name = "Etiqueta"
	titulo.theme_type_variation = &"BoldLabel"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var detalle := _etiqueta(boton, "", Rect2(14, 44, rect.size.x - 28, 24), 14, TINTA if primario else MUTED)
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
	if not is_instance_valid(lienzo):
		return
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
	_presupuesto.text = "DE %s" % vista.get("presupuesto", 10)
	_meta.text = str(vista.get("meta", 200))
	_puntos.text = "%s / %s" % [vista.get("puntos", 0), vista.get("meta", 200)]
	_umbral.text = str(vista.get("umbral", 17))
	_mazo.text = "MAZO %s  ·  DESCARTE %s" % [vista.get("mazo", 0), vista.get("descarte", 0)]
	_subtitulo.text = "MESA I  /  EL PRIMER SELLO" + ("  ·  DEMOSTRACIÓN" if vista.get("modo_demostracion", false) else "")
	boton_iniciar_pedir.disabled = not bool(acciones.get("iniciar", false) or acciones.get("pedir", false))
	boton_plantarse.disabled = not bool(acciones.get("plantarse", false))
	boton_llave.disabled = not bool(acciones.get("devolver", false))
	boton_reiniciar.disabled = not bool(acciones.get("reiniciar", true))
	_texto_accion(boton_iniciar_pedir, "PEDIR OTRA CARTA" if fase == "decision" else "INICIAR MANO", "−1 campanada")
	for boton in [boton_iniciar_pedir, boton_plantarse, boton_llave]:
		boton.get_node("Fondo").modulate.a = 0.55 if boton.disabled else 1.0
	_titulo_estado.text = "VICTORIA · EL PRIMER SELLO ES TUYO" if vista.get("victoria", false) else ("DERROTA · SIN MÁS OPORTUNIDADES" if terminada else ("MANO %s · TU DECISIÓN" % vista.get("numero_mano", 1) if fase == "decision" else ""))
	_mensaje.text = str(vista.get("mensaje", "Tómate tu tiempo. Las campanadas solo se gastan al actuar."))
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
			carta.ampliacion_solicitada.connect(mostrar_carta)
		carta.custom_minimum_size = Vector2(ancho_carta, 286)
		fila_cartas.move_child(carta, indice)
		carta.establecer_movimiento_reducido(movimiento_reducido)
		carta.presentar(datos)
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
	var ultima: Dictionary = vista.get("ultima_mano", {})
	boton_desglose.visible = _hay_resultado_revelado()
	if boton_desglose.visible:
		_lectura_titulo.text = "QUIEBRA" if ultima.get("quiebra", false) else "MANO RESUELTA"
		_lectura.text = "%s × %s = %s" % [ultima.get("total", 0), ultima.get("multiplicador", 1), ultima.get("puntos", 0)]
		_lectura.add_theme_font_size_override("font_size", 31)
		var patrones: Array = ultima.get("patrones", [])
		var velas: int = int(ultima.get("velas", 0))
		var resumen := "%s %s · %s %s" % [velas, "Vela" if velas == 1 else "Velas", patrones.size(), "patrón" if patrones.size() == 1 else "patrones"]
		_explicacion.text = "TOTAL > UMBRAL %s\n0 PUNTOS · VER DESGLOSE" % vista.get("umbral", 17) if ultima.get("quiebra", false) else resumen + "\nVER DESGLOSE →"
	else:
		_lectura_titulo.text = "TOTAL POSIBLE" if intervalo.get("ocultas", 0) > 0 else ("SUMA EFECTIVA" if not cartas.is_empty() else "SIGUIENTE PASO")
		_lectura.text = "%s–%s" % [intervalo.get("minimo", 0), intervalo.get("maximo", 0)] if intervalo.get("ocultas", 0) > 0 else (str(intervalo.get("conocido", 0)) if not cartas.is_empty() else "—")
		_lectura.add_theme_font_size_override("font_size", 40)
		_explicacion.text = "UMBRAL %s" % vista.get("umbral", 17)
		if intervalo.get("ocultas", 0) > 0:
			var conocidas := "%s + ?" % intervalo.get("conocido", 0)
			if int(intervalo.get("ocultas", 0)) > 1:
				conocidas += " × %s" % intervalo.get("ocultas", 0)
			var ocultas: int = int(intervalo.get("ocultas", 0))
			_explicacion.text = conocidas + "\nUMBRAL %s · %s %s" % [vista.get("umbral", 17), ocultas, "oculta" if ocultas == 1 else "ocultas"]
	if not _modal.visible:
		var actual := get_viewport().gui_get_focus_owner()
		if terminada or actual == null or not actual.is_visible_in_tree() or (actual is BaseButton and actual.disabled):
			_enfocar_accion_legal()
	if cartas.size() >= 6 and str(cartas.back().get("id", "")) != ultimo_anterior and not _modal.visible:
		_mostrar_ultima_carta(_revision_vista)

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
	var candidatos: Array = [boton_iniciar_pedir, boton_plantarse, boton_llave, boton_reiniciar]
	if vista.get("terminado", false):
		candidatos = [boton_reiniciar]
	for boton in candidatos:
		if not boton.disabled and boton.focus_mode != Control.FOCUS_NONE:
			boton.grab_focus()
			return
	boton_ayuda.grab_focus()

func _enviar(comando: RefCounted) -> void:
	if not is_instance_valid(controlador):
		return
	var resultado = controlador.procesar_comando(comando)
	if not resultado.aceptado:
		_mensaje.text = resultado.motivo

func _iniciar_o_pedir() -> void:
	if boton_iniciar_pedir.disabled:
		return
	if vista.get("fase", "preparado") == "decision":
		_enviar(Pedir.new())
	else:
		_enviar(Iniciar.new())

func _plantarse() -> void:
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
	for estado in ["font_color", "font_hover_color", "font_pressed_color"]:
		boton.add_theme_color_override(estado, TINTA if principal else MARFIL)

func mostrar_ayuda() -> void:
	_abrir_modal("El libro del Custodio")
	_panel_modal.position = Vector2(160, 47)
	_panel_modal.size = Vector2(1120, 716)
	_contenido_modal.size = _panel_modal.size
	var guia := Guia.new()
	guia.name = "Reglamento"
	guia.position = Vector2(32, 100)
	_contenido_modal.add_child(guia)
	guia.movimiento.set_pressed_no_signal(movimiento_reducido)
	guia.movimiento_cambiado.connect(establecer_movimiento_reducido)
	var cerrar := _cerrar_boton()
	cerrar.position = Vector2(278, 649)
	cerrar.size = Vector2(810, 42)
	_etiqueta(_contenido_modal, "REGLAMENTO DE LA CASA", Rect2(32, 650, 220, 39), 12, MUTED)
	guia.navegacion[0].grab_focus()

func establecer_movimiento_reducido(reducido: bool) -> void:
	movimiento_reducido = reducido
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
	var palo := str(carta.get("palo", "mascaras"))
	var nombres := {"velas": "Velas", "llaves": "Llaves", "relojes": "Relojes", "mascaras": "Máscaras"}
	_etiqueta(_contenido_modal, nombres.get(palo, "Carta"), Rect2(350, 144, 370, 58), 40, ORO, true)
	var efectos := {
		"velas": "Cada Vela conservada suma +1 al multiplicador, siempre que la mano no quiebre.",
		"llaves": "Puedes devolver una Llave elegible para recibir otra carta gratis. Solo una vez por mano; el reemplazo se añade al final.",
		"relojes": "Su valor efectivo es el impreso menos uno, con mínimo uno. Pedir un Reloj sigue costando una campanada.",
		"mascaras": "Su valor permanece oculto hasta plantarte. El intervalo usa de 1 a 10 por Máscara y no predice el valor real.",
	}
	var detalle := _etiqueta(_contenido_modal, efectos.get(palo, ""), Rect2(350, 230, 362, 220), 21, MARFIL)
	detalle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var lectura := "VALOR OCULTO · 1–10" if carta.get("oculta", false) else "VALOR EFECTIVO: %s" % carta.get("valor_efectivo", carta.get("valor", "—"))
	_etiqueta(_contenido_modal, lectura, Rect2(350, 489, 362, 65), 18, ORO)
	_cerrar_boton()

func mostrar_devolucion() -> void:
	if boton_llave.disabled:
		return
	var disponibles: Array = vista.get("llaves_disponibles", [])
	if disponibles.is_empty():
		return
	_abrir_modal("DEVOLVER UNA LLAVE")
	var detalle := _etiqueta(_contenido_modal, "Elige una Llave legal de tu mano. El reemplazo se añade al final. Gratis · una vez por mano.\nNo cambia ninguna carta hasta confirmar.", Rect2(32, 113, 696, 112), 20, MARFIL)
	detalle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var opciones := OptionButton.new()
	opciones.name = "LlavesDisponibles"
	opciones.position = Vector2(70, 275)
	opciones.size = Vector2(620, 60)
	_contenido_modal.add_child(opciones)
	var cartas: Array = vista.get("cartas", [])
	for id in disponibles:
		for indice in range(cartas.size()):
			if cartas[indice].get("id") == id:
				opciones.add_item("Llave %s · posición %s de la mano" % [cartas[indice].get("valor", "—"), indice + 1])
				opciones.set_item_metadata(opciones.item_count - 1, id)
	var confirmar := _boton_texto(_contenido_modal, "boton_confirmar_llave", "CONFIRMAR DEVOLUCIÓN · GRATIS", Rect2(70, 420, 620, 60), func() -> void:
		var id: String = str(opciones.get_item_metadata(opciones.selected))
		cerrar_modal()
		_enviar(Devolver.new(id)))
	confirmar.disabled = opciones.item_count == 0
	_estilo_modal(confirmar, true)
	_cerrar_boton("CANCELAR")
	opciones.grab_focus()

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
	match evento.keycode:
		KEY_P: _iniciar_o_pedir()
		KEY_S: _plantarse()
		KEY_L: mostrar_devolucion()
		KEY_H: mostrar_ayuda()
		KEY_R: _solicitar_reinicio()
		_: return
	get_viewport().set_input_as_handled()
