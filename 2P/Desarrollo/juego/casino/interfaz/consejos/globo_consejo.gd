class_name GloboConsejo
extends Control
## Globo del tutorial en contexto: una frase sobre un recuadro dorado que señala con una flecha
## la parte de la pantalla de la que habla, rodeada por un marco que late. No toma el foco ni el
## ratón, así que nunca bloquea una acción; desaparece cuando la persona actúa.

const ORO := Color("d6b25e")
const FONDO := Color(0.04, 0.1, 0.08, 0.96)
const PAPEL := Color("f2e6c8")
const LIENZO := Vector2(1440, 810)
const MARGEN := 10.0
const SEPARACION := 16.0
const FLECHA := 12.0

var id := ""
var texto: Label
var anillo: Panel
var _caja := Rect2()
## Lado del globo respecto a lo que señala: "arriba", "abajo" o "derecha".
var lado := "arriba"
var _punta := Vector2.ZERO
var _latido: Tween

func _init() -> void:
	name = "GloboConsejo"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	size = LIENZO
	z_index = 20
	anillo = Panel.new()
	anillo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var borde := StyleBoxFlat.new()
	borde.bg_color = Color.TRANSPARENT
	borde.border_color = ORO
	borde.set_border_width_all(3)
	borde.set_corner_radius_all(8)
	anillo.add_theme_stylebox_override("panel", borde)
	add_child(anillo)
	texto = Label.new()
	texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.add_theme_font_override("font", preload("res://recursos/fuentes/DMSans.ttf"))
	texto.add_theme_font_size_override("font_size", 21)
	texto.add_theme_color_override("font_color", PAPEL)
	add_child(texto)
	hide()

## Muestra `frase` señalando `objetivo`, un rectángulo en las coordenadas de este globo, que
## queda enmarcado. `ancla` (si no está vacía) es la parte a la que apunta la flecha, para no
## tapar un título; con `a_la_derecha`, el globo se pone a su derecha.
func senalar(nuevo_id: String, frase: String, objetivo: Rect2, reducido := false, ancla := Rect2(), a_la_derecha := false) -> void:
	var punto := objetivo if ancla.size == Vector2.ZERO else ancla
	id = nuevo_id
	texto.text = frase
	accessibility_name = "Consejo: " + frase
	var fuente := texto.get_theme_font("font")
	var ancho := minf(fuente.get_string_size(frase, HORIZONTAL_ALIGNMENT_LEFT, -1, 21).x + 44.0, LIENZO.x - 2 * MARGEN)
	var alto := 54.0
	var x: float
	var y: float
	if a_la_derecha and punto.end.x + SEPARACION + ancho <= LIENZO.x - MARGEN:
		lado = "derecha"
		x = punto.end.x + SEPARACION
		y = clampf(punto.get_center().y - alto * 0.5, MARGEN, LIENZO.y - alto - MARGEN)
		_punta = Vector2(punto.end.x + SEPARACION - FLECHA, clampf(punto.get_center().y, y + 14.0, y + alto - 14.0))
	else:
		lado = "arriba" if punto.position.y - SEPARACION - alto >= MARGEN else "abajo"
		y = punto.position.y - SEPARACION - alto if lado == "arriba" else punto.end.y + SEPARACION
		y = clampf(y, MARGEN, LIENZO.y - alto - MARGEN)
		x = clampf(punto.get_center().x - ancho * 0.5, MARGEN, LIENZO.x - ancho - MARGEN)
		var px := clampf(punto.get_center().x, x + 20.0, x + ancho - 20.0)
		_punta = Vector2(px, y + alto + FLECHA) if lado == "arriba" else Vector2(px, y - FLECHA)
	_caja = Rect2(x, y, ancho, alto)
	texto.position = _caja.position
	texto.size = _caja.size
	anillo.position = objetivo.position - Vector2(6, 6)
	anillo.size = objetivo.size + Vector2(12, 12)
	show()
	queue_redraw()
	if _latido != null and _latido.is_valid():
		_latido.kill()
	modulate.a = 1.0
	anillo.modulate.a = 1.0
	if not reducido:
		modulate.a = 0.0
		_latido = create_tween()
		_latido.tween_property(self, "modulate:a", 1.0, 0.25)
		_latido.tween_callback(func() -> void:
			_latido = create_tween().set_loops()
			_latido.tween_property(anillo, "modulate:a", 0.35, 0.7).set_trans(Tween.TRANS_SINE)
			_latido.tween_property(anillo, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE))

func ocultar() -> void:
	if _latido != null and _latido.is_valid():
		_latido.kill()
	id = ""
	hide()

func _draw() -> void:
	if _caja.size == Vector2.ZERO:
		return
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = FONDO
	estilo.border_color = ORO
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(6)
	estilo.shadow_color = Color(0, 0, 0, 0.5)
	estilo.shadow_size = 8
	draw_style_box(estilo, _caja)
	var flecha: PackedVector2Array
	if lado == "derecha":
		var bx := _caja.position.x
		flecha = PackedVector2Array([Vector2(bx, _punta.y - FLECHA), Vector2(bx, _punta.y + FLECHA), _punta])
	else:
		var by := _caja.end.y if lado == "arriba" else _caja.position.y
		flecha = PackedVector2Array([Vector2(_punta.x - FLECHA, by), Vector2(_punta.x + FLECHA, by), _punta])
	draw_colored_polygon(flecha, ORO)
