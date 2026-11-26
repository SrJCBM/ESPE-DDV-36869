extends VBoxContainer
## Presenta las pertenencias del intento en la exploración y en la pausa.

const Libro := preload("res://casino/interfaz/libro.gd")
const Sellos := preload("res://casino/interfaz/hud/sellos_campana.gd")
const Saldo := preload("res://casino/interfaz/hud/saldo_fichas.gd")

func presentar(campana: CampanaCasino) -> void:
	add_theme_constant_override("separation", 14)
	if not campana.recibida:
		var invitacion := Libro.rotulo("Una invitación lacrada y una ficha antigua.", 19, Libro.PAPEL)
		invitacion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		invitacion.custom_minimum_size.x = 320
		add_child(invitacion)
		return
	var cabecera := HBoxContainer.new()
	cabecera.add_theme_constant_override("separation", 10)
	cabecera.add_child(_placa("BARAJA", Libro.rotulo("%s cartas" % campana.baraja.size(), 28, Libro.PAPEL, true)))
	var fichas := Saldo.new(34, 23)
	fichas.presentar(campana.saldo)
	cabecera.add_child(_placa("FICHAS", fichas))
	var sellos := Sellos.new()
	sellos.presentar(campana.superadas, true)
	cabecera.add_child(_placa("SELLOS", sellos))
	add_child(cabecera)

	add_child(Libro.rotulo("OBJETOS", 13, Libro.ORO))
	var objetos := HBoxContainer.new()
	objetos.add_theme_constant_override("separation", 10)
	add_child(objetos)
	var detalle := Libro.rotulo("", 17, Libro.PAPEL)
	detalle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detalle.custom_minimum_size = Vector2(320, 48)
	for id in campana.amuletos:
		_objeto(objetos, detalle, id)
	if campana.lentes > 0:
		_objeto(objetos, detalle, "lente", campana.lentes)
	detalle.text = "Todavía no tienes objetos." if objetos.get_child_count() == 0 else "Elige un objeto para ver su efecto."
	add_child(detalle)

func _placa(titulo: String, valor: Control) -> PanelContainer:
	var placa := PanelContainer.new()
	placa.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var estilo := Libro.caja(Color("0b1c17"), Color("645c44"))
	estilo.border_width_top = 2
	placa.add_theme_stylebox_override("panel", estilo)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 2)
	columna.add_child(Libro.rotulo(titulo, 12, Libro.ORO))
	columna.add_child(valor)
	placa.add_child(columna)
	return placa

func _objeto(fila: HBoxContainer, detalle: Label, id: String, cantidad := 1) -> void:
	var producto := CampanaCasino.TIENDA.buscar(id)
	if producto == null:
		return
	var boton := Button.new()
	boton.custom_minimum_size = Vector2(112, 102)
	boton.add_theme_stylebox_override("normal", Libro.caja(Color("19392f"), Color("645c44")))
	boton.add_theme_stylebox_override("focus", Libro.caja(Color(0, 0, 0, 0), Libro.PAPEL))
	boton.add_theme_stylebox_override("hover", Libro.caja(Color("2c493b"), Libro.ORO))
	boton.accessibility_name = producto.nombre
	boton.tooltip_text = producto.nombre
	boton.icon = load("res://casino/arte/objeto_%s.webp" % id)
	boton.expand_icon = true
	boton.text = "×%s" % cantidad if cantidad > 1 else ""
	fila.add_child(boton)
	var mostrar := func() -> void: detalle.text = "%s · %s" % [producto.nombre, producto.descripcion]
	boton.focus_entered.connect(mostrar)
	boton.mouse_entered.connect(mostrar)
	boton.pressed.connect(mostrar)
