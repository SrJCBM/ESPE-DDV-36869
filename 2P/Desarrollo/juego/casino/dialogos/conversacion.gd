class_name Conversacion
extends Resource
## Conversación como datos (I4-06). Escribir o cambiar un diálogo solo exige editar su `.tres`.
##
## - `personajes`: id → {"nombre", "retrato", "expresiones"?}. "expresiones" es una ruta con
##   %s («res://historia/retratos/custodio_%s.webp»); una intervención con "expresion" usa
##   ese archivo si existe y, si aún no está dibujado, el retrato general.
## - `entradas`: [{"si"?, "ir"}]; se abre por la primera cuya condición se cumpla.
## - `intervenciones`: id → {"personaje", "texto", "retrato"?, "siguiente"? | "opciones"?,
##   "solicitud"?, "modo"?, "fondo"?, "sonido"?}.
##   Cada opción: {"texto", "ir", "si"?, "solicitud"?}. "ir" vacío cierra el diálogo.
##   "siguiente" es un id o una lista [{"si"?, "ir"}] que se resuelve como las entradas.
##   "solicitud" en una intervención se emite al mostrarla (registrar que se vio algo).
##   "modo": "adv" (cuadro con retrato, por defecto), "nvl" (narración a pantalla completa
##   que se acumula párrafo a párrafo; "pagina_nueva": true la limpia) o "tarjeta" (título).
## - "escena" en una intervención: lista de cambios del escenario antes de mostrarla:
##   {"entra": personaje, "lado": "izquierda" | "centro" | "derecha", "expresion"?} o
##   {"sale": personaje} ("todos" vacía el escenario).
## - `fondos`: id → {"ruta"?, "descripcion"}. Un fondo sin archivo se muestra como
##   ilustración pendiente con su descripción, para sustituirlo sin tocar el guion.
##
## Las condiciones («sin_invitacion», «sellos==1»…) las evalúa quien abre el diálogo, y las
## solicitudes las comprueba y aplica la campaña: este recurso no conoce el juego.

@export var personajes: Dictionary = {}
@export var entradas: Array = []
@export var intervenciones: Dictionary = {}
@export var fondos: Dictionary = {}

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
	var personaje: Dictionary = personajes.get(linea.get("personaje", ""), {})
	if linea.has("expresion") and personaje.has("expresiones"):
		var ruta := str(personaje.expresiones) % str(linea.expresion)
		if ResourceLoader.exists(ruta):
			return ruta
	return str(personaje.get("retrato", ""))

## Intervención que sigue a `id`. Con una lista, la primera cuya condición se cumpla.
func siguiente(id: String, evaluar := Callable()) -> String:
	var destino = intervencion(id).get("siguiente", "")
	if destino is Array:
		for paso: Dictionary in destino:
			if not paso.has("si") or (evaluar.is_valid() and _cumple(paso, evaluar)):
				return str(paso.get("ir", ""))
		return ""
	return str(destino)

## Imagen de un personaje con una expresión (si ya está dibujada) o su retrato general.
func imagen(personaje: String, expresion := "") -> String:
	var datos: Dictionary = personajes.get(personaje, {})
	if not expresion.is_empty() and datos.has("expresiones"):
		var ruta := str(datos.expresiones) % expresion
		if ResourceLoader.exists(ruta):
			return ruta
	return str(datos.get("retrato", ""))

## {"ruta", "descripcion"} del fondo, o vacío si el id no está definido.
func fondo(id: String) -> Dictionary:
	return fondos.get(id, {})

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
		var destino = linea.get("siguiente", "")
		if destino is Array:
			for paso: Dictionary in destino:
				destinos.append(str(paso.get("ir", "")))
		else:
			destinos.append(str(destino))
		for cambio: Dictionary in linea.get("escena", []):
			var quien := str(cambio.get("entra", cambio.get("sale", "")))
			if quien != "todos" and not personajes.has(quien):
				lista.append("%s: personaje en escena desconocido %s" % [id, quien])
		if linea.has("fondo") and not str(linea.fondo).is_empty() and not fondos.has(str(linea.fondo)):
			lista.append("%s: fondo desconocido %s" % [id, linea.fondo])
		for opcion: Dictionary in linea.get("opciones", []):
			destinos.append(str(opcion.get("ir", "")))
	for destino: String in destinos:
		if not destino.is_empty() and not intervenciones.has(destino):
			lista.append("destino inexistente: %s" % destino)
	return lista

static func _cumple(datos: Dictionary, evaluar: Callable) -> bool:
	return not datos.has("si") or bool(evaluar.call(str(datos.si)))
