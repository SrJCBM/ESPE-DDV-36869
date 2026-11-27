extends RefCounted
## Inventario de la mesa (revisión de pantallas): fichas, la regla del crupier y cada objeto con
## su ilustración y los usos que le quedan en este encuentro. Se lee igual que las pertenencias
## del casino (tarjeta_objeto.gd). Solo construye controles dentro de `destino`.

const Piezas := preload("res://mesa/piezas_mesa.gd")
const TarjetaObjeto := preload("res://casino/interfaz/objetos/tarjeta_objeto.gd")
const SaldoFichas := preload("res://casino/interfaz/hud/saldo_fichas.gd")
const Libro := preload("res://casino/interfaz/libro.gd")
## Lo que cada mesa añade a las reglas de la casa; {retenidas} se rellena con la vista.
const REGLAS := {
	"recaudador": "Comisión de la casa: cada carta que pides tras el reparto cuesta una ficha.",
	"coleccionista": "Cartas retenidas hasta superar esta mesa: {retenidas}.",
	"dueno": "Cada mano cerrada sin Quiebra reduce el umbral un punto, hasta 17.",
}
const SIN_REGLA := "Esta mesa no añade reglas a las de la casa."

static func construir(destino: Control, campana: CampanaCasino, usos: Dictionary, vista: Dictionary) -> void:
	var cabecera := HBoxContainer.new()
	cabecera.position = Vector2(32, 84)
	cabecera.size = Vector2(696, 52)
	cabecera.add_theme_constant_override("separation", 12)
	destino.add_child(cabecera)
	var fichas := SaldoFichas.new(32, 22)
	fichas.presentar(campana.saldo)
	cabecera.add_child(_placa("FICHAS", fichas))
	var texto := str(REGLAS.get(campana.activa, SIN_REGLA)).format({"retenidas": vista.get("retenidas", 0)})
	var regla := Libro.rotulo(texto, 16, Piezas.MARFIL)
	regla.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	regla.custom_minimum_size = Vector2(470, 0)
	cabecera.add_child(_placa("REGLA DE ESTA MESA", regla, true))
	var rejilla := GridContainer.new()
	rejilla.columns = 2
	rejilla.position = Vector2(32, 168)
	rejilla.add_theme_constant_override("h_separation", 10)
	rejilla.add_theme_constant_override("v_separation", 10)
	destino.add_child(rejilla)
	for objeto in TarjetaObjeto.inventario(campana, usos):
		var tarjeta := TarjetaObjeto.new()
		tarjeta.configurar(objeto, 343.0)
		rejilla.add_child(tarjeta)
	if campana.amuletos.is_empty():
		var vacio := Piezas.etiqueta(destino, "Aún no tienes amuletos. Se compran en el Gabinete de la anfitriona.", Rect2(32, 560, 696, 30), 16, Piezas.MUTED)
		vacio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

static func _placa(titulo: String, valor: Control, expandir := false) -> PanelContainer:
	var placa := PanelContainer.new()
	if expandir: placa.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("0b1c17")
	estilo.border_color = Color("645c44")
	estilo.set_border_width_all(1)
	estilo.border_width_top = 2
	estilo.set_content_margin_all(8)
	estilo.content_margin_left = 14
	estilo.content_margin_right = 14
	placa.add_theme_stylebox_override("panel", estilo)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 2)
	columna.add_child(Libro.rotulo(titulo, 16, Piezas.ORO))
	columna.add_child(valor)
	placa.add_child(columna)
	return placa
