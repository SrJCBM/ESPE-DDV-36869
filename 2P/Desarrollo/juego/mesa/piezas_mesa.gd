extends RefCounted
## Constructores de los controles de la mesa: etiquetas, imágenes y botones con el estilo de la casa.

const ORO := Color("d5b578")
const MARFIL := Color("f1e4c9")
const MUTED := Color("b9c4a8")
const TINTA := Color("263a2b")
## Iconos de la ficha de coste de las acciones (I6-04).
const ICONO_CAMPANADA := "res://mesa/arte/icono_campanada.webp"
const ICONO_FICHA := "res://recursos/hud/ficha_casino.png"
const ANCHO_FICHA := 54.0

static func etiqueta(padre: Node, texto: String, rect: Rect2, tamano: int, color: Color, display := false) -> Label:
	var nueva := Label.new()
	# El texto no debe imponer su ancho mínimo antes de habilitar el ajuste.
	nueva.clip_text = true
	nueva.text = texto
	nueva.position = rect.position
	nueva.size = rect.size
	nueva.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nueva.add_theme_font_size_override("font_size", Tipografia.tamano(tamano))
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
	boton.add_theme_font_size_override("font_size", Tipografia.tamano(tamano))
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
	# Tecla a la izquierda; a su derecha, la acción y, si hay coste real, una línea propia
	# debajo con el coste (I6-08): el nombre y el coste nunca se cruzan.
	atajo.position = Vector2(12, (rect.size.y - 28) * 0.5)
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
	var titulo := etiqueta(boton, "", Rect2(46, (rect.size.y - 30) * 0.5, rect.size.x - 58, 30), 17, TINTA if primario else MARFIL)
	titulo.name = "Etiqueta"
	titulo.theme_type_variation = &"BoldLabel"
	titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# El coste completo («−1 campanada») queda como texto accesible; en pantalla se lee como una
	# ficha con icono y cantidad, en su propio espacio a la derecha del nombre (I6-04).
	var detalle := etiqueta(boton, "", Rect2(46, rect.size.y * 0.5 + 2, rect.size.x - 58, 20), 13, TINTA if primario else MUTED)
	detalle.name = "Coste"
	detalle.visible = false
	var ficha := Panel.new()
	ficha.name = "Ficha"
	ficha.position = Vector2(rect.size.x - ANCHO_FICHA - 10, (rect.size.y - 34) * 0.5)
	ficha.size = Vector2(ANCHO_FICHA, 34)
	ficha.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caja := StyleBoxFlat.new()
	caja.bg_color = Color(TINTA, 0.1) if primario else Color(0, 0, 0, 0.25)
	caja.border_color = TINTA if primario else ORO
	caja.set_border_width_all(1)
	caja.set_corner_radius_all(17)
	ficha.add_theme_stylebox_override("panel", caja)
	boton.add_child(ficha)
	var icono := imagen(ficha, ICONO_CAMPANADA, Rect2(6, 7, 20, 20), true)
	icono.name = "Icono"
	var cantidad := etiqueta(ficha, "", Rect2(27, 0, ANCHO_FICHA - 30, 34), 16, TINTA if primario else MARFIL)
	cantidad.name = "Cantidad"
	cantidad.theme_type_variation = &"BoldLabel"
	cantidad.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ficha.hide()
	return boton

static func texto_accion(boton: Button, titulo: String, detalle: String) -> void:
	var nombre: Label = boton.get_node("Etiqueta")
	var coste: Label = boton.get_node("Coste")
	var ficha: Panel = boton.get_node("Ficha")
	nombre.text = titulo
	coste.text = detalle
	# El nombre siempre centrado en vertical; con coste, la ficha ocupa la derecha y el nombre
	# se acorta para no cruzarse con ella.
	var alto := boton.size.y
	nombre.position.y = (alto - 30) * 0.5
	nombre.size.x = boton.size.x - 56 - (ANCHO_FICHA + 4 if not detalle.is_empty() else 0.0)
	coste.visible = false
	ficha.visible = not detalle.is_empty()
	if ficha.visible:
		ficha.get_node("Cantidad").text = detalle.get_slice(" ", 0)
		var ruta := ICONO_FICHA if detalle.contains("ficha") else ICONO_CAMPANADA
		var icono: TextureRect = ficha.get_node("Icono")
		if icono.texture == null or icono.texture.resource_path != ruta:
			icono.texture = load(ruta)
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
