extends PanelContainer
## Presenta el objetivo actual y anima solo un cambio de texto.

const Libro := preload("res://casino/interfaz/libro.gd")

var texto: Label
var cambios := 0
var _tween: Tween

func _ready() -> void:
	var franja := StyleBoxFlat.new()
	franja.bg_color = Color(0.02, 0.055, 0.043, 0.62)
	franja.set_corner_radius_all(3)
	franja.content_margin_left = 10
	franja.content_margin_right = 14
	franja.content_margin_top = 5
	franja.content_margin_bottom = 6
	add_theme_stylebox_override("panel", franja)
	position = Vector2(96, 64)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 9)
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fila)
	var rombo := Libro.rotulo("◆", 12, Libro.ORO)
	rombo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fila.add_child(rombo)
	texto = Libro.rotulo("", 18, Libro.PAPEL)
	texto.name = "TextoObjetivo"
	texto.add_theme_constant_override("shadow_offset_x", 1)
	texto.add_theme_constant_override("shadow_offset_y", 1)
	texto.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	fila.add_child(texto)

func presentar(objetivo: String, mostrar: bool) -> void:
	visible = mostrar
	if objetivo == texto.text:
		return
	var habia_texto := not texto.text.is_empty()
	texto.text = objetivo
	reset_size()
	if habia_texto:
		cambios += 1
		if _tween != null:
			_tween.kill()
		modulate.a = 0.0
		_tween = create_tween()
		_tween.tween_property(self, "modulate:a", 1.0, 0.4)
