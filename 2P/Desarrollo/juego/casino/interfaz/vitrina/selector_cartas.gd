extends ScrollContainer
## Selector visual de cartas para los servicios de baraja (I4-01). Muestra el cambio previsto
## en cada carta; las no elegibles siguen siendo enfocables y explican su motivo.

const Libro := preload("res://casino/interfaz/libro.gd")

signal carta_elegida(carta: CartaEnPartida)
signal motivo_consultado(texto: String)

var rejilla := GridContainer.new()
var botones: Array[Button] = []

func _init() -> void:
	name = "SelectorCartas"
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	follow_focus = true
	rejilla.columns = 5
	rejilla.add_theme_constant_override("h_separation", 6)
	rejilla.add_theme_constant_override("v_separation", 6)
	add_child(rejilla)

func presentar(servicio: String, campana: CampanaCasino) -> void:
	for boton in botones:
		rejilla.remove_child(boton)
		boton.queue_free()
	botones.clear()
	for carta in campana.baraja:
		var motivo := campana.impedimento(servicio, carta)
		# Sin saldo, el motivo de la carta sería el mismo para todas: se informa en el detalle.
		if motivo == "Fichas insuficientes.": motivo = ""
		var boton := Button.new()
		boton.custom_minimum_size = Vector2(74, 62)
		boton.text = "%s\n%s" % [_valor(carta), Palos.NOMBRES.get(carta.definicion.palo, "")]
		boton.add_theme_font_size_override("font_size", 14)
		boton.add_theme_stylebox_override("normal", Libro.caja(Color("2a1c12"), Color("6b5634")))
		var foco := Libro.caja(Color("3a2818"), Color("e2c27e"))
		boton.add_theme_stylebox_override("focus", foco)
		boton.add_theme_stylebox_override("hover", foco)
		boton.add_theme_stylebox_override("disabled", Libro.caja(Color("1a120b"), Color("3d3122")))
		boton.add_theme_color_override("font_color", Libro.PAPEL)
		boton.disabled = not motivo.is_empty()
		var cambio := _cambio(servicio, carta)
		var lectura := "%s de %s. %s" % [_valor(carta), Palos.NOMBRES.get(carta.definicion.palo, ""), motivo if not motivo.is_empty() else cambio]
		boton.tooltip_text = lectura
		boton.set_meta("motivo", motivo)
		boton.focus_entered.connect(motivo_consultado.emit.bind(lectura))
		boton.mouse_entered.connect(motivo_consultado.emit.bind(lectura))
		boton.pressed.connect(carta_elegida.emit.bind(carta))
		rejilla.add_child(boton)
		botones.append(boton)

func enfocar_primera() -> void:
	for boton in botones:
		if not boton.disabled:
			boton.grab_focus()
			return
	if not botones.is_empty(): botones[0].grab_focus()

static func _valor(carta: CartaEnPartida) -> String:
	return str(carta.definicion.valor_impreso)

## Texto del cambio que produciría el servicio en esa carta.
static func _cambio(servicio: String, carta: CartaEnPartida) -> String:
	var valor := carta.definicion.valor_impreso
	match servicio:
		"subir": return "Pasará a %s." % (valor + 1)
		"bajar": return "Pasará a %s." % (valor - 1)
	return "Saldrá de tu baraja."
