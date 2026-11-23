class_name ReglaCrupier
extends RefCounted
## Strategy: el ciclo de cartas es común y cada crupier cambia solo su regla especial.
## Esta clase base es la mesa sin regla especial (el Custodio y la mesa suelta de I1).

## Al sentarse, antes de cualquier acción. Una sola vez por intento.
func al_sentarse(_campana: CampanaCasino) -> void:
	pass

## Si cada carta pedida tras el reparto cuesta una ficha.
func cobra_por_pedir() -> bool:
	return false

## Umbral de la mano que se está abriendo.
func umbral_al_iniciar(partida: EstadoPartida) -> int:
	return partida.umbral

## Umbral que tendrá la próxima mano, consultado entre manos (ayuda y placa).
func umbral_entre_manos(partida: EstadoPartida) -> int:
	return partida.umbral

## Umbral de la mano anterior y de la siguiente para anunciar cambios. −1 si no aplica.
func umbrales_vecinos(_partida: EstadoPartida, _mano_abierta: bool) -> Dictionary:
	return {"anterior": -1, "siguiente": -1}

## Después de puntuar y aplicar objetos, antes de descartar la mano.
func al_resolver(_partida: EstadoPartida) -> void:
	pass
