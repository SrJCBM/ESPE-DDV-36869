class_name ReglaColeccionista
extends ReglaCrupier
## Retiene la carta de mayor valor efectivo de cada mano cerrada, incluida una Quiebra.
## Empate: la última robada. Se omite si dejaría menos de dos cartas disponibles.

func al_resolver(partida: EstadoPartida) -> void:
	var mano := partida.mano
	if mano.is_empty() or partida.disponibles() + mano.size() <= 2:
		return
	var mayor: CartaEnPartida = mano.front()
	for carta in mano:
		if carta.valor_efectivo() >= mayor.valor_efectivo(): mayor = carta
	partida.retenidas.append(mayor)
	mano.erase(mayor)
