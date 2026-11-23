extends VBoxContainer
## Opciones del menú (I4-07): volumen por canal y movimiento reducido. Ambas se guardan en
## AjustesJuego y se conservan entre sesiones.

signal movimiento_cambiado(reducido: bool)

const Libro := preload("res://casino/interfaz/libro.gd")

var movimiento: CheckButton

func construir(audio: AudioCasino) -> void:
	add_theme_constant_override("separation", 16)
	if audio != null:
		var sonido := ControlesSonido.new()
		add_child(sonido)
		sonido.construir(audio)
	movimiento = CheckButton.new()
	movimiento.text = "Movimiento reducido"
	movimiento.button_pressed = AjustesJuego.movimiento_reducido()
	movimiento.add_theme_font_override("font", Libro.SANS)
	movimiento.add_theme_font_size_override("font_size", 18)
	movimiento.add_theme_color_override("font_color", Libro.PAPEL)
	movimiento.toggled.connect(_cambiar)
	add_child(movimiento)

func _cambiar(reducido: bool) -> void:
	AjustesJuego.guardar_movimiento_reducido(reducido)
	movimiento_cambiado.emit(reducido)
