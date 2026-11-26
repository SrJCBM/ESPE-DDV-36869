class_name ReaccionesCrupier
extends Resource
## Reacciones de los crupieres durante la mano (I6-10, guion §9). Las líneas son datos: cada
## crupier tiene sus variantes por disparador. Este recurso no conoce la mesa: recibe la vista
## pública anterior y la nueva, y decide qué decir.
##
## Primer tramo: Punto exacto, Al filo, Quiebra y `meta_cerca`, solo después de resolver la
## mano. Como la mano ya está revelada, ninguna reacción puede anticipar una Máscara oculta.

## Prioridad de cada disparador (§9): si coinciden varios, gana el mayor.
const PRIORIDADES := {"quiebra": 8, "punto_exacto": 8, "al_filo": 6, "meta_cerca": 6}
## «Cerca de la meta»: falta menos del 15 %.
const META_CERCA := 0.85
const MAXIMO_CARACTERES := 90

## crupier → disparador → [variantes].
@export var lineas: Dictionary = {}

## Disparador de mayor prioridad entre la vista anterior y la nueva, o vacío. Solo hay
## reacción cuando la mano acaba de resolverse.
static func disparador(previa: Dictionary, nueva: Dictionary) -> String:
	var ultima: Dictionary = nueva.get("ultima_mano", {})
	var resuelta: bool = previa.get("fase", "") == "decision" and nueva.get("fase", "") != "decision" and not ultima.is_empty()
	if not resuelta:
		return ""
	var candidatos: Array[String] = []
	if ultima.get("quiebra", false):
		candidatos.append("quiebra")
	else:
		var patrones: Array = ultima.get("patrones", [])
		if patrones.has("Punto exacto"): candidatos.append("punto_exacto")
		elif patrones.has("Al filo"): candidatos.append("al_filo")
	var meta := float(nueva.get("meta", 0))
	var antes := float(previa.get("puntos", 0))
	var ahora := float(nueva.get("puntos", 0))
	if meta > 0 and antes < meta * META_CERCA and ahora >= meta * META_CERCA and ahora < meta and not nueva.get("victoria", false):
		candidatos.append("meta_cerca")
	var elegido := ""
	for candidato in candidatos:
		if elegido.is_empty() or int(PRIORIDADES[candidato]) > int(PRIORIDADES[elegido]):
			elegido = candidato
	return elegido

## Una variante para el crupier y el disparador, distinta de `anterior` si hay otra.
func linea(crupier: String, id: String, anterior := "", azar: RandomNumberGenerator = null) -> String:
	var variantes: Array = lineas.get(crupier, {}).get(id, [])
	if variantes.is_empty():
		return ""
	var opciones := variantes.filter(func(v): return v != anterior)
	if opciones.is_empty():
		opciones = variantes
	var indice := azar.randi_range(0, opciones.size() - 1) if azar != null else randi_range(0, opciones.size() - 1)
	return str(opciones[indice])

## Líneas demasiado largas para el bocadillo a 1024 × 576.
func largas() -> PackedStringArray:
	var lista := PackedStringArray()
	for crupier in lineas:
		for id in lineas[crupier]:
			for texto in lineas[crupier][id]:
				if str(texto).length() > MAXIMO_CARACTERES:
					lista.append("%s · %s · %s" % [crupier, id, texto])
	return lista
