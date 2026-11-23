class_name Conversacion
extends Resource
## Conversación como datos (I4-06). Escribir o cambiar un diálogo solo exige editar su `.tres`.
##
## - `personajes`: id → {"nombre", "retrato"}.
## - `entradas`: [{"si"?, "ir"}]; se abre por la primera cuya condición se cumpla.
## - `intervenciones`: id → {"personaje", "texto", "retrato"?, "siguiente"? | "opciones"?}.
##   Cada opción: {"texto", "ir", "si"?, "solicitud"?}. "ir" vacío cierra el diálogo.
##
## Las condiciones («sin_invitacion», «sellos==1»…) las evalúa quien abre el diálogo, y las
## solicitudes las comprueba y aplica la campaña: este recurso no conoce el juego.

@export var personajes: Dictionary = {}
@export var entradas: Array = []
@export var intervenciones: Dictionary = {}

## Primera intervención según el progreso, o vacío si ninguna entrada corresponde.
func inicio(evaluar: Callable) -> String:
	for entrada: Dictionary in entradas:
		if _cumple(entrada, evaluar):
			return str(entrada.get("ir", ""))
	return ""

func intervencion(id: String) -> Dictionary:
	return intervenciones.get(id, {})

func nombre(id: String) -> String:
	return str(personajes.get(intervencion(id).get("personaje", ""), {}).get("nombre", ""))

## Retrato propio de la intervención (una expresión) o, si no tiene, el del personaje.
func retrato(id: String) -> String:
	var linea := intervencion(id)
	if linea.has("retrato"):
		return str(linea.retrato)
	return str(personajes.get(linea.get("personaje", ""), {}).get("retrato", ""))

func siguiente(id: String) -> String:
	return str(intervencion(id).get("siguiente", ""))

## Opciones visibles con el progreso actual.
func opciones(id: String, evaluar: Callable) -> Array:
	var visibles := []
	for opcion: Dictionary in intervencion(id).get("opciones", []):
		if _cumple(opcion, evaluar):
			visibles.append(opcion)
	return visibles

## Referencias rotas: destinos inexistentes, personajes sin definir o retratos ausentes.
func errores() -> PackedStringArray:
	var lista := PackedStringArray()
	var destinos := []
	for entrada: Dictionary in entradas:
		destinos.append(str(entrada.get("ir", "")))
	for id: String in intervenciones:
		var linea: Dictionary = intervenciones[id]
		if not personajes.has(linea.get("personaje", "")):
			lista.append("%s: personaje desconocido" % id)
		if str(linea.get("texto", "")).is_empty():
			lista.append("%s: sin texto" % id)
		if not retrato(id).is_empty() and not ResourceLoader.exists(retrato(id)):
			lista.append("%s: no existe el retrato %s" % [id, retrato(id)])
		destinos.append(str(linea.get("siguiente", "")))
		for opcion: Dictionary in linea.get("opciones", []):
			destinos.append(str(opcion.get("ir", "")))
	for destino: String in destinos:
		if not destino.is_empty() and not intervenciones.has(destino):
			lista.append("destino inexistente: %s" % destino)
	return lista

static func _cumple(datos: Dictionary, evaluar: Callable) -> bool:
	return not datos.has("si") or bool(evaluar.call(str(datos.si)))
