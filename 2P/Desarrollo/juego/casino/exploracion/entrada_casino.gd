extends Node2D
## La fachada de Corvera se usa también como fondo de la llegada en el prólogo.

const FACHADA := preload("res://historia/ilustraciones/fachada_casa.webp")
const UMBRAL := Vector2(640, 415)
const FAROLA := Vector2(270, 424)

func _draw() -> void:
	draw_texture_rect(FACHADA, Rect2(0, 0, 1280, 720), false)
