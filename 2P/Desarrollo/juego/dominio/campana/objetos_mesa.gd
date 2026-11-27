extends RefCounted
## Efectos y límites de uso del inventario durante un encuentro. Los límites salen del catálogo
## de la tienda (ObjetoTienda.usos_por_mesa, fichas_por_uso).

var mascaras_vistas: Dictionary = {}
var exactos := 0
## id del objeto → veces que se aplicó en este encuentro.
var usos: Dictionary = {}

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
		if _gastar_uso(campana, "moneda"):
			campana.ingresar(CampanaCasino.TIENDA.buscar("moneda").fichas_por_uso)
	if resultado.total <= partida.umbral - 3 and _gastar_uso(campana, "prudente"):
		partida.campanadas = mini(presupuesto, partida.campanadas + 1)

## Usos que le quedan a cada objeto limitado que se lleva, en este encuentro.
func usos_restantes(campana: CampanaCasino = null) -> Dictionary:
	var restantes := {}
	for producto in CampanaCasino.TIENDA.objetos:
		if producto.usos_por_mesa > 0 and (campana == null or campana.amuletos.has(producto.id)):
			restantes[producto.id] = producto.usos_por_mesa - int(usos.get(producto.id, 0))
	return restantes

func _gastar_uso(campana: CampanaCasino, id: String) -> bool:
	if not campana.amuletos.has(id) or int(usos.get(id, 0)) >= CampanaCasino.usos_por_mesa(id):
		return false
	usos[id] = int(usos.get(id, 0)) + 1
	return true
