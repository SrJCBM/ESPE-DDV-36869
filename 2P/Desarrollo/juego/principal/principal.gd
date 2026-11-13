extends Control
## Escena principal mínima de la base I1-00.
## Solo identifica la base; no contiene reglas ni interfaz del juego.

const ETIQUETA_BASE := "I1-00"


func _ready() -> void:
	$Contenedor/Titulo.text = "La Última Mesa"
	$Contenedor/Subtitulo.text = "Base común %s" % ETIQUETA_BASE
