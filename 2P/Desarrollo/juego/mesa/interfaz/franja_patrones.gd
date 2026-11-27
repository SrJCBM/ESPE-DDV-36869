extends HBoxContainer
## Presenta patrones públicos y resalta las cartas relacionadas.
## Cada indicador muestra el nombre y el bono del patrón y, debajo, su estado breve; al
## enfocarlo, el espacio de detalle explica cómo conseguirlo. Tras resolver, se destacan
## los patrones aplicados.

signal detalle_cambiado(texto: String)
signal patron_solicitado(indice: int)
signal boton_creado(boton: Button)

const Lectura := preload("res://mesa/lectura_mesa.gd")
const Piezas := preload("res://mesa/piezas_mesa.gd")
var _mano: HBoxContainer
var _puede_resaltar: Callable
var _vista: Dictionary = {}
## Desde la revisión de pantallas la franja está siempre abierta mientras hay cartas en la mesa.
var abierta := false
var _raton := -1
var _foco := -1

func configurar(mano: HBoxContainer, puede_resaltar: Callable) -> void:
	_mano = mano
	_puede_resaltar = puede_resaltar
	position = Vector2(431, 552)
	size = Vector2(680, 43)
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 6)
	hide()

func presentar(vista: Dictionary) -> void:
	_vista = vista
	var patrones: Array = vista.get("patrones_visibles", [])
	ocultar_por_seleccion(false)
	for indice in range(patrones.size()):
		var boton: Button = get_child(indice) if indice < get_child_count() else _crear_boton(indice)
		_estilizar(boton, patrones[indice])
		boton.show()
		if boton.has_focus():
			_foco = indice
	for indice in range(patrones.size(), get_child_count()):
		get_child(indice).hide()
	_refrescar()

## Se mantiene visible al elegir una Llave para que la mesa no salte; solo deja de resaltar.
func ocultar_por_seleccion(_ocultar: bool) -> void:
	visible = abierta and not _vista.get("cartas", []).is_empty() and not _vista.get("patrones_visibles", []).is_empty()

## Si el foco está en uno de los patrones.
func tiene_foco() -> bool:
	return get_children().any(func(boton: Control) -> bool: return boton.has_focus())

func limpiar() -> void:
	_raton = -1
	_foco = -1
	for carta in _mano.get_children():
		carta.resaltar_patron(false)

func _crear_boton(indice: int) -> Button:
	var boton := Button.new()
	# 5 × 131 + 4 × 6 = 679: los cinco caben en los 680 de la franja.
	boton.custom_minimum_size = Vector2(131, 43)
	boton.add_theme_font_size_override("font_size", Tipografia.MINIMA)
	boton.clip_text = true
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	boton.pressed.connect(patron_solicitado.emit.bind(indice))
	boton.mouse_entered.connect(_senalar.bind(indice, true, true))
	boton.mouse_exited.connect(_senalar.bind(indice, false, true))
	boton.focus_entered.connect(_senalar.bind(indice, true, false))
	boton.focus_exited.connect(_senalar.bind(indice, false, false))
	add_child(boton)
	boton_creado.emit(boton)
	return boton

func _estilizar(boton: Button, datos: Dictionary) -> void:
	boton.text = "%s +%s\n%s" % [datos.nombre, datos.bono, Lectura.progreso(datos)]
	boton.tooltip_text = "%s +%s: %s. %s" % [datos.nombre, datos.bono, datos.detalle, datos.explicacion]
	if datos.condicionado:
		boton.tooltip_text += " Bono condicionado a no quebrar."
	var aplicado := _aplicado(datos.nombre)
	var color := Piezas.MUTED
	if aplicado or (datos.estado == "activo" and not datos.condicionado and _vista.get("fase", "") == "decision"):
		color = Piezas.ORO
	elif datos.estado == "pendiente" or datos.condicionado:
		color = Piezas.MARFIL
	boton.add_theme_color_override("font_color", color)
	boton.add_theme_color_override("font_focus_color", color)
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color.TRANSPARENT
	estilo.bg_color = Color(0.83, 0.71, 0.47, 0.16) if aplicado else Color.TRANSPARENT
	estilo.border_color = color if datos.estado == "activo" or aplicado else Color("526043")
	estilo.border_width_bottom = 2 if datos.estado == "activo" or aplicado else 1
	boton.set_meta("aplicado", aplicado)
	boton.add_theme_stylebox_override("normal", estilo)
	var hover := estilo.duplicate() as StyleBoxFlat
	hover.bg_color = Color("172d23")
	hover.border_color = Piezas.ORO
	hover.border_width_bottom = 2
	boton.add_theme_stylebox_override("hover", hover)
	boton.add_theme_stylebox_override("pressed", hover)

## Tras resolver una mano válida, los patrones que puntuaron quedan destacados.
func _aplicado(nombre: String) -> bool:
	if _vista.get("fase", "") == "decision":
		return false
	var mano: Dictionary = _vista.get("ultima_mano", {})
	return not mano.get("quiebra", true) and mano.get("patrones", []).has(nombre)

func _senalar(indice: int, entra: bool, raton: bool) -> void:
	if entra and not _puede_resaltar.call():
		return
	if raton:
		if entra: _raton = indice
		elif _raton == indice: _raton = -1
	else:
		if entra: _foco = indice
		elif _foco == indice: _foco = -1
	_refrescar()

func _refrescar() -> void:
	var indice := _raton if _raton >= 0 else _foco
	if not _puede_resaltar.call():
		indice = -1
	var detalle: Dictionary = Lectura.patron(_vista, indice)
	for i in range(_mano.get_child_count()):
		var resaltar: bool = detalle.indices.has(i)
		_mano.get_child(i).resaltar_patron(resaltar, indice >= 0 and not resaltar)
	var texto: String = detalle.texto
	var filas: Array = _vista.get("patrones_visibles", [])
	if indice >= 0 and indice < filas.size() and not texto.is_empty():
		# Nombre y bono en el único espacio de detalle; el indicador solo lleva símbolo y estado.
		texto = "+%s · %s · %s" % [filas[indice].bono, texto, Lectura.progreso(filas[indice])]
	detalle_cambiado.emit(texto)
