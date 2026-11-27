class_name AjustesJuego
extends RefCounted
## Preferencias que se conservan entre sesiones, como pide el documento de diseño.
## La campaña se guarda aparte, en PartidaGuardada (I5).
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

static func volumen(canal: StringName, predeterminado: int) -> int:
	var archivo := ConfigFile.new()
	archivo.load(ruta)
	return clampi(int(archivo.get_value("audio", str(canal), predeterminado)), 0, 100)

static func guardar_volumen(canal: StringName, nivel: int) -> void:
	var archivo := ConfigFile.new()
	archivo.load(ruta)
	archivo.set_value("audio", str(canal), clampi(nivel, 0, 100))
	archivo.save(ruta)

## Comentarios de los crupieres durante la mano (I6-10). Activados por defecto.
static func comentarios_crupieres() -> bool:
	var archivo := ConfigFile.new()
	if archivo.load(ruta) != OK:
		return true
	return bool(archivo.get_value("accesibilidad", "comentarios_crupieres", true))

static func guardar_comentarios_crupieres(activos: bool) -> void:
	var archivo := ConfigFile.new()
	archivo.load(ruta)
	archivo.set_value("accesibilidad", "comentarios_crupieres", activos)
	archivo.save(ruta)

## Ajustes de lectura de las conversaciones (I5-10): velocidad del texto en caracteres por
## segundo (el máximo es instantáneo), espera del modo automático en segundos, tamaño del
## texto en porcentaje y opacidad del cuadro en porcentaje.
const LECTURA := {
	"velocidad": {"predeterminado": 55, "minimo": 20, "maximo": 120},
	"espera_auto": {"predeterminado": 15, "minimo": 5, "maximo": 40},
	"tamano_texto": {"predeterminado": 100, "minimo": 90, "maximo": 140},
	"opacidad": {"predeterminado": 96, "minimo": 40, "maximo": 100},
}

static func lectura(clave: String) -> int:
	var limites: Dictionary = LECTURA[clave]
	var archivo := ConfigFile.new()
	archivo.load(ruta)
	return clampi(int(archivo.get_value("lectura", clave, limites.predeterminado)), limites.minimo, limites.maximo)

static func guardar_lectura(clave: String, valor: int) -> void:
	var limites: Dictionary = LECTURA[clave]
	var archivo := ConfigFile.new()
	archivo.load(ruta)
	archivo.set_value("lectura", clave, clampi(valor, limites.minimo, limites.maximo))
	archivo.save(ruta)

## Los ajustes de lectura en el formato de `DialogoNovela.configurar`.
static func ajustes_dialogo() -> Dictionary:
	var velocidad := lectura("velocidad")
	return {
		"velocidad": 0.0 if velocidad >= int(LECTURA.velocidad.maximo) else float(velocidad),
		"espera_auto": lectura("espera_auto") / 10.0,
		"escala_texto": lectura("tamano_texto") / 100.0,
		"opacidad": lectura("opacidad") / 100.0,
	}

## Consejos del tutorial en contexto (26 nov 2026). Activados por defecto; cada uno sale una vez.
static func consejos() -> bool:
	var archivo := ConfigFile.new()
	if archivo.load(ruta) != OK:
		return true
	return bool(archivo.get_value("tutorial", "consejos", true))

static func guardar_consejos(activos: bool) -> void:
	var archivo := ConfigFile.new()
	archivo.load(ruta)
	archivo.set_value("tutorial", "consejos", activos)
	archivo.save(ruta)

static func consejos_vistos() -> Array:
	var archivo := ConfigFile.new()
	archivo.load(ruta)
	var vistos = archivo.get_value("tutorial", "vistos", [])
	return Array(vistos) if vistos is Array else []

static func marcar_consejo(id: String) -> void:
	var archivo := ConfigFile.new()
	archivo.load(ruta)
	var vistos := consejos_vistos()
	if vistos.has(id):
		return
	vistos.append(id)
	archivo.set_value("tutorial", "vistos", vistos)
	archivo.save(ruta)

## Vuelve a mostrar todos los consejos (Opciones › «Repetir los consejos»).
static func reiniciar_consejos() -> void:
	var archivo := ConfigFile.new()
	archivo.load(ruta)
	archivo.set_value("tutorial", "vistos", [])
	archivo.save(ruta)
