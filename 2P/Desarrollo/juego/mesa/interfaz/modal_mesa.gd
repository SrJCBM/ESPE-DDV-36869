extends Control
## Diálogo de la mesa. Aísla el foco del fondo mientras permanece abierto.

const Piezas := preload("res://mesa/piezas_mesa.gd")
const Marco := preload("res://mesa/marco_casa.gd")
const MARCO_NORMAL := Rect2(340, 62, 760, 686)

signal foco_requerido

var panel := Panel.new()
var contenido := Control.new()
var _foco_anterior: Control
var _focos_suspendidos: Dictionary = {}

func _ready() -> void:
	size = get_parent().size
	hide()
	var sombra := ColorRect.new()
	sombra.color = Color(0.008, 0.025, 0.018, 0.93)
	sombra.size = size
	add_child(sombra)
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("10291e")
	estilo.border_color = Piezas.ORO
	estilo.set_border_width_all(1)
	estilo.set_corner_radius_all(2)
	panel.add_theme_stylebox_override("panel", estilo)
	add_child(panel)
	var marco := Marco.new()
	marco.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(marco)
	panel.add_child(contenido)

func abrir(titulo: String, caja: Rect2 = MARCO_NORMAL) -> void:
	panel.position = caja.position
	panel.size = caja.size
	contenido.size = panel.size
	if not visible:
		_foco_anterior = get_viewport().gui_get_focus_owner()
		for control in get_parent().find_children("*", "Control", true, false):
			if control != self and not is_ancestor_of(control):
				_suspender(control)
	for nodo in contenido.get_children():
		contenido.remove_child(nodo)
		nodo.queue_free()
	Piezas.etiqueta(contenido, titulo, Rect2(32, 22, 660, 54), 32, Piezas.ORO, true)
	show()

func cerrar() -> void:
	if not visible:
		return
	hide()
	for control in _focos_suspendidos:
		if is_instance_valid(control):
			control.focus_mode = _focos_suspendidos[control]
	_focos_suspendidos.clear()
	var anterior := _foco_anterior
	_foco_anterior = null
	if is_instance_valid(anterior) and anterior.is_visible_in_tree() and not (anterior is BaseButton and anterior.disabled):
		anterior.grab_focus()
	else:
		foco_requerido.emit()

func suspender_si_abierto(control: Control) -> void:
	if visible:
		_suspender(control)

func _suspender(control: Control) -> void:
	if control.focus_mode != Control.FOCUS_NONE and not _focos_suspendidos.has(control):
		_focos_suspendidos[control] = control.focus_mode
		control.focus_mode = Control.FOCUS_NONE

func boton_cerrar(texto := "VOLVER A LA MESA") -> Button:
	var boton := Piezas.boton_texto(contenido, "boton_cerrar_modal", "%s  ·  %s" % [texto, Acciones.tecla(Acciones.VOLVER)], Rect2(32, 618, 696, 42), cerrar)
	Piezas.estilo_modal(boton)
	boton.grab_focus()
	return boton

func pedir_confirmacion(mensaje: String, accion: Callable) -> void:
	var detalle := Piezas.etiqueta(contenido, mensaje, Rect2(48, 112, 724, 175), 22, Piezas.MARFIL)
	detalle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var confirmar := Piezas.boton_texto(contenido, "boton_confirmar", "CONFIRMAR", Rect2(424, 315, 348, 54), func() -> void:
		cerrar()
		accion.call())
	Piezas.estilo_modal(confirmar, true)
	var cancelar := boton_cerrar("CANCELAR")
	cancelar.position = Vector2(48, 315)
	cancelar.size = Vector2(348, 54)
	Piezas.etiqueta(contenido, "Tu partida solo cambia al confirmar.", Rect2(48, 406, 724, 32), 16, Piezas.MUTED)
