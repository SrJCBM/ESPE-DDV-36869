extends HBoxContainer
## Icono de ficha del casino con el saldo en cifras (I4-04). El mismo recuadro se usa
## en la exploración, la mesa y la vitrina; quien lo usa decide cuándo actualizarlo.

const FICHA := preload("res://recursos/hud/ficha_casino.png")
const LETRA := preload("res://recursos/fuentes/DMSans.ttf")

var icono := TextureRect.new()
var cifra := Label.new()

func _init(lado := 30.0, tamano_letra := 20) -> void:
	name = "Saldo"
	add_theme_constant_override("separation", 6)
	icono.texture = FICHA
	icono.custom_minimum_size = Vector2(lado, lado)
	icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(icono)
	cifra.name = "Cifra"
	cifra.add_theme_font_override("font", LETRA)
	cifra.add_theme_font_size_override("font_size", tamano_letra)
	cifra.add_theme_color_override("font_color", Color("f1e4c9"))
	cifra.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Cifras alineadas: el ancho no salta al pasar de 9 a 10 fichas.
	cifra.custom_minimum_size.x = tamano_letra * 1.9
	add_child(cifra)

func presentar(saldo: int) -> void:
	cifra.text = str(saldo)
	tooltip_text = "%s %s" % [saldo, "ficha" if saldo == 1 else "fichas"]
	icono.tooltip_text = tooltip_text
