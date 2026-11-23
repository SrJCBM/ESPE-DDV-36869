extends Control
## Punto de entrada del encuentro local del Custodio.

func _ready() -> void:
	get_window().min_size = Vector2i(1024, 576)
	var audio := AudioCasino.new()
	add_child(audio)
	$Mesa.activar_audio(audio)
	$Mesa.establecer_movimiento_reducido(AjustesJuego.movimiento_reducido())
