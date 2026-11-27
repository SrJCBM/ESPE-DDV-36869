extends PanelContainer
## Placa «Regla de la mesa» al pie del retrato del crupier (I3-03).

const Piezas = preload("res://mesa/piezas_mesa.gd")
## Borde inferior del retrato: la placa crece hacia arriba desde aquí para no tapar el umbral.
const PIE := 658.0

var texto: Label

func _init() -> void:
	name = "ReglaCrupier"
	var placa := StyleBoxFlat.new()
	placa.bg_color = Color(0.02, 0.06, 0.045, 0.86)
	placa.border_color = Piezas.ORO
	placa.border_width_top = 1
	placa.content_margin_left = 14
	placa.content_margin_right = 14
	placa.content_margin_top = 8
	placa.content_margin_bottom = 9
	add_theme_stylebox_override("panel", placa)
	position = Vector2(22, 580)
	size = Vector2(356, 78)
	custom_minimum_size = Vector2(356, 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 2)
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(columna)
	var rotulo := Label.new()
	rotulo.text = "REGLA DE LA MESA"
	rotulo.add_theme_font_size_override("font_size", Tipografia.MINIMA)
	rotulo.add_theme_color_override("font_color", Piezas.ORO)
	columna.add_child(rotulo)
	texto = Label.new()
	texto.name = "TextoRegla"
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.custom_minimum_size = Vector2(328, 0)
	texto.add_theme_font_size_override("font_size", Tipografia.MINIMA)
	texto.add_theme_color_override("font_color", Piezas.MARFIL)
	columna.add_child(texto)
	hide()

## Sin texto la placa se oculta: el Custodio y la mesa suelta no tienen regla especial.
func mostrar(regla: String) -> void:
	texto.text = regla
	visible = not regla.is_empty()
	if visible:
		reset_size()
		position.y = PIE - get_combined_minimum_size().y
