extends Panel
## Diálogo, inventario y compras comparten la misma navegación por teclado.
## I6-08: el panel mide el título y el párrafo antes de colocar la lista de cartas y botones,
## y crece (centrado y sin salir del lienzo) cuando la lista no cabe; si aun así no cabe, la
## lista se desplaza.
const SERIF := preload("res://recursos/fuentes/CormorantGaramond.ttf")
const SANS := preload("res://recursos/fuentes/DMSans.ttf")
const ORO := Color("d5b578")
const PAPEL := Color("f1e4c9")
var lista: VBoxContainer
var cuerpo: Label
var cierre: Callable
var primero: Button
const ANCHO := 920.0
const ALTO_MINIMO := 526.0
const ALTO_MAXIMO := 770.0 ## El lienzo mide 810: deja 20 de margen arriba y abajo.
const LIENZO_ALTO := 810.0
const MARGEN_INFERIOR := 35.0
var nombre: Label
var _desplazable: ScrollContainer
var _alto_minimo := ALTO_MINIMO

static func caja(color: Color, borde: Color) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = color
	estilo.border_color = borde
	estilo.set_border_width_all(1)
	for lado in [SIDE_LEFT,SIDE_RIGHT]: estilo.set_content_margin(lado,14)
	for lado in [SIDE_TOP,SIDE_BOTTOM]: estilo.set_content_margin(lado,6)
	return estilo

static func rotulo(texto: String, puntos: int, color: Color, titulo := false) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_font_override("font", SERIF if titulo else SANS)
	etiqueta.add_theme_font_size_override("font_size",puntos)
	etiqueta.add_theme_color_override("font_color",color)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return etiqueta

func presentar(titulo: String, texto: String, retrato: String, al_cerrar: Callable, alto_minimo := ALTO_MINIMO) -> void:
	for hijo in get_children():
		remove_child(hijo)
		hijo.queue_free()
	cierre = al_cerrar
	primero = null
	_alto_minimo = alto_minimo
	size = Vector2(ANCHO, _alto_minimo)
	position = Vector2(260, (LIENZO_ALTO - _alto_minimo) * 0.5)
	add_theme_stylebox_override("panel",caja(Color("10251f"),ORO))
	var x := 38
	if not retrato.is_empty():
		var imagen := TextureRect.new()
		imagen.texture = load(retrato)
		imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		imagen.position = Vector2(24,62)
		imagen.size = Vector2(236,365)
		add_child(imagen)
		x = 282
	var ancho := 920 - x - 38
	# Con salto de línea, una etiqueta calcula su alto con el ancho que ya tiene: se fija el
	# ancho antes del texto para que no se estire una palabra por línea.
	nombre = rotulo("",43,PAPEL,true)
	nombre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nombre.position = Vector2(x,30)
	nombre.size = Vector2(ancho, 0)
	add_child(nombre)
	nombre.text = titulo
	cuerpo = rotulo("",20,PAPEL)
	cuerpo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cuerpo.size = Vector2(ancho, 0)
	add_child(cuerpo)
	cuerpo.text = texto
	cuerpo.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	# El párrafo empieza bajo el título medido y ocupa exactamente las líneas que necesita.
	cuerpo.position = Vector2(x, nombre.position.y + _alto_texto(nombre, ancho) + 10)
	cuerpo.size = Vector2(ancho, _alto_texto(cuerpo, ancho))
	var scroll := ScrollContainer.new()
	var inicio := cuerpo.position.y + cuerpo.size.y + (18 if not texto.strip_edges().is_empty() else 0)
	scroll.position = Vector2(x, maxf(inicio, 250.0 if not retrato.is_empty() else 0.0))
	scroll.size = Vector2(ancho, _alto_minimo - scroll.position.y - MARGEN_INFERIOR)
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	lista = VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.add_theme_constant_override("separation",6)
	scroll.add_child(lista)
	_desplazable = scroll
	lista.minimum_size_changed.connect(ajustar)
	show()

## Alto que ocupa una etiqueta con salto de línea en el ancho dado.
static func _alto_texto(etiqueta: Label, ancho: float) -> float:
	if etiqueta.text.strip_edges().is_empty():
		return 0.0
	var fuente := etiqueta.get_theme_font("font")
	var puntos := etiqueta.get_theme_font_size("font_size")
	var medida := fuente.get_multiline_string_size(etiqueta.text, HORIZONTAL_ALIGNMENT_LEFT, ancho, puntos, -1, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE)
	return ceilf(medida.y)

## El panel crece hasta que la lista cabe entera o llega al alto máximo.
func ajustar() -> void:
	if _desplazable == null or lista == null:
		return
	var necesario := _desplazable.position.y + lista.get_combined_minimum_size().y + MARGEN_INFERIOR
	size.y = clampf(necesario, _alto_minimo, ALTO_MAXIMO)
	position.y = (LIENZO_ALTO - size.y) * 0.5
	_desplazable.size.y = size.y - _desplazable.position.y - MARGEN_INFERIOR

func opcion(texto: String, accion: Callable, habilitada := true) -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
	boton.custom_minimum_size.y = 38
	boton.add_theme_font_override("font",SANS)
	boton.add_theme_font_size_override("font_size",17)
	boton.add_theme_color_override("font_color",PAPEL)
	boton.add_theme_stylebox_override("normal",caja(Color("19392f"), Color("645c44")))
	boton.add_theme_stylebox_override("hover",caja(Color("2c493b"),ORO))
	boton.add_theme_stylebox_override("focus",caja(Color(0,0,0,0),PAPEL))
	boton.disabled = not habilitada
	boton.pressed.connect(accion)
	lista.add_child(boton)
	if habilitada and primero == null:
		primero = boton
		boton.grab_focus()
	return boton
