class_name IniciarMano
extends ComandoMesa

func ejecutar(receptor: EstadoMesaBase) -> ResultadoAccion:
	return receptor.iniciar()
