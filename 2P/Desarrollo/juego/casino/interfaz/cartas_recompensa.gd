extends HBoxContainer
## Muestra las cartas ofrecidas y emite el índice elegido.

const Carta := preload("res://cartas/carta.tscn")

signal elegida(indice: int)

func presentar(opciones: Array[Dictionary]) -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	theme = preload("res://temas/mesa.tres")
	add_theme_constant_override("separation", 22)
	for i in range(opciones.size()):
		var datos := opciones[i].duplicate()
		var carta := Carta.instantiate() as Button
		carta.custom_minimum_size = Vector2(164, 232)
		add_child(carta)
		datos.valor_efectivo = maxi(1, datos.valor - 1) if datos.palo == Palos.RELOJES else datos.valor
		carta.presentar(datos)
		carta.tooltip_text = "Añadir %s de %s a la baraja" % [datos.valor, Palos.NOMBRES[datos.palo]]
		if datos.get("rasgo", "") == CartaEnPartida.RASGO_RACHA_DOBLE:
			carta.tooltip_text += ". Cuenta como dos cartas para Racha; para el umbral vale %s" % datos.valor
		carta.accessibility_name = carta.tooltip_text
		carta.pressed.connect(elegida.emit.bind(i))
