extends Button
## Ficha de la vitrina (I4-01): imagen, nombre y precio a la vista, para comparar sin abrirla.

const Libro := preload("res://casino/interfaz/libro.gd")
const FICHA := preload("res://recursos/hud/ficha_casino.png")

var id := ""
var imagen := TextureRect.new()
var nombre: Label
var precio: Label
var marca_bloqueo: Label

func configurar(objeto: ObjetoTienda, arte: Texture2D, glifo := "") -> void:
	id = objeto.id
	name = "Ficha_%s" % id
	custom_minimum_size = Vector2(168, 196)
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "%s · %s fichas" % [objeto.nombre, objeto.precio]
	var normal := Libro.caja(Color(0.96, 0.88, 0.7, 0.07), Color("6b5634"))
	var foco := Libro.caja(Color(0.96, 0.88, 0.7, 0.16), Color("e2c27e"))
	foco.set_border_width_all(2)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", foco)
	add_theme_stylebox_override("focus", foco)
	add_theme_stylebox_override("pressed", foco)
	# El modo de expansión va antes del tamaño: si no, el control crece hasta la textura.
	imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagen.texture = arte
	imagen.position = Vector2(14, 10)
	imagen.size = Vector2(140, 112)
	imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(imagen)
	if not glifo.is_empty():
		var signo := Libro.rotulo(glifo, 40, Libro.PAPEL)
		signo.position = Vector2(14, 34)
		signo.size = Vector2(140, 60)
		signo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		signo.add_theme_constant_override("outline_size", 8)
		signo.add_theme_color_override("font_outline_color", Color("1a120b"))
		add_child(signo)
	nombre = Libro.rotulo(objeto.nombre, 17, Libro.PAPEL, true)
	nombre.position = Vector2(8, 124)
	nombre.size = Vector2(152, 40)
	nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nombre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(nombre)
	var fila := HBoxContainer.new()
	fila.position = Vector2(8, 164)
	fila.size = Vector2(152, 26)
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fila)
	var icono := TextureRect.new()
	icono.texture = FICHA
	icono.custom_minimum_size = Vector2(22, 22)
	icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_child(icono)
	precio = Libro.rotulo(str(objeto.precio), 19, Libro.ORO)
	precio.name = "Precio"
	fila.add_child(precio)
	marca_bloqueo = Libro.rotulo("", 13, Color("d9b8a0"))
	marca_bloqueo.position = Vector2(8, 4)
	marca_bloqueo.size = Vector2(152, 18)
	marca_bloqueo.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(marca_bloqueo)

## Un producto bloqueado sigue siendo consultable; solo se atenúa y lleva un aviso breve.
func presentar(bloqueado: bool) -> void:
	imagen.modulate.a = 0.45 if bloqueado else 1.0
	marca_bloqueo.text = "No disponible" if bloqueado else ""
