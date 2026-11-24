class_name FabricaCartas
extends RefCounted
## Centraliza creación e impide compartir definiciones mutables entre intentos.

const CATALOGO = preload("res://datos/cartas/baraja_inicial.tres")

static func crear_baraja() -> Array[CartaEnPartida]:
	var cartas: Array[CartaEnPartida] = []
	for definicion: CartaDef in CATALOGO.cartas:
		assert(Palos.es_valido(definicion.palo), "Palo desconocido en el catálogo: %s" % definicion.id)
		cartas.append(CartaEnPartida.new(definicion.duplicate() as CartaDef))
	return cartas


static func crear_carta(palo: String, valor: int, identidad: String = "", rasgo: String = "") -> CartaEnPartida:
	assert(Palos.es_valido(palo), "Palo desconocido: %s" % palo)
	return CartaEnPartida.new(CartaDef.new("%s_%02d" % [palo, valor], palo, valor, rasgo), identidad)
