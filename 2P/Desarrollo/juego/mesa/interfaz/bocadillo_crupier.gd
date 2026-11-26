extends Control
## Bocadillo de reacción del crupier junto a su retrato (I6-10). No recibe clics ni foco: la
## mano sigue en manos del jugador. Desaparece a los 3 s o con la siguiente acción.

const Piezas := preload("res://mesa/piezas_mesa.gd")
const DURACION := 3.0
const ANCHO := 336.0

var nombre: Label
var texto: Label
var _fondo: Panel
var _cola: Polygon2D
var _restante := 0.0

func _ready() -> void:
	name = "BocadilloCrupier"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	_fondo = Panel.new()
	_fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.95, 0.9, 0.79, 0.97)
	estilo.border_color = Piezas.ORO
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(6)
	_fondo.add_theme_stylebox_override("panel", estilo)
	add_child(_fondo)
	_cola = Polygon2D.new()
	_cola.color = estilo.bg_color
	add_child(_cola)
	nombre = Piezas.etiqueta(self, "", Rect2(14, 8, ANCHO - 28, 18), 12, Color("6b5426"))
	texto = Piezas.etiqueta(self, "", Rect2(14, 26, ANCHO - 28, 40), 16, Color("1d2a22"))
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hide()

## Muestra la línea del crupier; la anterior se sustituye.
func mostrar(quien: String, linea: String) -> void:
	nombre.text = quien.to_upper()
	texto.size = Vector2(ANCHO - 28, 0)
	texto.text = linea
	var alto := float(texto.get_line_count() * texto.get_line_height() + 4)
	texto.size.y = alto
	size = Vector2(ANCHO, 26 + alto + 12)
	_fondo.size = size
	# La cola apunta hacia abajo, hacia el rostro del retrato.
	_cola.polygon = PackedVector2Array([Vector2(ANCHO * 0.38, size.y - 1), Vector2(ANCHO * 0.38 + 22, size.y - 1), Vector2(ANCHO * 0.38 + 6, size.y + 14)])
	_restante = DURACION
	show()

func ocultar() -> void:
	_restante = 0.0
	hide()

func _process(delta: float) -> void:
	if not visible:
		return
	_restante -= delta
	if _restante <= 0.0:
		hide()
