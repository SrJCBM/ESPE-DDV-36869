class_name Consejos
extends RefCounted
## Tutorial en contexto (26 nov 2026): una frase corta, una sola vez, en el momento en que hace
## falta y señalando la parte de la pantalla de la que habla. Pensado para que alguien de 13
## años juegue sin leer el reglamento. Qué consejos se han visto se guarda en AjustesJuego.

const TEXTOS := {
	"umbral": "Acércate al Umbral sin pasarte.",
	"pedir": "P: otra carta. S: plantarte y cobrar.",
	"llave": "Puedes cambiar una Llave antes de pedir.",
	"mascara": "Las Máscaras se descubren al plantarte.",
	"quiebra": "Te pasaste: esta mano vale 0.",
	"patron": "¡Patrón! Multiplica tus puntos.",
	"campanadas": "Cada mano gasta una campanada.",
	"recompensa": "Elige una carta para tu baraja.",
	"tienda": "Gasta fichas en objetos y cartas.",
}

## Consejo de la mesa que toca tras pasar de `previa` a `nueva`, o "" si no hay ninguno nuevo.
## Solo uno a la vez, por orden de importancia; los que esperan salen la próxima vez que se dé
## su situación.
static func en_mesa(previa: Dictionary, nueva: Dictionary, vistos: Array) -> String:
	if nueva.get("terminado", false):
		return ""
	var candidatos: Array[String] = []
	var fase := str(nueva.get("fase", ""))
	var ultima: Dictionary = nueva.get("ultima_mano", {})
	var recien_resuelta := str(previa.get("fase", "")) == "decision" and fase != "decision" and not ultima.is_empty()
	if recien_resuelta:
		if ultima.get("quiebra", false):
			candidatos.append("quiebra")
		elif not (ultima.get("patrones", []) as Array).is_empty():
			candidatos.append("patron")
	if fase == "decision":
		candidatos.append("pedir")
		if not (nueva.get("llaves_disponibles", []) as Array).is_empty():
			candidatos.append("llave")
		if int(nueva.get("intervalo", {}).get("ocultas", 0)) > 0:
			candidatos.append("mascara")
	if int(nueva.get("campanadas", 99)) == 2:
		candidatos.append("campanadas")
	if fase == "preparado" and (nueva.get("cartas", []) as Array).is_empty():
		candidatos.append("umbral")
	for id in candidatos:
		if not vistos.has(id):
			return id
	return ""
