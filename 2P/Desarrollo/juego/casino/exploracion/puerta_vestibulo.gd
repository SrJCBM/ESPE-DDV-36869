extends Node2D
## Puerta este del vestíbulo, dentro del nicho entre las dos pilastras del fondo (I6-09): se
## dibuja como un hueco en el muro, entre las molduras de latón, sin marco que sobresalga.

const ORO := Color("cfaa64")
const APAGADO := Color("6f6a5f")
## Hueco del nicho en el arte del vestíbulo: entre la moldura superior (y ≈ 305) y la inferior
## (y ≈ 400), y entre la cara de las pilastras y el muro (x ≈ 1233–1262).
const VANO := Rect2(1235, 309, 26, 88)

var abierta := false

func _draw() -> void:
	# Jamba en sombra del lado del vestíbulo: el muro tiene grosor y la puerta queda dentro.
	var jamba := PackedVector2Array([VANO.position, VANO.position + Vector2(5, 4), Vector2(VANO.position.x + 5, VANO.end.y - 3), Vector2(VANO.position.x, VANO.end.y)])
	draw_rect(VANO, Color("120c08"))
	draw_colored_polygon(jamba, Color("070504"))
	if abierta:
		# Una franja de luz cálida por la rendija: por aquí sigue el recorrido.
		draw_rect(Rect2(VANO.position.x + 7, VANO.position.y + 6, 4, VANO.size.y - 12), Color(0.95, 0.78, 0.45, 0.6))
	draw_rect(VANO, ORO if abierta else APAGADO, false, 1.5)
