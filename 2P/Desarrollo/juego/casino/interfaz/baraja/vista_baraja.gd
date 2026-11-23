extends Control
## «Ver baraja» (I5). Consulta de solo lectura de la baraja del intento: el total, un resumen
## por palo y por valor, y las cartas en una fila por palo, ordenadas por valor. Señala las
## cartas ganadas, las ajustadas, la Vela de Racha ×2 y las retiradas en la tienda.
##
## Recibe datos ya filtrados por el casino: nunca ve el orden del mazo y, durante una mano,
## las Máscaras llegan boca abajo. Se abre desde el inventario en exploración o en la pausa;
## Esc, Enter o «Volver» la cierran y el casino devuelve el foco a donde estaba.

signal cerrada

const Libro := preload("res://casino/interfaz/libro.gd")
const Carta := preload("res://cartas/carta.tscn")
const ARTE := preload("res://cartas/carta_ui.gd").ARTE
const BASE := Vector2(1440, 810)
const MARCO := Rect2(60, 50, 1320, 710)
const FILAS := Rect2(520, 150, 830, 520) ## Zona de las cuatro filas de cartas.
const CARTA := Vector2(96, 112)
const ALTO_FILA := 130.0
const MUTED := Color("b9ad91")
const VERDE := Color("9fc7a2")

var lienzo := Control.new()
var titulo: Label
var total: Label
var resumen: VBoxContainer
var valores: VBoxContainer
var filas: Array[HBoxContainer] = []
var boton_volver: Button
var cartas: Array[Button] = []
var _ultimos: Dictionary = {}

func _ready() -> void:
	name = "VistaBaraja"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var sombra := ColorRect.new()
	sombra.color = Color(0.01, 0.03, 0.02, 0.78)
	sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sombra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sombra)
	lienzo.size = BASE
	lienzo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lienzo)
	var panel := Panel.new()
	panel.position = MARCO.position
	panel.size = MARCO.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", Libro.caja(Color(0.06, 0.145, 0.12, 0.98), Libro.ORO))
	lienzo.add_child(panel)
	# Pestaña del título, como el rótulo «Baraja completa» de la referencia.
	var pestana := Panel.new()
	pestana.position = Vector2(560, 28)
	pestana.size = Vector2(320, 56)
	pestana.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pestana.add_theme_stylebox_override("panel", Libro.caja(Color("19392f"), Libro.ORO))
	lienzo.add_child(pestana)
	titulo = Libro.rotulo("Tu baraja", 32, Libro.PAPEL, true)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = pestana.position + Vector2(0, 6)
	titulo.size = Vector2(pestana.size.x, 44)
	lienzo.add_child(titulo)
	# Columna izquierda: total y resumen por palo, ganadas, ajustes y retiros.
	var caja := Panel.new()
	caja.position = Vector2(90, 110)
	caja.size = Vector2(310, 560)
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.add_theme_stylebox_override("panel", Libro.caja(Color("0b1c17"), Color("645c44")))
	lienzo.add_child(caja)
	total = Libro.rotulo("", 30, Libro.PAPEL, true)
	total.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	total.position = caja.position + Vector2(10, 12)
	total.size = Vector2(caja.size.x - 20, 40)
	lienzo.add_child(total)
	resumen = VBoxContainer.new()
	resumen.position = caja.position + Vector2(22, 66)
	resumen.size = Vector2(caja.size.x - 44, caja.size.y - 80)
	resumen.add_theme_constant_override("separation", 6)
	lienzo.add_child(resumen)
	# Columna de valores: cuántas cartas hay de cada valor impreso.
	valores = VBoxContainer.new()
	valores.position = Vector2(420, 112)
	valores.size = Vector2(80, 556)
	valores.add_theme_constant_override("separation", 1)
	lienzo.add_child(valores)
	var fondo_filas := Panel.new()
	fondo_filas.position = FILAS.position - Vector2(12, 40)
	fondo_filas.size = FILAS.size + Vector2(24, 52)
	fondo_filas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo_filas.add_theme_stylebox_override("panel", Libro.caja(Color("0b1c17"), Color("645c44")))
	lienzo.add_child(fondo_filas)
	for indice in Palos.TODOS.size():
		var fila := HBoxContainer.new()
		fila.position = FILAS.position + Vector2(0, indice * ALTO_FILA)
		fila.size = Vector2(FILAS.size.x, CARTA.y)
		fila.theme = preload("res://temas/mesa.tres")
		lienzo.add_child(fila)
		filas.append(fila)
	boton_volver = Button.new()
	boton_volver.text = "Volver"
	boton_volver.position = Vector2(90, 688)
	boton_volver.size = Vector2(1260, 50)
	boton_volver.add_theme_font_override("font", Libro.SANS)
	boton_volver.add_theme_font_size_override("font_size", 20)
	boton_volver.add_theme_color_override("font_color", Libro.PAPEL)
	boton_volver.add_theme_stylebox_override("normal", Libro.caja(Color("19392f"), Color("645c44")))
	boton_volver.add_theme_stylebox_override("hover", Libro.caja(Color("2c493b"), Libro.ORO))
	boton_volver.add_theme_stylebox_override("focus", Libro.caja(Color("2c493b"), Libro.PAPEL))
	boton_volver.pressed.connect(cerrar)
	lienzo.add_child(boton_volver)
	resized.connect(_adaptar)
	_adaptar()
	hide()

func _adaptar() -> void:
	var escala := minf(size.x / BASE.x, size.y / BASE.y)
	lienzo.scale = Vector2.ONE * escala
	lienzo.position = (size - BASE * escala) * 0.5

## datos: {"cartas": [{palo, valor, valor_efectivo, oculta, rasgo, nota, ganada, ajuste}],
## "retiradas": [{palo, valor}], "en_mano": bool}.
func presentar(datos: Dictionary) -> void:
	_ultimos = datos
	var lista: Array = datos.get("cartas", [])
	var retiradas: Array = datos.get("retiradas", [])
	total.text = "%s cartas" % lista.size()
	_limpiar(resumen)
	_limpiar(valores)
	for carta in cartas:
		carta.get_parent().remove_child(carta)
		carta.queue_free()
	cartas.clear()
	var por_palo := {}
	var por_valor := {}
	var ganadas := 0
	var ajustadas := 0
	var ocultas := 0
	var dobles := 0
	for palo in Palos.TODOS: por_palo[palo] = []
	for datos_carta: Dictionary in lista:
		por_palo[datos_carta.palo].append(datos_carta)
		if datos_carta.get("oculta", false): ocultas += 1
		else: por_valor[int(datos_carta.valor)] = int(por_valor.get(int(datos_carta.valor), 0)) + 1
		if datos_carta.get("ganada", false): ganadas += 1
		if int(datos_carta.get("ajuste", 0)) != 0: ajustadas += 1
		if datos_carta.get("rasgo", "") == CartaEnPartida.RASGO_RACHA_DOBLE: dobles += 1
	for palo: String in Palos.TODOS:
		resumen.add_child(_fila_palo(palo, por_palo[palo].size()))
	resumen.add_child(_separador())
	resumen.add_child(_linea("Ganadas como recompensa: %s" % ganadas, VERDE if ganadas else MUTED))
	resumen.add_child(_linea("Con el valor ajustado: %s" % ajustadas, Libro.ORO if ajustadas else MUTED))
	if dobles:
		resumen.add_child(_linea("Velas de Racha ×2: %s · cuentan como dos cartas para Racha" % dobles, Libro.ORO))
	var texto_retiros := "Retiradas en la tienda: %s" % retiradas.size()
	if not retiradas.is_empty():
		var nombres := PackedStringArray()
		for retirada: Dictionary in retiradas:
			nombres.append("%s de %s" % [retirada.valor, Palos.NOMBRES.get(retirada.palo, "")])
		texto_retiros += "\n" + ", ".join(nombres)
	resumen.add_child(_linea(texto_retiros, MUTED))
	if datos.get("en_mano", false):
		resumen.add_child(_separador())
		resumen.add_child(_linea("Mano en curso: las Máscaras se muestran boca abajo y la baraja no sigue el orden del mazo.", MUTED))
	for valor in range(10, 0, -1):
		valores.add_child(_cuenta(str(valor), int(por_valor.get(valor, 0))))
	if ocultas:
		valores.add_child(_cuenta("?", ocultas))
	for indice in Palos.TODOS.size():
		_llenar_fila(filas[indice], por_palo[Palos.TODOS[indice]])

func abrir(datos: Dictionary) -> void:
	presentar(datos)
	show()
	boton_volver.grab_focus()

func cerrar() -> void:
	if not visible:
		return
	hide()
	cerrada.emit()

## Una fila por palo, de menor a mayor valor. Si no caben, las cartas se solapan.
func _llenar_fila(fila: HBoxContainer, lista: Array) -> void:
	lista.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.get("oculta", false) != b.get("oculta", false): return b.get("oculta", false)
		if a.get("oculta", false): return false
		return int(a.valor) < int(b.valor))
	var n := lista.size()
	var separacion := 8.0 if n < 2 else minf(8.0, (FILAS.size.x - n * CARTA.x) / (n - 1))
	fila.add_theme_constant_override("separation", int(separacion))
	for datos_carta: Dictionary in lista:
		var carta := Carta.instantiate() as Button
		carta.custom_minimum_size = CARTA
		carta.focus_mode = Control.FOCUS_NONE
		fila.add_child(carta)
		carta.establecer_movimiento_reducido(true)
		carta.presentar(datos_carta)
		carta.set_meta("datos", datos_carta)
		cartas.append(carta)

func _fila_palo(palo: String, cantidad: int) -> HBoxContainer:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 12)
	var icono := TextureRect.new()
	icono.texture = ARTE[palo]
	icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icono.custom_minimum_size = Vector2(34, 34)
	fila.add_child(icono)
	var nombre := Libro.rotulo(Palos.NOMBRES[palo], 20, Libro.PAPEL)
	nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(nombre)
	fila.add_child(Libro.rotulo(str(cantidad), 22, Libro.ORO, true))
	return fila

func _linea(texto: String, color: Color) -> Label:
	var etiqueta := Libro.rotulo(texto, 15, color)
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta.custom_minimum_size.x = resumen.size.x
	return etiqueta

func _cuenta(valor: String, cantidad: int) -> HBoxContainer:
	var fila := HBoxContainer.new()
	var marca := Libro.rotulo(valor, 18, Libro.PAPEL, true)
	marca.custom_minimum_size.x = 36
	fila.add_child(marca)
	fila.add_child(Libro.rotulo(str(cantidad), 18, Libro.ORO if cantidad else MUTED))
	return fila

func _separador() -> Control:
	var espacio := Control.new()
	espacio.custom_minimum_size.y = 6
	return espacio

func _limpiar(nodo: Node) -> void:
	for hijo in nodo.get_children():
		nodo.remove_child(hijo)
		hijo.queue_free()

func _gui_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and evento.pressed:
		accept_event()

func _unhandled_key_input(evento: InputEvent) -> void:
	if not visible or not evento is InputEventKey or not evento.pressed or evento.echo:
		return
	if evento.keycode in [KEY_ESCAPE, KEY_B]:
		cerrar()
	elif evento.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E]:
		boton_volver.pressed.emit()
	get_viewport().set_input_as_handled()
