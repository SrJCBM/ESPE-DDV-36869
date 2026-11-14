extends Control
## Filetes y esquinas del mobiliario del Custodio; no captura entrada.

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var oro := Color("a78b58")
	var inset := 10.0
	for esquina in [Vector2(inset, inset), Vector2(size.x - inset, inset), Vector2(inset, size.y - inset), Vector2(size.x - inset, size.y - inset)]:
		var direccion := Vector2(1 if esquina.x < size.x / 2 else -1, 1 if esquina.y < size.y / 2 else -1)
		draw_line(esquina, esquina + Vector2(34 * direccion.x, 0), oro, 1.0, true)
		draw_line(esquina, esquina + Vector2(0, 34 * direccion.y), oro, 1.0, true)
		draw_line(esquina + Vector2(7 * direccion.x, 0), esquina + Vector2(0, 7 * direccion.y), oro, 1.0, true)
	draw_line(Vector2(32, 83), Vector2(size.x - 32, 83), Color("526043"), 1.0, true)
	draw_line(Vector2(32, size.y - 83), Vector2(size.x - 32, size.y - 83), Color("526043"), 1.0, true)
