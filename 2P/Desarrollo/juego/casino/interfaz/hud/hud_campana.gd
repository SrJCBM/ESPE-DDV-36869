extends HBoxContainer
## Encabezado de la campaña (I4-04): los tres sellos y el saldo reemplazan «10 fichas · 0 / 3 sellos».
## Solo lee la campaña; nunca la modifica.

const SellosCampana := preload("res://casino/interfaz/hud/sellos_campana.gd")
const SaldoFichas := preload("res://casino/interfaz/hud/saldo_fichas.gd")

var sellos := SellosCampana.new()
var saldo := SaldoFichas.new()

func _init() -> void:
	name = "HudCampana"
	alignment = BoxContainer.ALIGNMENT_END
	add_theme_constant_override("separation", 18)
	mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(sellos)
	add_child(saldo)

## Antes de recibir la invitación no hay fichas: solo se ven los huecos de los sellos.
func presentar(campana: CampanaCasino, reducido := false) -> void:
	sellos.presentar(campana.superadas, reducido)
	saldo.visible = campana.recibida
	saldo.presentar(campana.saldo)
