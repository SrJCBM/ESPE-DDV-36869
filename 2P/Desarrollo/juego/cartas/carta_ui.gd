extends Button
## La carta solo recibe datos de presentación. Nunca consulta el dominio.

signal ampliacion_solicitada(carta: Dictionary)

const ARTE := {
	Palos.VELAS: preload("res://recursos/arte/carta-velas-grabado.png"),
	Palos.LLAVES: preload("res://recursos/arte/carta-llaves-grabado.png"),
	Palos.RELOJES: preload("res://recursos/arte/carta-relojes-grabado.png"),
	Palos.MASCARAS: preload("res://recursos/arte/carta-mascaras-grabado.png"),
}
const DURACION_SACUDIDA := 0.42
const NOMBRES := {Palos.VELAS: "VELAS", Palos.LLAVES: "LLAVES", Palos.RELOJES: "RELOJES", Palos.MASCARAS: "MÁSCARAS"}
var _vista: Dictionary = {}
var _valor: Label
var _palo: Label
var _efecto: Label
var _arte: TextureRect
var _visual: Control
var _animacion: Tween
var _movimiento_reducido := false
var _devolucion_disponible := false
var _seleccionada := false
var _patron_resaltado := false
var _marco: Panel
var _fondo: StyleBoxFlat

func _ready() -> void:
	clip_contents = false
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_visual = Control.new()
	_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_visual)
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Color("172d23")
	fondo.set_border_width_all(1)
	fondo.border_color = Color("d5b578")
	fondo.set_corner_radius_all(3)
	var marco := Panel.new()
	_marco = marco
	_fondo = fondo
	marco.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	marco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marco.add_theme_stylebox_override("panel", fondo)
	_visual.add_child(marco)
	for estado in ["normal", "hover", "pressed", "disabled"]:
		add_theme_stylebox_override(estado, StyleBoxEmpty.new())
	_arte = TextureRect.new()
	_arte.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_arte.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_arte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_visual.add_child(_arte)
	_valor = _etiqueta(34, Color("f1e4c9"))
	_valor.theme_type_variation = &"DisplayLabel"
	_palo = _etiqueta(14, Color("d5b578"))
	_efecto = _etiqueta(13, Color("b9c4a8"))
	resized.connect(_colocar)
	pressed.connect(func() -> void: ampliacion_solicitada.emit(_vista.duplicate(true)))
	mouse_entered.connect(_actualizar_enfasis)
	mouse_exited.connect(_actualizar_enfasis)
	focus_entered.connect(_actualizar_enfasis)
	focus_exited.connect(_actualizar_enfasis)
	_colocar()
	_actualizar()

func presentar(carta: Dictionary) -> void:
	# Whitelist: los datos de una Máscara se eliminan antes de almacenarlos.
	var oculta: bool = bool(carta.get("oculta", false))
	var revelar: bool = bool(_vista.get("oculta", false)) and not oculta
	_vista = {"palo": str(carta.get("palo", Palos.MASCARAS)), "oculta": oculta,
		"valor": null if oculta else carta.get("valor"),
		"valor_efectivo": null if oculta else carta.get("valor_efectivo")}
	if is_node_ready():
		_actualizar()
		if revelar and not _movimiento_reducido:
			# Volteo: la carta se cierra de canto y se abre con un leve rebote al mostrar su valor.
			_cancelar_animacion()
			_visual.scale = Vector2(0.08, 1.06)
			_animacion = create_tween()
			_animacion.tween_property(_visual, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _etiqueta(tamano: int, color: Color) -> Label:
	var etiqueta := Label.new()
	etiqueta.clip_text = true
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_visual.add_child(etiqueta)
	return etiqueta

func _colocar() -> void:
	if not is_instance_valid(_arte):
		return
	_visual.size = size
	_visual.pivot_offset = size * 0.5
	if size.x < 100:
		_valor.add_theme_font_size_override("font_size", 24)
		_palo.add_theme_font_size_override("font_size", 9)
		_efecto.add_theme_font_size_override("font_size", 8)
		_arte.position = Vector2(5, 32)
		_arte.size = Vector2(size.x - 10, size.y - 66)
		_valor.position = Vector2(3, 0)
		_valor.size = Vector2(size.x - 6, 32)
		_palo.position = Vector2(3, size.y - 33)
		_palo.size = Vector2(size.x - 6, 17)
		_efecto.position = Vector2(3, size.y - 17)
		_efecto.size = Vector2(size.x - 6, 15)
		return
	_arte.position = Vector2(8, 46)
	_arte.size = Vector2(size.x - 16, size.y - 103)
	_valor.position = Vector2(8, 0)
	_valor.size = Vector2(size.x - 16, 46)
	_palo.position = Vector2(8, size.y - 52)
	_palo.size = Vector2(size.x - 16, 26)
	_efecto.position = Vector2(8, size.y - 29)
	_efecto.size = Vector2(size.x - 16, 22)

func _actualizar() -> void:
	var palo: String = _vista.get("palo", Palos.MASCARAS)
	var oculta: bool = _vista.get("oculta", false)
	_arte.texture = ARTE.get(palo, ARTE[Palos.MASCARAS])
	_valor.text = "?" if oculta else str(_vista.get("valor", "—"))
	_palo.text = NOMBRES.get(palo, palo.to_upper())
	if oculta:
		_efecto.text = "OCULTA · 1–10"
	else:
		var efectivo: Variant = _vista.get("valor_efectivo")
		_efecto.text = "Cuenta como %s" % str(efectivo) if efectivo != null and efectivo != _vista.get("valor") else ""
	if _devolucion_disponible:
		_efecto.text = "LLAVE ELEGIDA" if _seleccionada else "Cambiar · L"
	tooltip_text = "%s. %s. %s. Activar para ampliar." % [NOMBRES.get(palo, palo), "Valor oculto" if oculta else "Valor %s" % _valor.text, _efecto.text]
	if oculta:
		tooltip_text = "%s. Valor oculto entre 1 y 10; se revela al plantarse. Activar para ampliar." % NOMBRES.get(palo, palo)
	elif _devolucion_disponible:
		tooltip_text = "Llave %s elegible. Activar para elegir; confirmar o cancelar en la mesa. No se devuelve hasta confirmar." % _valor.text
	for propiedad in get_property_list():
		if propiedad.name == "accessibility_name":
			set("accessibility_name", tooltip_text)

func establecer_devolucion_disponible(disponible: bool) -> void:
	_devolucion_disponible = disponible
	if is_node_ready(): _actualizar()

func establecer_seleccionada(seleccionada: bool) -> void:
	_seleccionada = seleccionada
	_actualizar_borde()
	_actualizar()
	_actualizar_enfasis()

func resaltar_patron(resaltar: bool, atenuar: bool = false) -> void:
	_patron_resaltado = resaltar
	set_meta("patron_resaltado", resaltar)
	# Solo baja el arte de las otras cartas: los valores siguen legibles.
	_arte.modulate.a = 0.45 if atenuar and not _seleccionada else 1.0
	_actualizar_borde()

func _actualizar_borde() -> void:
	var borde := _fondo.duplicate() as StyleBoxFlat
	borde.border_color = Color("f1e4c9") if _seleccionada else Color("d5b578")
	borde.set_border_width_all(3 if _seleccionada else (2 if _patron_resaltado else 1))
	_marco.add_theme_stylebox_override("panel", borde)

func establecer_movimiento_reducido(reducido: bool) -> void:
	_movimiento_reducido = reducido
	if reducido and is_instance_valid(_visual):
		_cancelar_animacion()

func _cancelar_animacion() -> void:
	if _animacion != null and _animacion.is_valid():
		_animacion.kill()
	_visual.position = Vector2.ZERO
	_visual.scale = Vector2.ONE
	_visual.rotation = 0.0
	_visual.modulate = Color.WHITE

func animar_entrada(retraso: float = 0.0) -> void:
	if _movimiento_reducido:
		return
	_cancelar_animacion()
	_visual.position.y = 15
	_visual.modulate.a = 0.45
	_animacion = create_tween().set_parallel(true)
	_animacion.tween_property(_visual, "position:y", 0.0, 0.24).set_delay(retraso).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_animacion.tween_property(_visual, "modulate:a", 1.0, 0.20).set_delay(retraso)

func _actualizar_enfasis() -> void:
	_cancelar_animacion()
	var activo := has_focus() or is_hovered() or _seleccionada
	z_index = 1 if activo else 0
	if _movimiento_reducido or not activo:
		return
	_animacion = create_tween().set_parallel(true)
	_animacion.tween_property(_visual, "position:y", -5.0, 0.13).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_animacion.tween_property(_visual, "scale", Vector2.ONE * 1.018, 0.13)

## Quiebra: sacudida breve que decae con trauma². Solo mueve el dibujo, nunca el botón ni su foco.
func sacudir(intensidad: float = 0.8) -> void:
	if _movimiento_reducido or not is_instance_valid(_visual):
		return
	_cancelar_animacion()
	_animacion = create_tween()
	_animacion.tween_method(_aplicar_sacudida.bind(intensidad, randf() * TAU), 1.0, 0.0, DURACION_SACUDIDA)
	_animacion.tween_callback(_volver_a_reposo)

func _aplicar_sacudida(trauma: float, intensidad: float, fase: float) -> void:
	var fuerza := trauma * trauma * intensidad
	# Senos a ritmos distintos: un temblor suave en lugar de ruido aleatorio cada frame.
	var t := (1.0 - trauma) * DURACION_SACUDIDA * 30.0
	_visual.position = Vector2(10.0 * fuerza * sin(t * 1.7 + fase), 3.0 * fuerza * sin(t * 2.3))
	_visual.rotation = 0.035 * fuerza * sin(t * 1.1 + fase)
	# Un solo tinte cálido que se desvanece: sin destellos repetidos.
	_visual.modulate = Color(1.0, 1.0 - 0.28 * trauma, 1.0 - 0.32 * trauma)

## Punto exacto: la carta salta y se asienta con rebote.
func celebrar(retraso: float = 0.0) -> void:
	if _movimiento_reducido or not is_instance_valid(_visual):
		return
	_cancelar_animacion()
	_animacion = create_tween()
	if retraso > 0.0:
		_animacion.tween_interval(retraso)
	_animacion.tween_property(_visual, "position:y", -16.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_animacion.parallel().tween_property(_visual, "scale", Vector2.ONE * 1.06, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_animacion.tween_property(_visual, "position:y", 0.0, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_animacion.parallel().tween_property(_visual, "scale", Vector2.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_animacion.tween_callback(_volver_a_reposo)

func _volver_a_reposo() -> void:
	_visual.position = Vector2.ZERO
	_visual.scale = Vector2.ONE
	_visual.rotation = 0.0
	_visual.modulate = Color.WHITE
