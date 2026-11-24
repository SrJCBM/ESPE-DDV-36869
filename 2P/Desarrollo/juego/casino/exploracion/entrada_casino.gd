extends Node2D
## Entrada al casino (I5), arte provisional dibujado con primitivas hasta tener la fachada:
## calle de noche, fachada con el rótulo y la puerta iluminada al norte. Lienzo de 1280 × 720.

const SERIF := preload("res://recursos/fuentes/CormorantGaramond.ttf")
const ORO := Color("cfaa64")
const PUERTA := Rect2(580, 142, 120, 156) ## Hoja de la puerta, sobre el escalón.

func _draw() -> void:
	# Cielo en franjas, de negro verdoso a verde profundo.
	for franja in range(8):
		draw_rect(Rect2(0, franja * 12, 1280, 12), Color("06100d").lerp(Color("10241d"), franja / 7.0))
	for estrella: Vector2 in [Vector2(90, 30), Vector2(240, 60), Vector2(410, 22), Vector2(880, 40), Vector2(1030, 18), Vector2(1190, 64)]:
		draw_circle(estrella, 1.6, Color("f4e5c8"))
	# Fachada de piedra con pilastras y cornisa de latón.
	draw_rect(Rect2(160, 70, 960, 250), Color("1d2b25"))
	for x in [160.0, 400.0, 840.0, 1080.0]:
		draw_rect(Rect2(x, 70, 40, 250), Color("26372f"))
	draw_rect(Rect2(150, 62, 980, 14), ORO.darkened(0.35))
	draw_string(SERIF, Vector2(160, 104), "LA ÚLTIMA MESA", HORIZONTAL_ALIGNMENT_CENTER, 960, 34, ORO)
	# Ventanas apagadas a los lados.
	for x in [250.0, 470.0, 760.0, 960.0]:
		draw_rect(Rect2(x, 150, 60, 90), Color("0b1512"))
		draw_rect(Rect2(x, 150, 60, 90), ORO.darkened(0.55), false, 2.0)
	# Puerta con luz cálida y su reflejo en la acera.
	draw_rect(PUERTA.grow(10), Color("2a1a10"))
	draw_rect(PUERTA, Color(1.0, 0.78, 0.45, 0.85))
	draw_line(Vector2(PUERTA.get_center().x, PUERTA.position.y), Vector2(PUERTA.get_center().x, PUERTA.end.y), Color("2a1a10"), 4.0)
	draw_rect(PUERTA.grow(10), ORO, false, 3.0)
	draw_rect(Rect2(540, 300, 200, 24), Color("3a3328"))
	# Acera y calle.
	draw_rect(Rect2(0, 320, 1280, 400), Color("16201c"))
	for fila in range(6):
		draw_line(Vector2(0, 360 + fila * 60), Vector2(1280, 360 + fila * 60), Color("1f2b26"), 2.0)
	for radio in [220.0, 160.0, 100.0]:
		draw_set_transform(Vector2(640, 340), 0.0, Vector2(1.0, 0.3))
		draw_circle(Vector2.ZERO, radio, Color(1.0, 0.8, 0.45, 0.05))
	draw_set_transform(Vector2.ZERO)
	# Farolas.
	for x in [300.0, 980.0]:
		draw_rect(Rect2(x - 4, 250, 8, 320), Color("0e1512"))
		draw_circle(Vector2(x, 246), 14.0, Color(1.0, 0.85, 0.55, 0.9))
		draw_circle(Vector2(x, 246), 34.0, Color(1.0, 0.85, 0.55, 0.12))
