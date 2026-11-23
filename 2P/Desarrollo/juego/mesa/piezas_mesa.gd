extends RefCounted
## Constructores de los controles de la mesa: etiquetas, imágenes y botones con el estilo de la casa.

const ORO := Color("d5b578")
const MARFIL := Color("f1e4c9")
const MUTED := Color("b9c4a8")
const TINTA := Color("263a2b")

static func etiqueta(padre: Node, texto: String, rect: Rect2, tamano: int, color: Color, display := false) -> Label:
	var nueva := Label.new()
	# El texto no debe imponer su ancho mínimo antes de habilitar el ajuste.
	nueva.clip_text = true
	nueva.text = texto
	nueva.position = rect.position
	nueva.size = rect.size
	nueva.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nueva.add_theme_font_size_override("font_size", tamano)
	nueva.add_theme_color_override("font_color", color)
	if display:
		nueva.theme_type_variation = &"DisplayLabel"
	padre.add_child(nueva)
	return nueva

static func imagen(padre: Node, ruta: String, rect: Rect2, conservar := false) -> TextureRect:
	var nueva := TextureRect.new()
	nueva.texture = load(ruta)
	nueva.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	nueva.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if conservar else TextureRect.STRETCH_SCALE
	nueva.position = rect.position
	nueva.size = rect.size
	nueva.mouse_filter = Control.MOUSE_FILTER_IGNORE
	padre.add_child(nueva)
	return nueva

static func boton_texto(padre: Node, nombre: String, texto: String, rect: Rect2, accion: Callable, tamano := 16) -> Button:
	var boton := Button.new()
	boton.name = nombre
	boton.text = texto
	boton.position = rect.position
	boton.size = rect.size
	boton.add_theme_font_size_override("font_size", tamano)
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	boton.pressed.connect(accion)
	padre.add_child(boton)
	return boton

## Botón principal de la mesa (Iniciar/Pedir, Plantarse): fondo, tecla, título y coste.
static func boton_accion(padre: Node, nombre: String, rect: Rect2, primario: bool, accion: Callable, tecla: String) -> Button:
	var boton := boton_texto(padre, nombre, "", rect, accion)
	var ruta := "res://mesa/arte/accion-primaria.svg" if primario else "res://mesa/arte/accion-secundaria.svg"
	var fondo := imagen(boton, ruta, Rect2(Vector2.ZERO, rect.size))
	fondo.name = "Fondo"
	var atajo := Panel.new()
	atajo.name = "Atajo"
	atajo.position = Vector2(12, 26)
	atajo.size = Vector2(28, 28)
	atajo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var borde := StyleBoxFlat.new()
	borde.bg_color = Color.TRANSPARENT
	borde.border_color = TINTA if primario else ORO
	borde.set_border_width_all(2)
	atajo.add_theme_stylebox_override("panel", borde)
	boton.add_child(atajo)
	var letra := etiqueta(atajo, tecla, Rect2(0, 0, 28, 28), 16, TINTA if primario else MARFIL)
	letra.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	letra.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var titulo := etiqueta(boton, "", Rect2(47, 14, rect.size.x - 59, 30), 17, TINTA if primario else MARFIL)
	titulo.name = "Etiqueta"
	titulo.theme_type_variation = &"BoldLabel"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var detalle := etiqueta(boton, "", Rect2(47, 44, rect.size.x - 59, 24), 13, TINTA if primario else MUTED)
	detalle.name = "Coste"
	detalle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return boton

static func texto_accion(boton: Button, titulo: String, detalle: String) -> void:
	boton.get_node("Etiqueta").text = titulo
	boton.get_node("Coste").text = detalle
	boton.tooltip_text = "%s. %s" % [titulo, detalle]
	for propiedad in boton.get_property_list():
		if propiedad.name == "accessibility_name":
			boton.set("accessibility_name", boton.tooltip_text)

static func estilo_modal(boton: Button, principal := false) -> void:
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = ORO if principal else Color("1d3628")
	fondo.border_color = ORO if principal else Color("6c7951")
	fondo.set_border_width_all(1)
	boton.add_theme_stylebox_override("normal", fondo)
	var hover := fondo.duplicate() as StyleBoxFlat
	hover.bg_color = Color("e7c993") if principal else Color("2c4532")
	boton.add_theme_stylebox_override("hover", hover)
	boton.add_theme_stylebox_override("pressed", hover)
	for estado in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		boton.add_theme_color_override(estado, TINTA if principal else MARFIL)
