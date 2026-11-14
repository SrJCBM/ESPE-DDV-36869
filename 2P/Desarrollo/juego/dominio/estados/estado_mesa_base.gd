class_name EstadoMesaBase
extends RefCounted

var contexto: Node
var nombre: String = "base"

func _init(receptor: Node = null) -> void:
	contexto = receptor

func iniciar() -> ResultadoAccion:
	return ResultadoAccion.rechazar("No puedes iniciar en esta fase.")

func pedir() -> ResultadoAccion:
	return ResultadoAccion.rechazar("No puedes pedir en esta fase.")

func devolver_llave(_carta_id: String) -> ResultadoAccion:
	return ResultadoAccion.rechazar("No puedes devolver una Llave en esta fase.")

func plantarse() -> ResultadoAccion:
	return ResultadoAccion.rechazar("No hay una mano pendiente de resolver.")
