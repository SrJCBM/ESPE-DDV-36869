class_name ReaccionesCrupier
extends Resource
## Las reacciones se deducen de dos vistas públicas consecutivas del encuentro.
## Dentro de cada transición el orden de los candidatos define su prioridad.

const META_CERCA := 0.85
const MAXIMO_CARACTERES := 90
const PATRONES := {"Punto exacto": "punto_exacto", "Al filo": "al_filo",
	"Racha": "racha", "Ascenso": "ascenso", "Mano larga": "mano_larga"}

@export var lineas: Dictionary = {}

static func disparadores(previa: Dictionary, nueva: Dictionary) -> Array[String]:
	var decision: bool = nueva.get("fase") == "decision"
	var en_mano: bool = previa.get("fase") == "decision"
	if previa.is_empty():
		return ["sentarse"] if nueva.get("mesa", "") != "" else []
	if en_mano and not decision and not nueva.get("ultima_mano", {}).is_empty():
		return _al_resolver(previa, nueva)
	if not decision:
		return []
	if not en_mano:
		var quedan := int(nueva.get("campanadas", -1))
		if quedan == 0: return ["ultima_campanada"]
		if quedan == 2: return ["campanadas_bajas"]
		return ["iniciar_mano"]
	var antes: Array = previa.get("cartas", [])
	var ahora: Array = nueva.get("cartas", [])
	var minimo := int(previa.get("intervalo", {}).get("minimo", 0))
	var umbral := int(nueva.get("umbral", 17))
	var saldo := int(nueva.get("saldo", 0))
	if ahora.size() > antes.size():
		var candidatos: Array[String] = []
		if nueva.get("comision", false) and saldo == 0:
			candidatos.append("sin_saldo")
		if umbral - minimo <= 4:
			candidatos.append("pedir_arriesgado")
		if saldo < int(previa.get("saldo", 0)):
			candidatos.append("cobro")
		candidatos.append("pedir")
		return candidatos
	if antes.size() != ahora.size():
		return []
	var ids := ahora.map(func(carta): return carta.id)
	if antes.any(func(carta): return not ids.has(carta.id)):
		return ["llave_devuelta"]
	if int(nueva.get("intervalo", {}).get("ocultas", 0)) < int(previa.get("intervalo", {}).get("ocultas", 0)):
		return ["lente"]
	return []

static func _al_resolver(previa: Dictionary, nueva: Dictionary) -> Array[String]:
	var ultima: Dictionary = nueva.ultima_mano
	var candidatos: Array[String] = []
	if nueva.get("terminado", false):
		candidatos.append("victoria" if nueva.get("victoria", false) else "derrota")
	if ultima.get("quiebra", false):
		candidatos.append("quiebra")
	else:
		var patrones: Array = ultima.get("patrones", [])
		if int(nueva.get("saldo", 0)) > int(previa.get("saldo", 0)): candidatos.append("moneda")
		if int(nueva.get("campanadas", 0)) > int(previa.get("campanadas", 0)): candidatos.append("prudente")
		if ultima.get("corona", 0) > 0: candidatos.append("corona")
		if "Punto exacto" in patrones: candidatos.append("punto_exacto")
		if "Al filo" in patrones: candidatos.append("al_filo")
		var meta := float(nueva.get("meta", 0))
		var puntos := float(nueva.get("puntos", 0))
		if meta > 0 and float(previa.get("puntos", 0)) < meta * META_CERCA and puntos >= meta * META_CERCA and puntos < meta:
			candidatos.append("meta_cerca")
		for patron in ["Racha", "Ascenso", "Mano larga"]:
			if patron in patrones:
				candidatos.append(PATRONES[patron])
	if int(nueva.get("retenidas", 0)) > int(previa.get("retenidas", 0)):
		var cartas: Array = nueva.get("cartas", [])
		var mayor := 0
		for carta in cartas:
			mayor = maxi(mayor, int(carta.get("valor_efectivo", 0)))
		if mayor == 10: candidatos.append("retencion_diez")
		candidatos.append("retencion")
	if nueva.get("mesa") == "dueno" and int(nueva.get("umbral_siguiente", 0)) < int(nueva.get("umbral", 0)):
		candidatos.append("umbral_minimo" if nueva.umbral_siguiente == 17 else "estrecha")
	if int(previa.get("intervalo", {}).get("ocultas", 0)) > 0:
		candidatos.append("mascara_revelada")
	if previa.get("cartas", []).size() == 2:
		candidatos.append("plantarse_pronto")
	return candidatos

## Primer disparador disponible en la transición; útil al inspeccionar la prioridad.
static func disparador(previa: Dictionary, nueva: Dictionary) -> String:
	var opciones := disparadores(previa, nueva)
	return "" if opciones.is_empty() else opciones[0]

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
