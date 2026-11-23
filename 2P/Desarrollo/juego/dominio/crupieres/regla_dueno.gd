class_name ReglaDueno
extends ReglaCrupier
## Empieza en el umbral de su mesa y lo baja uno tras cada mano cerrada sin Quiebra, hasta el mínimo.

const MINIMO := 17
var _anterior := -1

func umbral_para(manos_validas: int) -> int:
	return maxi(MINIMO, CampanaCasino.MESAS_CAMPANA.de("dueno").umbral - manos_validas)

func umbral_al_iniciar(partida: EstadoPartida) -> int:
	_anterior = partida.umbral if partida.manos_resueltas > 0 else -1
	return umbral_para(partida.manos_validas())

func umbral_entre_manos(partida: EstadoPartida) -> int:
	return umbral_para(partida.manos_validas())

func umbrales_vecinos(partida: EstadoPartida, mano_abierta: bool) -> Dictionary:
	if mano_abierta:
		# La siguiente supone que esta mano se cierra sin Quiebra.
		return {"anterior": _anterior, "siguiente": umbral_para(partida.manos_validas() + 1)}
	return {
		"anterior": partida.umbral if partida.manos_resueltas > 0 else -1,
		"siguiente": umbral_para(partida.manos_validas()),
	}
