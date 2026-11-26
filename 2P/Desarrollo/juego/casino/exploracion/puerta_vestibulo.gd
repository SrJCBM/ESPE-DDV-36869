extends Node2D
## Puerta este del vestíbulo, situada en el nicho entre dos pilastras.

const ORO := Color("cfaa64")
const APAGADO := Color("8e887c")
const VANO := Rect2(1226, 300, 40, 112)

var abierta := false

func _draw() -> void:
	draw_rect(VANO.grow(6), Color("2a1a10"))
	draw_rect(VANO, Color("120c08"))
	if abierta:
		# Una franja de luz cálida por la rendija: por aquí sigue el recorrido.
		draw_rect(Rect2(VANO.position.x + 2, VANO.position.y + 4, 6, VANO.size.y - 8), Color(0.95, 0.78, 0.45, 0.55))
	draw_rect(VANO.grow(6), ORO if abierta else APAGADO, false, 3.0)
	draw_line(Vector2(VANO.position.x - 6, VANO.position.y), Vector2(VANO.end.x + 6, VANO.position.y), Color("e2c27e"), 2.0)
