class_name AjustesJuego
extends RefCounted
## Preferencias que se conservan entre sesiones, como pide el documento de diseño.
## La campaña se guarda aparte, en PartidaGuardada (I5).
## Sin Autoload: las mesas y las pruebas no dependen de un estado global; solo los puntos de entrada lo leen.
## El archivo se lee una vez y queda en memoria; cada cambio se escribe en el disco al momento.

## Las pruebas la redirigen a otro archivo para no tocar las preferencias de quien juega.
static var ruta := "user://ajustes.cfg":
	set(nueva):
		ruta = nueva
		_archivo = null

static var _archivo: ConfigFile

## Olvida lo leído; la próxima consulta vuelve al disco (p. ej., si alguien borró el archivo).
static func recargar() -> void:
	_archivo = null

## Borra el archivo y lo leído: todo vuelve a lo predeterminado (pruebas y capturas).
static func borrar() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))
	_archivo = null

static func _leer(seccion: String, clave: String, predeterminado: Variant) -> Variant:
	return _cargado().get_value(seccion, clave, predeterminado)

static func _escribir(seccion: String, clave: String, valor: Variant) -> void:
	_cargado().set_value(seccion, clave, valor)
	_archivo.save(ruta)

static func _cargado() -> ConfigFile:
	if _archivo == null:
		_archivo = ConfigFile.new()
		_archivo.load(ruta) # Sin archivo, todo vale lo predeterminado.
	return _archivo

static func movimiento_reducido() -> bool:
	return bool(_leer("accesibilidad", "movimiento_reducido", false))

static func guardar_movimiento_reducido(reducido: bool) -> void:
	_escribir("accesibilidad", "movimiento_reducido", reducido)

static func volumen(canal: StringName, predeterminado: int) -> int:
	return clampi(int(_leer("audio", str(canal), predeterminado)), 0, 100)

static func guardar_volumen(canal: StringName, nivel: int) -> void:
	_escribir("audio", str(canal), clampi(nivel, 0, 100))

## Comentarios de los crupieres durante la mano (I6-10). Activados por defecto.
static func comentarios_crupieres() -> bool:
	return bool(_leer("accesibilidad", "comentarios_crupieres", true))

static func guardar_comentarios_crupieres(activos: bool) -> void:
	_escribir("accesibilidad", "comentarios_crupieres", activos)

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
	return clampi(int(_leer("lectura", clave, limites.predeterminado)), limites.minimo, limites.maximo)

static func guardar_lectura(clave: String, valor: int) -> void:
	var limites: Dictionary = LECTURA[clave]
	_escribir("lectura", clave, clampi(valor, limites.minimo, limites.maximo))

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
	return bool(_leer("tutorial", "consejos", true))

static func guardar_consejos(activos: bool) -> void:
	_escribir("tutorial", "consejos", activos)

static func consejos_vistos() -> Array:
	var vistos = _leer("tutorial", "vistos", [])
	return Array(vistos).duplicate() if vistos is Array else []

static func marcar_consejo(id: String) -> void:
	var vistos := consejos_vistos()
	if vistos.has(id):
		return
	vistos.append(id)
	_escribir("tutorial", "vistos", vistos)

## Vuelve a mostrar todos los consejos (Opciones › «Repetir los consejos»).
static func reiniciar_consejos() -> void:
	_escribir("tutorial", "vistos", [])
