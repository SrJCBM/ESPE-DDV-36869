class_name Plantarse
extends ComandoMesa

func ejecutar(receptor: EstadoMesaBase) -> ResultadoAccion:
	return receptor.plantarse()
