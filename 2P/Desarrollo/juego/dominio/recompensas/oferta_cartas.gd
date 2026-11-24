class_name OfertaCartas
extends RefCounted
## Una permutación parcial toma tres combinaciones distintas de palo y valor.
## Con la variante de I5, la tercera es una Vela que cuenta doble para Racha.

static func generar(azar: RandomNumberGenerator, con_vela_doble: bool = false) -> Array[CartaDef]:
	var bolsa: Array[int] = []
	for codigo in range(Palos.TODOS.size() * 10):
		bolsa.append(codigo)
	var opciones: Array[CartaDef] = []
	for turno in range(3):
		var codigo: int = bolsa.pop_at(azar.randi_range(0, bolsa.size() - 1))
		var palo := Palos.TODOS[floori(codigo / 10.0)]
		var valor := codigo % 10 + 1
		opciones.append(CartaDef.new("%s_%02d" % [palo, valor], palo, valor))
	if con_vela_doble:
		# Valor libre entre las Velas de las otras dos opciones: las tres siguen siendo distintas.
		var valores: Array[int] = []
		for valor in range(1, 11):
			var repetida := false
			for otra in opciones.slice(0, 2):
				repetida = repetida or (otra.palo == Palos.VELAS and otra.valor_impreso == valor)
			if not repetida:
				valores.append(valor)
		var elegido: int = valores[azar.randi_range(0, valores.size() - 1)]
		opciones[2] = CartaDef.new("%s_%02d_racha" % [Palos.VELAS, elegido], Palos.VELAS, elegido, CartaEnPartida.RASGO_RACHA_DOBLE)
	return opciones
