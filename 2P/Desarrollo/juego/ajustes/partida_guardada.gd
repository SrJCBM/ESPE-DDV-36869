class_name PartidaGuardada
extends RefCounted
## Partida de campaña guardada (I5): una sola ranura en un archivo JSON con versión.
## Solo guarda entre encuentros; una mesa en curso nunca se escribe. El casino decide
## cuándo guardar; aquí solo se lee, se escribe y se borra el archivo.
## Sin Autoload, como AjustesJuego: las pruebas redirigen `ruta` a otro archivo.

const VERSION := 1

static var ruta := "user://partida.json"

static func existe() -> bool:
	return not cargar().is_empty()

## Escribe primero un archivo temporal y lo renombra: si el juego se cierra a mitad de la
## escritura, la partida anterior sigue intacta.
static func guardar(datos: Dictionary) -> bool:
	var copia := datos.duplicate(true)
	copia["version"] = VERSION
	var temporal := ruta + ".tmp"
	var archivo := FileAccess.open(temporal, FileAccess.WRITE)
	if archivo == null:
		push_warning("No se pudo guardar la partida en %s" % ruta)
		return false
	archivo.store_string(JSON.stringify(copia, "\t"))
	archivo.close()
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temporal), ProjectSettings.globalize_path(ruta)) == OK

## Datos de la partida, o vacío si no hay archivo, está dañado o es de otra versión.
static func cargar() -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var lector := JSON.new()
	if lector.parse(FileAccess.get_file_as_string(ruta)) != OK:
		return {}
	var datos = lector.data
	if not datos is Dictionary or int(datos.get("version", -1)) != VERSION or not datos.get("campana") is Dictionary:
		return {}
	return datos

static func borrar() -> void:
	for archivo in [ruta, ruta + ".tmp"]:
		if FileAccess.file_exists(archivo):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(archivo))
