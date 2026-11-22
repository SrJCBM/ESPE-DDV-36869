class_name ReglaDueno
extends ReglaCrupier
## Empieza en el umbral de su mesa y lo baja uno tras cada mano cerrada sin Quiebra, hasta el mínimo.

const MINIMO := 17
var _anterior := -1

func umbral_para(manos_validas: int) -> int:
	return maxi(MINIMO, int(CampanaCasino.REGLAS[3][0]) - manos_validas)

func umbral_al_iniciar(mesa: ControladorMesa) -> int:
	_anterior = mesa.partida.umbral if mesa.manos_resueltas() > 0 else -1
	return umbral_para(mesa.manos_validas())

func umbral_entre_manos(mesa: ControladorMesa) -> int:
	return umbral_para(mesa.manos_validas())

func umbrales_vecinos(mesa: ControladorMesa) -> Dictionary:
	if mesa.estado_activo.nombre == "decision":
		# La siguiente supone que esta mano se cierra sin Quiebra.
		return {"anterior": _anterior, "siguiente": umbral_para(mesa.manos_validas() + 1)}
	return {"anterior": mesa.partida.umbral if mesa.manos_resueltas() > 0 else -1,
		"siguiente": umbral_para(mesa.manos_validas())}
