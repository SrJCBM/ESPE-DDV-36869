extends RefCounted
## Proyección de la mano. Solo publica valores revelados y conserva el orden al cerrarla.

const Indicadores = preload("res://dominio/indicadores_patrones.gd")

var _cartas_resueltas: Array[Dictionary] = []
var _resultado: Dictionary = {}

func limpiar() -> void:
	_cartas_resueltas.clear()
	_resultado.clear()

func registrar_cierre(mano: Array[CartaEnPartida], resultado: Dictionary) -> void:
	_cartas_resueltas = _cartas(mano, [], {}, true)
	_resultado = resultado.duplicate(true)

func proyectar(partida: EstadoPartida, mano_abierta: bool, llaves: Array[String], vistas: Dictionary) -> Dictionary:
	var cartas: Array[Dictionary]
	var intervalo: Dictionary
	var anticipado: Dictionary = {}
	if not mano_abierta and not _cartas_resueltas.is_empty():
		cartas = _cartas_resueltas.duplicate(true)
		var total := int(_resultado.total)
		intervalo = {"conocido": total, "ocultas": 0, "minimo": total, "maximo": total}
	else:
		cartas = _cartas(partida.mano, llaves, vistas, false)
		intervalo = EvaluadorMano.intervalo(partida.mano, false, vistas)
		if mano_abierta and intervalo.ocultas == 0:
			anticipado = EvaluadorMano.evaluar(partida.mano, partida.umbral)
	return {
		"cartas": cartas, "intervalo": intervalo, "llaves_disponibles": llaves,
		"ultima_mano": _resultado.duplicate(true), "resultado_visible": anticipado,
		"patrones_visibles": Indicadores.calcular(cartas, intervalo, partida.umbral),
	}

func _cartas(mano: Array[CartaEnPartida], llaves: Array[String], vistas: Dictionary, revelar: bool) -> Array[Dictionary]:
	var cartas: Array[Dictionary] = []
	for carta in mano:
		var oculta := not revelar and carta.es_mascara_oculta(vistas)
		cartas.append({
			"id": carta.id_instancia, "palo": carta.definicion.palo, "rasgo": carta.definicion.rasgo,
			"valor": null if oculta else carta.definicion.valor_impreso as Variant,
			"valor_efectivo": null if oculta else carta.valor_efectivo() as Variant,
			"oculta": oculta, "puede_devolver": llaves.has(carta.id_instancia),
		})
	return cartas
