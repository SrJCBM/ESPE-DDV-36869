class_name OfertaCartas
extends RefCounted
## Una permutación parcial toma tres combinaciones distintas de palo y valor.

static func generar(azar: RandomNumberGenerator) -> Array[CartaDef]:
	var bolsa: Array[int] = []
	for codigo in range(Palos.TODOS.size() * 10):
		bolsa.append(codigo)
	var opciones: Array[CartaDef] = []
	for turno in range(3):
		var codigo: int = bolsa.pop_at(azar.randi_range(0, bolsa.size() - 1))
		var palo := Palos.TODOS[floori(codigo / 10.0)]
		var valor := codigo % 10 + 1
		opciones.append(CartaDef.new("%s_%02d" % [palo, valor], palo, valor))
	return opciones
