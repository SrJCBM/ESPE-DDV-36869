class_name EstadoPreparado
extends EstadoMesaBase

func _init(receptor: Node = null) -> void:
	super(receptor)
	nombre = "preparado"

func iniciar() -> ResultadoAccion:
	return contexto._iniciar_mano()
