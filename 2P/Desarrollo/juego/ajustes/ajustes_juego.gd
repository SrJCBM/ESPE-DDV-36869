class_name AjustesJuego
extends RefCounted
## Preferencias que se conservan entre sesiones, como pide el documento de diseño.
## La campaña no se guarda: cerrar el juego sigue reiniciando el intento.
## Sin Autoload: las mesas y las pruebas no dependen de un estado global; solo los puntos de entrada lo leen.

## Las pruebas la redirigen a otro archivo para no tocar las preferencias de quien juega.
static var ruta := "user://ajustes.cfg"

static func movimiento_reducido() -> bool:
	var archivo := ConfigFile.new()
	if archivo.load(ruta) != OK:
		return false
	return bool(archivo.get_value("accesibilidad", "movimiento_reducido", false))

static func guardar_movimiento_reducido(reducido: bool) -> void:
	var archivo := ConfigFile.new()
	archivo.load(ruta) # Conserva las demás preferencias si el archivo ya existe.
	archivo.set_value("accesibilidad", "movimiento_reducido", reducido)
	archivo.save(ruta)
