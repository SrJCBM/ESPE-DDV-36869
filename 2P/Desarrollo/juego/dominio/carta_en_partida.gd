class_name CartaEnPartida
extends RefCounted
## La identidad pública no codifica el palo ni el valor de la carta.

var id_instancia: String = ""
var definicion: CartaDef

func _init(datos: CartaDef = null, identidad: String = "") -> void:
	definicion = datos
	id_instancia = identidad
	if id_instancia.is_empty():
		id_instancia = Crypto.new().generate_random_bytes(16).hex_encode()


func valor_efectivo() -> int:
	if definicion.palo == Palos.RELOJES:
		return maxi(1, definicion.valor_impreso - 1)
	return definicion.valor_impreso
