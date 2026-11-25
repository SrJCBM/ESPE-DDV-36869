extends Node2D
## Puerta este del vestíbulo hacia el pasillo del Custodio (I5-10), en el nicho entre dos
## pilastras del arte. Es un vano de latón provisional, como los de los pasillos, hasta que el
## fondo del vestíbulo tenga la puerta dibujada. Sin la invitación lleva candado.

const LETRA := preload("res://recursos/fuentes/DMSans.ttf")
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
	if not abierta:
		var centro := VANO.get_center() + Vector2(-34, 0)
		draw_circle(centro + Vector2(0, 3), 18.0, Color(0.05, 0.06, 0.05, 0.78))
		draw_arc(centro + Vector2(0, -5), 7.0, PI, TAU, 16, APAGADO, 3.0)
		draw_rect(Rect2(centro + Vector2(-10, -5), Vector2(20, 16)), APAGADO)
	draw_string(LETRA, Vector2(1060, 290), "Pasillo del Custodio", HORIZONTAL_ALIGNMENT_RIGHT, 160, 15, ORO if abierta else APAGADO)
