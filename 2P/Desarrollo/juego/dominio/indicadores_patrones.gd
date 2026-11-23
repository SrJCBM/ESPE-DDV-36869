extends RefCounted
## Progreso de objetivos usando exclusivamente cartas y cotas de la vista pública.

static func calcular(cartas: Array, intervalo: Dictionary, umbral: int) -> Array[Dictionary]:
	var filas: Array[Dictionary] = []
	var ocultas: int = int(intervalo.get("ocultas", 0))
	var conocido: int = int(intervalo.get("conocido", 0))
	var minimo: int = int(intervalo.get("minimo", 0))
	var maximo: int = int(intervalo.get("maximo", 0))
	for nombre in ["Punto exacto", "Al filo"]:
		var objetivo: int = umbral if nombre == "Punto exacto" else umbral - 1
		var estado := "progreso"
		var detalle := "Faltan %s" % maxi(0, objetivo - conocido)
		if ocultas > 0:
			estado = "pendiente" if minimo <= objetivo and maximo >= objetivo else "inactivo"
			detalle = "Al revelar" if estado == "pendiente" else "Fuera del rango"
		elif conocido == objetivo and not cartas.is_empty():
			estado = "activo"
			detalle = "Total %s" % objetivo
		elif conocido > objetivo:
			estado = "inactivo"
			detalle = "Superaste %s" % objetivo
		filas.append(_fila(nombre, estado, detalle, "Suma %s exactamente. El bono cuenta solo si no hay Quiebra." % objetivo, false))
	var sube := true
	var ultimo := 0
	for carta in cartas:
		if carta.get("oculta", false):
			ultimo += 1
			if ultimo > 10: sube = false
			continue
		var valor: int = int(carta.get("valor_efectivo", 0))
		if valor <= ultimo: sube = false
		ultimo = valor
	if cartas.size() < 3 and ultimo >= 10: sube = false
	var ascenso := "inactivo"
	var ascenso_detalle := "No van subiendo"
	if sube:
		ascenso = "pendiente" if ocultas > 0 else ("activo" if cartas.size() >= 3 else "progreso")
		ascenso_detalle = "Al revelar" if ocultas > 0 else ("Van subiendo" if cartas.size() >= 3 else "%s/3 subiendo" % cartas.size())
	filas.append(_fila("Ascenso", ascenso, ascenso_detalle, "3 cartas o más, todas de menor a mayor en orden de robo. Ejemplo: 2 < 5 < 8. No hace falta que sean consecutivas.", false))
	filas.append(_fila("Mano larga", "activo" if cartas.size() >= 5 else "progreso", "%s/5 cartas" % mini(cartas.size(), 5), "Conserva al menos 5 cartas sin superar el umbral. Cada carta que pides arriesga la mano, pero no gasta campanadas.", ocultas > 0))
	var racha := 0
	if not cartas.is_empty():
		var palo: String = str(cartas.back().get("palo", ""))
		for indice in range(cartas.size() - 1, -1, -1):
			if cartas[indice].get("palo", "") != palo: break
			racha += 2 if cartas[indice].get("rasgo", "") == CartaEnPartida.RASGO_RACHA_DOBLE else 1
	filas.append(_fila("Racha", "activo" if racha >= 3 else "progreso", "%s/3 del palo" % mini(racha, 3), "Las 3 últimas cartas conservadas son del mismo palo. Una Vela de Racha ×2 cuenta como dos. Las anteriores pueden ser distintas. No se puede cambiar el orden.", ocultas > 0))
	if minimo > umbral:
		for fila in filas:
			fila.estado = "anulado"
			fila.detalle = "Quiebra segura"
	return filas

static func _fila(nombre: String, estado: String, detalle: String, explicacion: String, condicionado: bool) -> Dictionary:
	return {"nombre": nombre, "estado": estado, "detalle": detalle,
		"bono": int(EvaluadorMano.BONOS[nombre]), "explicacion": explicacion,
		"condicionado": condicionado}
