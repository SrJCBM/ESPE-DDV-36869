class_name EvaluadorMano
extends RefCounted
## Evaluación interna: la vista pública debe ocultar este resultado hasta revelar.

const BONOS := {"Punto exacto": 3, "Al filo": 2, "Ascenso": 2, "Mano larga": 2, "Racha": 2}

static func evaluar(mano: Array, umbral: int = 17) -> Dictionary:
	var valores: Array[int] = []
	var patrones: Array[String] = []
	var total: int = 0
	for carta: CartaEnPartida in mano:
		var valor := carta.valor_efectivo()
		valores.append(valor)
		total += valor
	var resultado := {
		"total": total, "quiebra": total > umbral, "patrones": patrones,
		"bonos": {}, "velas": 0, "multiplicador": 0, "puntos": 0,
		"valores": valores,
	}
	if resultado.quiebra:
		return resultado
	var bonos: Dictionary = resultado.bonos
	if not mano.is_empty() and total == umbral:
		bonos["Punto exacto"] = BONOS["Punto exacto"]
	elif not mano.is_empty() and total == umbral - 1:
		bonos["Al filo"] = BONOS["Al filo"]
	var ascenso := mano.size() >= 3
	for i in range(1, valores.size()):
		if valores[i] <= valores[i - 1]:
			ascenso = false
	if ascenso:
		bonos["Ascenso"] = BONOS["Ascenso"]
	if mano.size() >= 5:
		bonos["Mano larga"] = BONOS["Mano larga"]
	if mano.size() >= 3:
		var ultimo_palo: String = mano[-1].definicion.palo
		if mano[-2].definicion.palo == ultimo_palo and mano[-3].definicion.palo == ultimo_palo:
			bonos["Racha"] = BONOS["Racha"]
	var multiplicador: int = 1
	for nombre: String in bonos:
		patrones.append(nombre)
		multiplicador += int(bonos[nombre])
	for carta: CartaEnPartida in mano:
		if carta.definicion.palo == "velas":
			resultado.velas += 1
	multiplicador += int(resultado.velas)
	resultado.multiplicador = multiplicador
	resultado.puntos = total * multiplicador
	return resultado


static func intervalo(mano: Array, reveladas: bool = false, vistas: Dictionary = {}) -> Dictionary:
	var conocido: int = 0
	var ocultas: int = 0
	for carta: CartaEnPartida in mano:
		if carta.definicion.palo == "mascaras" and not reveladas and not vistas.has(carta.id_instancia):
			# No se consulta su valor: estas cotas no dependen del valor oculto real.
			ocultas += 1
		else:
			conocido += carta.valor_efectivo()
	return {
		"conocido": conocido, "ocultas": ocultas,
		"minimo": conocido + ocultas, "maximo": conocido + 10 * ocultas,
	}
