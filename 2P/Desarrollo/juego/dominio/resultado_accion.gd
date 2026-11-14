class_name ResultadoAccion
extends RefCounted

var aceptado: bool
var motivo: String

func _init(valido: bool = false, mensaje: String = "") -> void:
	aceptado = valido
	motivo = mensaje

static func aceptar(mensaje: String = "") -> ResultadoAccion:
	return ResultadoAccion.new(true, mensaje)

static func rechazar(mensaje: String) -> ResultadoAccion:
	return ResultadoAccion.new(false, mensaje)
