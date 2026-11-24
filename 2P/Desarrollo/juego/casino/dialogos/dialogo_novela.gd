extends Control
## Presentación compartida de las conversaciones (I4-06), sobre el fondo de la sala: retrato,
## cuadro inferior con nombre e intervención y respuestas encima del cuadro.
## Clic, Enter o E avanzan; si la línea se está escribiendo, la primera pulsación la completa.
## Esc cierra sin aplicar nada. Con movimiento reducido el texto aparece completo.
## No conoce el juego: las condiciones las evalúa `evaluar`, las solicitudes se emiten y
## `describir` (opcional) completa una opción con {"icono", "detalle"}.

signal solicitud(id: String)
signal cerrado

const Libro := preload("res://casino/interfaz/libro.gd")
const BASE := Vector2(1440, 810)
const VELOCIDAD := 55.0 ## Caracteres por segundo.
const CAJA := Rect2(140, 600, 1160, 180)
const RETRATO := Rect2(150, 150, 360, 470)
const MUTED := Color("b9ad91")

var conversacion: Conversacion
var evaluar: Callable
var describir: Callable
var reducido := false
var actual := ""
var retrato: TextureRect
var marco_retrato: Panel
var nombre: Label
var texto: Label
var indicacion: Label
var respuestas: VBoxContainer
var botones: Array[Button] = []
var _opciones: Array = []
var _escritos := 0.0

func _ready() -> void:
	name = "DialogoNovela"
	size = BASE
	mouse_filter = Control.MOUSE_FILTER_STOP
	var sombra := ColorRect.new()
	sombra.color = Color(0.01, 0.03, 0.02, 0.45)
	sombra.size = BASE
	sombra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sombra)
	marco_retrato = Panel.new()
	marco_retrato.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marco_retrato.add_theme_stylebox_override("panel", Libro.caja(Color("06120e"), Libro.ORO))
	add_child(marco_retrato)
	retrato = TextureRect.new()
	retrato.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	retrato.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	retrato.position = RETRATO.position
	retrato.size = RETRATO.size
	retrato.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(retrato)
	var caja := Panel.new()
	caja.position = CAJA.position
	caja.size = CAJA.size
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.add_theme_stylebox_override("panel", Libro.caja(Color(0.04, 0.11, 0.09, 0.96), Libro.ORO))
	add_child(caja)
	var placa := Panel.new()
	placa.position = CAJA.position + Vector2(30, -24)
	placa.size = Vector2(280, 46)
	placa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	placa.add_theme_stylebox_override("panel", Libro.caja(Color("19392f"), Libro.ORO))
	add_child(placa)
	nombre = Libro.rotulo("", 27, Libro.PAPEL, true)
	nombre.position = placa.position + Vector2(18, 4)
	nombre.size = Vector2(250, 38)
	add_child(nombre)
	texto = Libro.rotulo("", 22, Libro.PAPEL)
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	texto.position = CAJA.position + Vector2(36, 38)
	texto.size = Vector2(CAJA.size.x - 72, 104)
	add_child(texto)
	indicacion = Libro.rotulo("E · continuar", 14, MUTED)
	indicacion.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	indicacion.position = CAJA.end - Vector2(236, 34)
	indicacion.size = Vector2(210, 22)
	add_child(indicacion)
	respuestas = VBoxContainer.new()
	respuestas.add_theme_constant_override("separation", 8)
	respuestas.position = Vector2(CAJA.end.x - 520, CAJA.position.y - 20)
	respuestas.size = Vector2(520, 0)
	add_child(respuestas)
	hide()

## Abre la conversación en la entrada que corresponda al progreso. false si no hay ninguna.
func abrir(datos: Conversacion, condicion: Callable, movimiento_reducido := false, descripcion := Callable()) -> bool:
	conversacion = datos
	evaluar = condicion
	describir = descripcion
	reducido = movimiento_reducido
	var inicio := conversacion.inicio(evaluar)
	if inicio.is_empty():
		return false
	show()
	_mostrar(inicio)
	return true

func escribiendo() -> bool:
	return visible and texto.visible_characters >= 0

func _mostrar(id: String) -> void:
	actual = id
	var ruta := conversacion.retrato(id)
	retrato.texture = load(ruta) if not ruta.is_empty() else null
	_encuadrar_retrato()
	nombre.text = conversacion.nombre(id)
	texto.text = str(conversacion.intervencion(id).get("texto", ""))
	_opciones = conversacion.opciones(id, evaluar)
	for boton in botones:
		respuestas.remove_child(boton)
		boton.queue_free()
	botones.clear()
	indicacion.hide()
	_escritos = 0.0
	texto.visible_characters = 0
	if reducido:
		completar()

## El retrato conserva su proporción, apoyado sobre el cuadro y con un filo de latón.
func _encuadrar_retrato() -> void:
	marco_retrato.visible = retrato.texture != null
	if retrato.texture == null:
		return
	var proporcion := retrato.texture.get_size()
	var escala := minf(RETRATO.size.x / proporcion.x, RETRATO.size.y / proporcion.y)
	var medida := proporcion * escala
	retrato.size = medida
	retrato.position = Vector2(RETRATO.position.x, RETRATO.end.y - medida.y)
	marco_retrato.position = retrato.position - Vector2(4, 4)
	marco_retrato.size = medida + Vector2(8, 8)

## Muestra la línea entera y, después, sus respuestas o la indicación para seguir.
func completar() -> void:
	texto.visible_characters = -1
	if _opciones.is_empty():
		indicacion.text = "E · continuar" if not conversacion.siguiente(actual).is_empty() else "E · cerrar"
		indicacion.show()
		return
	for indice in _opciones.size():
		var boton := Button.new()
		boton.text = str(_opciones[indice].get("texto", ""))
		boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
		boton.custom_minimum_size = Vector2(520, 44)
		var extra: Dictionary = describir.call(_opciones[indice]) if describir.is_valid() else {}
		if not str(extra.get("detalle", "")).is_empty():
			# Nombre y efecto en una línea cada uno, con el icono del objeto a la izquierda.
			boton.text += "\n" + str(extra.detalle)
			boton.custom_minimum_size.y = 66
			boton.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if ResourceLoader.exists(str(extra.get("icono", ""))):
			boton.icon = load(str(extra.icono))
			boton.expand_icon = true
			boton.add_theme_constant_override("icon_max_width", 50)
			boton.add_theme_constant_override("h_separation", 12)
		boton.add_theme_font_override("font", Libro.SANS)
		boton.add_theme_font_size_override("font_size", 18)
		boton.add_theme_color_override("font_color", Libro.PAPEL)
		boton.add_theme_stylebox_override("normal", Libro.caja(Color("19392f"), Color("645c44")))
		boton.add_theme_stylebox_override("hover", Libro.caja(Color("2c493b"), Libro.ORO))
		boton.add_theme_stylebox_override("focus", Libro.caja(Color("2c493b"), Libro.PAPEL))
		boton.pressed.connect(elegir.bind(indice))
		respuestas.add_child(boton)
		botones.append(boton)
	respuestas.reset_size()
	respuestas.position.y = CAJA.position.y - 34 - respuestas.size.y
	botones[0].grab_focus()

func _process(delta: float) -> void:
	if not escribiendo():
		return
	_escritos += delta * VELOCIDAD
	texto.visible_characters = int(_escritos)
	if texto.visible_characters >= texto.get_total_character_count():
		completar()

## Clic, Enter o E: completa la línea, pasa a la siguiente o cierra. Con respuestas, espera.
func avanzar() -> void:
	if escribiendo():
		completar()
	elif not _opciones.is_empty():
		return
	elif conversacion.siguiente(actual).is_empty():
		cerrar()
	else:
		_mostrar(conversacion.siguiente(actual))

func elegir(indice: int) -> void:
	if indice < 0 or indice >= _opciones.size() or escribiendo():
		return
	var opcion: Dictionary = _opciones[indice]
	if not str(opcion.get("solicitud", "")).is_empty():
		solicitud.emit(str(opcion.solicitud))
	var destino := str(opcion.get("ir", ""))
	if destino.is_empty():
		cerrar()
	else:
		_mostrar(destino)

func cerrar() -> void:
	if not visible:
		return
	hide()
	cerrado.emit()

func _gui_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_LEFT:
		avanzar()
		accept_event()

func _unhandled_key_input(evento: InputEvent) -> void:
	if not visible or not evento is InputEventKey or not evento.pressed or evento.echo:
		return
	if evento.keycode == KEY_ESCAPE:
		cerrar()
	elif evento.is_action_pressed("interactuar") or evento.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
		var foco := get_viewport().gui_get_focus_owner()
		if foco in botones and not escribiendo():
			elegir(botones.find(foco))
		else:
			avanzar()
	get_viewport().set_input_as_handled()
