extends Panel
## Diálogo, inventario y compras comparten la misma navegación por teclado.
const SERIF := preload("res://recursos/fuentes/CormorantGaramond.ttf")
const SANS := preload("res://recursos/fuentes/DMSans.ttf")
const ORO := Color("d5b578")
const PAPEL := Color("f1e4c9")
var lista: VBoxContainer
var cuerpo: Label
var cierre: Callable
var primero: Button

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

func presentar(titulo: String, texto: String, retrato: String, al_cerrar: Callable) -> void:
	for hijo in get_children():
		remove_child(hijo)
		hijo.queue_free()
	cierre = al_cerrar
	primero = null
	size = Vector2(920,526)
	position = Vector2(260,142)
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
	var marca := rotulo("LA ÚLTIMA MESA   /   REGISTRO DE LA CASA",13,ORO)
	marca.position = Vector2(x,25)
	add_child(marca)
	var nombre := rotulo(titulo,43,PAPEL,true)
	nombre.position = Vector2(x,50)
	add_child(nombre)
	cuerpo = rotulo("",20,PAPEL)
	cuerpo.clip_text = true
	cuerpo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(cuerpo)
	cuerpo.position = Vector2(x,118)
	cuerpo.size = Vector2(ancho,124)
	cuerpo.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	cuerpo.text = texto
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(x,250 if not retrato.is_empty() else 196)
	scroll.size = Vector2(ancho,526-scroll.position.y-35)
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	lista = VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.add_theme_constant_override("separation",6)
	scroll.add_child(lista)
	show()

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
