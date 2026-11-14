class_name DevolverLlave
extends ComandoMesa

var carta_id: String

func _init(identidad: String = "") -> void:
	carta_id = identidad

func ejecutar(receptor: EstadoMesaBase) -> ResultadoAccion:
	return receptor.devolver_llave(carta_id)
