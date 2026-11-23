extends RefCounted
## Traduce la vista pública a explicaciones breves; no evalúa cartas ocultas.

static func resultado(vista: Dictionary) -> Dictionary:
	var mano: Dictionary = vista.get("ultima_mano", {})
	var total: int = int(mano.get("total", 0))
	var umbral: int = int(vista.get("umbral", 17))
	if mano.get("quiebra", false):
		return {"formula": "Quiebra · %s supera %s" % [total, umbral],
			"detalle": "Esta mano no suma puntos.", "completo": "Superaste el umbral por %s." % (total - umbral)}
	# A primera vista, el aporte y los patrones obtenidos; la fórmula queda en «Ver desglose».
	var partes := PackedStringArray()
	var bonos: Dictionary = mano.get("bonos", {})
	for nombre in mano.get("patrones", []):
		partes.append("%s +%s" % ["Exacto" if nombre == "Punto exacto" else nombre, int(bonos.get(nombre, 0))])
	if mano.get("corona", 0) > 0: partes.append("Corona +2")
	var completo := "%s × %s = %s" % [total, mano.get("multiplicador", 1), mano.get("puntos", 0)]
	return {"formula": "+%s puntos" % mano.get("puntos", 0),
		"detalle": " · ".join(partes), "completo": completo}

## Regla del crupier aplicada a la mano en curso, para leerla sin abrir la ayuda.
## texto: placa bajo el retrato (vacía si la mesa no tiene regla especial). nota: línea junto al umbral.
static func regla(vista: Dictionary) -> Dictionary:
	var nota := "No lo excedas."
	var umbral: int = int(vista.get("umbral", 17))
	var siguiente: int = int(vista.get("umbral_siguiente", -1))
	var anterior: int = int(vista.get("umbral_anterior", -1))
	match str(vista.get("mesa", "")):
		"recaudador":
			return {"texto": "Cada carta que pides tras el reparto cuesta 1 ficha. Saldo: %s." % vista.get("saldo", 0), "nota": nota}
		"coleccionista":
			var retenidas: int = int(vista.get("retenidas", 0))
			return {"texto": "Al cerrar cada mano se queda tu carta más alta hasta el final de la mesa. Retenidas: %s." % retenidas, "nota": nota}
		"dueno":
			if vista.get("terminado", false):
				return {"texto": "El umbral bajó uno por cada mano cerrada sin Quiebra.", "nota": nota}
			if vista.get("fase", "") == "decision":
				var texto := ""
				if anterior > umbral: texto = "El umbral bajó de %s a %s. " % [anterior, umbral]
				elif anterior == umbral and siguiente < umbral: texto = "El umbral sigue en %s: tu última mano fue Quiebra. " % umbral
				if siguiente < umbral:
					texto += "Si cierras esta mano sin Quiebra, bajará a %s." % siguiente
					nota = "Baja a %s sin Quiebra." % siguiente
				else:
					texto += "El umbral ya está en su mínimo: %s." % umbral
					nota = "Mínimo alcanzado."
				return {"texto": texto, "nota": nota}
			if anterior < 0:
				return {"texto": "Empieza en %s y baja uno por cada mano que cierres sin Quiebra, hasta 17." % siguiente, "nota": "Baja sin Quiebra."}
			if siguiente < anterior:
				return {"texto": "Tu próxima mano tendrá umbral %s: baja de %s." % [siguiente, anterior], "nota": "Próxima mano: %s." % siguiente}
			if siguiente > 17:
				return {"texto": "La Quiebra no baja el umbral: tu próxima mano sigue en %s." % siguiente, "nota": "Próxima mano: %s." % siguiente}
			return {"texto": "El umbral se mantiene en su mínimo: %s." % siguiente, "nota": "Mínimo alcanzado."}
	return {"texto": "", "nota": nota}

static func pista(vista: Dictionary) -> String:
	if vista.get("terminado", false):
		var resumen: Dictionary = vista.get("resumen_intento", {})
		var manos: int = int(resumen.get("manos", vista.get("numero_mano", 0)))
		var validas: int = int(resumen.get("validas", 0))
		var quiebras: int = int(resumen.get("quiebras", 0))
		return "%s %s · %s %s · %s %s" % [manos, "mano" if manos == 1 else "manos",
			validas, "válida" if validas == 1 else "válidas", quiebras, "Quiebra" if quiebras == 1 else "Quiebras"]
	if vista.get("fase", "") != "decision":
		return "Inicia una mano: dos cartas, una campanada." if vista.get("cartas", []).is_empty() else ""
	var intervalo: Dictionary = vista.get("intervalo", {})
	if int(intervalo.get("minimo", 0)) > int(vista.get("umbral", 17)):
		return "Quiebra segura. Cambia una Llave o plántate." if not vista.get("llaves_disponibles", []).is_empty() else "Quiebra segura. Plántate para revelar y cerrar."
	if vista.get("comision", false):
		return "Pedir cuesta una ficha. Saldo: %s." % vista.saldo if vista.saldo > 0 else "Sin fichas para la comisión. Puedes plantarte."
	if not vista.get("acciones", {}).get("pedir", true):
		return "No quedan cartas disponibles. Plántate para cerrar la mano."
	if int(vista.get("campanadas", 1)) == 0:
		return "Última mano: puedes pedir gratis o plantarte."
	if vista.get("numero_mano", 1) == 1 and not vista.get("llaves_disponibles", []).is_empty():
		return "Puedes cambiar una Llave antes de pedir o plantarte."
	if int(intervalo.get("ocultas", 0)) > 0:
		return "Plantarte revela las Máscaras y cierra la mano."
	return "Pedir es gratis; si te pasas, esta mano no suma."

static func patron(vista: Dictionary, indice: int) -> Dictionary:
	var filas: Array = vista.get("patrones_visibles", [])
	if indice < 0 or indice >= filas.size(): return {"indices": [], "texto": ""}
	var fila: Dictionary = filas[indice]
	var cartas: Array = vista.get("cartas", [])
	var indices: Array[int] = []
	var primero: int = maxi(0, cartas.size() - 3) if fila.nombre == "Racha" else 0
	for i in range(primero, cartas.size()): indices.append(i)
	var umbral: int = int(vista.get("umbral", 17))
	var frases := {
		"Punto exacto": "Exacto · suma exactamente %s." % umbral,
		"Al filo": "Al filo · suma %s, uno por debajo del umbral." % (umbral - 1),
		"Ascenso": "Ascenso · toda la mano de menor a mayor, con 3 cartas o más.",
		"Mano larga": "Mano larga · conserva 5 cartas o más sin superar %s." % umbral,
		"Racha": "Racha · las últimas 3 cartas del mismo palo.",
	}
	var texto: String = frases.get(fila.nombre, "")
	if fila.estado == "anulado": texto += " Sin bono: Quiebra segura."
	elif fila.estado == "pendiente" or (fila.estado == "activo" and fila.get("condicionado", false)):
		texto += " Por confirmar al revelar."
	return {"indices": indices, "texto": texto}

static func progreso(fila: Dictionary) -> String:
	if fila.estado == "anulado": return "Sin bono"
	if fila.estado == "activo":
		return str(fila.detalle).get_slice(" ", 0) + " · al revelar" if fila.get("condicionado", false) else "Activo"
	if fila.estado == "pendiente": return "Por revelar"
	if fila.estado == "inactivo": return "No se cumple"
	return str(fila.detalle).replace(" cartas", "").replace(" subiendo", "").replace(" del palo", "")
