class_name EstadoDecision
extends EstadoMesaBase

func _init(receptor: Node = null) -> void:
	super(receptor)
	nombre = "decision"

func pedir() -> ResultadoAccion:
	return contexto._pedir_carta()

func devolver_llave(carta_id: String) -> ResultadoAccion:
	return contexto._devolver_llave(carta_id)

func plantarse() -> ResultadoAccion:
	return contexto._plantarse()
