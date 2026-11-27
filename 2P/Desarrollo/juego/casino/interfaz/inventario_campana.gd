extends VBoxContainer
## Presenta las pertenencias del intento en la exploración y en la pausa.

const Libro := preload("res://casino/interfaz/libro.gd")
const Sellos := preload("res://casino/interfaz/hud/sellos_campana.gd")
const Saldo := preload("res://casino/interfaz/hud/saldo_fichas.gd")
const TarjetaObjeto := preload("res://casino/interfaz/objetos/tarjeta_objeto.gd")

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
	var datos := TarjetaObjeto.inventario(campana)
	if datos.is_empty():
		var vacio := Libro.rotulo("Todavía no tienes objetos. La anfitriona los vende en su gabinete.", 17, Libro.PAPEL)
		vacio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vacio.custom_minimum_size = Vector2(320, 0)
		add_child(vacio)
		return
	var rejilla := GridContainer.new()
	rejilla.name = "Objetos"
	rejilla.columns = 2
	rejilla.add_theme_constant_override("h_separation", 12)
	rejilla.add_theme_constant_override("v_separation", 12)
	add_child(rejilla)
	for objeto in datos:
		var tarjeta := TarjetaObjeto.new()
		tarjeta.configurar(objeto, 416.0)
		rejilla.add_child(tarjeta)

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
