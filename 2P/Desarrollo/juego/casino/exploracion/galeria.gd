extends Node2D
## El fondo ya contiene las puertas y los umbrales de cada pasillo.

const FONDOS := {
	"pasillo_custodio": preload("res://casino/arte/pasillo_custodio.webp"),
	"pasillo_recaudador": preload("res://casino/arte/pasillo_recaudador.webp"),
	"pasillo_coleccionista": preload("res://casino/arte/pasillo_coleccionista.webp"),
	"pasillo_dueno": preload("res://casino/arte/pasillo_dueno.webp"),
}

var pasillo := "pasillo_custodio"

func _draw() -> void:
	draw_texture_rect(FONDOS[pasillo], Rect2(0, 0, 1280, 720), false)
