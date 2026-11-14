class_name PedirCarta
extends ComandoMesa

func ejecutar(receptor: EstadoMesaBase) -> ResultadoAccion:
	return receptor.pedir()
