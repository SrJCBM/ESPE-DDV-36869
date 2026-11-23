extends Panel
## Selección y confirmación se hacen sobre la carta visible. La mesa envía el comando.

signal seleccion_cambiada(activa: bool)
signal devolucion_solicitada(id: String)

const Piezas := preload("res://mesa/piezas_mesa.gd")
var seleccionada := ""
var _lienzo: Control
var _mano: HBoxContainer
var _vista: Dictionary = {}
var _confirmacion: Label
var _confirmar: Button

func configurar(lienzo: Control, mano: HBoxContainer, scroll: ScrollContainer) -> void:
	_lienzo = lienzo
	_mano = mano
	name = "EleccionLlave"
	size = Vector2(280, 60)
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Color("10291e")
	fondo.border_color = Piezas.ORO
	fondo.set_border_width_all(1)
	add_theme_stylebox_override("panel", fondo)
	_confirmacion = Piezas.etiqueta(self, "", Rect2(5, 0, 270, 21), 12, Piezas.ORO)
	_confirmacion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_confirmar = Piezas.boton_texto(self, "ConfirmarLlave", "Confirmar", Rect2(4, 22, 132, 36), confirmar, 13)
	var boton_cancelar := Piezas.boton_texto(self, "CancelarLlave", "Cancelar", Rect2(144, 22, 132, 36), cancelar, 13)
	_confirmar.icon = preload("res://mesa/arte/confirmar-llave.svg")
	boton_cancelar.icon = preload("res://mesa/arte/cancelar-llave.svg")
	for boton in [_confirmar, boton_cancelar]:
		boton.add_theme_constant_override("icon_max_width", 22)
	Piezas.estilo_modal(_confirmar, true)
	Piezas.estilo_modal(boton_cancelar)
	boton_cancelar.tooltip_text = "Cancelar elección sin cambiar cartas ni campanadas. Esc."
	hide()
	scroll.get_h_scroll_bar().value_changed.connect(func(_valor: float) -> void: _posicionar())

func presentar(vista: Dictionary) -> void:
	cancelar(false)
	_vista = vista

func siguiente() -> void:
	var disponibles: Array = _vista.get("llaves_disponibles", [])
	if not disponibles.is_empty():
		seleccionar(str(disponibles[(disponibles.find(seleccionada) + 1) % disponibles.size()]))

func seleccionar(id: String) -> void:
	if not _es_elegible(id):
		return
	var carta := carta_por_id(id)
	if carta == null:
		return
	var anterior := carta_por_id(seleccionada)
	if anterior != null:
		anterior.establecer_seleccionada(false)
	seleccionada = id
	carta.establecer_seleccionada(true)
	_confirmacion.text = "DEVOLVER LLAVE %s · GRATIS" % carta._vista.get("valor", "—")
	_confirmar.tooltip_text = _confirmacion.text + ". Un reemplazo por mano."
	show()
	seleccion_cambiada.emit(true)
	_posicionar()
	_ajustar_tras_layout(id)
	_confirmar.grab_focus()

func confirmar() -> void:
	if seleccionada.is_empty():
		return
	var id := seleccionada
	cancelar()
	if _es_elegible(id):
		devolucion_solicitada.emit(id)

func cancelar(reponer_foco := true) -> void:
	if seleccionada.is_empty():
		return
	var carta := carta_por_id(seleccionada)
	seleccionada = ""
	hide()
	if carta != null:
		carta.establecer_seleccionada(false)
		if reponer_foco:
			carta.grab_focus()
	seleccion_cambiada.emit(false)

func carta_por_id(id: String) -> Control:
	if not id.is_empty():
		for carta in _mano.get_children():
			if str(carta.get_meta("carta_id", "")) == id:
				return carta
	return null

func _es_elegible(id: String) -> bool:
	return _vista.get("acciones", {}).get("devolver", false) and _vista.get("llaves_disponibles", []).has(id)

func _ajustar_tras_layout(id: String) -> void:
	# La fila y el scroll ordenan sus hijos antes de fijar la posición global.
	await get_tree().process_frame
	await get_tree().process_frame
	if seleccionada == id:
		_posicionar()

func _posicionar() -> void:
	var carta := carta_por_id(seleccionada)
	if carta != null:
		var centro: Vector2 = _lienzo.get_global_transform().affine_inverse() * carta.get_global_rect().get_center()
		position = Vector2(clampf(centro.x - 140, 405, 843), 537)
