class_name CartaEnPartida
extends RefCounted
## La identidad pública no codifica el palo ni el valor de la carta.

const RASGO_RACHA_DOBLE := "racha_doble"

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


## Peso para Racha: la Vela de la variante de I5 cuenta como dos cartas del palo.
func peso_racha() -> int:
	return 2 if definicion.rasgo == RASGO_RACHA_DOBLE else 1


func es_mascara_oculta(vistas: Dictionary) -> bool:
	return definicion.palo == Palos.MASCARAS and not vistas.has(id_instancia)
