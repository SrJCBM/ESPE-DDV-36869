extends RefCounted
## Efectos y límites de uso del inventario durante un encuentro.

var mascaras_vistas: Dictionary = {}
var exactos := 0
var _usos_prudente := 0
var _usos_moneda := 0

func usar_lente(campana: CampanaCasino, mano: Array[CartaEnPartida]) -> bool:
	if campana.lentes <= 0 or EvaluadorMano.intervalo(mano, false, mascaras_vistas).ocultas == 0:
		return false
	for carta in mano:
		if carta.definicion.palo == Palos.MASCARAS:
			mascaras_vistas[carta.id_instancia] = true
	campana.lentes -= 1
	return true

func aplicar(campana: CampanaCasino, partida: EstadoPartida, resultado: Dictionary, presupuesto: int) -> void:
	if resultado.quiebra:
		return
	if campana.amuletos.has("corona") and EvaluadorMano.intervalo(partida.mano, false, mascaras_vistas).ocultas > 0:
		resultado.corona = 2
		resultado.multiplicador += 2
		resultado.puntos = resultado.total * resultado.multiplicador
	if resultado.total == partida.umbral:
		exactos += 1
		if campana.amuletos.has("moneda") and _usos_moneda < 3:
			campana.saldo += 2
			_usos_moneda += 1
	if campana.amuletos.has("prudente") and _usos_prudente < CampanaCasino.USOS_PRUDENTE and resultado.total <= partida.umbral - 3:
		partida.campanadas = mini(presupuesto, partida.campanadas + 1)
		_usos_prudente += 1
