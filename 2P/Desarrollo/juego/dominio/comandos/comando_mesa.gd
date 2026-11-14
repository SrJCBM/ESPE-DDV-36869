class_name ComandoMesa
extends RefCounted

func ejecutar(_receptor: EstadoMesaBase) -> ResultadoAccion:
	return ResultadoAccion.rechazar("Comando sin operación.")
