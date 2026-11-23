extends PanelContainer
## Detalle del producto elegido (I4-01): efecto, motivo si está bloqueado y, antes de cobrar,
## el coste y el saldo resultante. Solo presenta; la vitrina decide qué hacer al confirmar.

const Libro := preload("res://casino/interfaz/libro.gd")

signal compra_confirmada

var titulo: Label
var efecto: Label
var aviso: Label
var resto: Label
var boton_comprar := Button.new()
var contenedor := VBoxContainer.new()

func _init() -> void:
	name = "DetalleProducto"
	add_theme_stylebox_override("panel", Libro.caja(Color(0.07, 0.045, 0.03, 0.92), Color("8a6f43")))
	contenedor.add_theme_constant_override("separation", 12)
	add_child(contenedor)
	titulo = Libro.rotulo("", 30, Libro.PAPEL, true)
	titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	contenedor.add_child(titulo)
	efecto = Libro.rotulo("", 18, Libro.PAPEL)
	efecto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	efecto.custom_minimum_size.x = 320
	contenedor.add_child(efecto)
	aviso = Libro.rotulo("", 17, Color("e8b9a0"))
	aviso.name = "Aviso"
	aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	contenedor.add_child(aviso)
	resto = Libro.rotulo("", 17, Libro.ORO)
	resto.name = "SaldoResultante"
	resto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	contenedor.add_child(resto)
	boton_comprar.name = "Comprar"
	boton_comprar.custom_minimum_size = Vector2(0, 46)
	boton_comprar.add_theme_font_size_override("font_size", 18)
	boton_comprar.add_theme_stylebox_override("normal", Libro.caja(Color("6d5226"), Color("e2c27e")))
	var foco := Libro.caja(Color("8a6a31"), Color("fff0c8"))
	foco.set_border_width_all(2)
	boton_comprar.add_theme_stylebox_override("focus", foco)
	boton_comprar.add_theme_stylebox_override("hover", foco)
	boton_comprar.add_theme_color_override("font_color", Libro.PAPEL)
	boton_comprar.pressed.connect(compra_confirmada.emit)
	contenedor.add_child(boton_comprar)

func vaciar(texto: String) -> void:
	titulo.text = "Elige una pieza"
	efecto.text = texto
	aviso.text = ""
	resto.text = ""
	boton_comprar.hide()

## motivo vacío: se puede comprar. saldo_tras < 0 cuando falta saldo.
func presentar(objeto: ObjetoTienda, detalle: String, motivo: String, saldo: int, confirmable: bool) -> void:
	titulo.text = objeto.nombre
	efecto.text = detalle
	aviso.text = motivo
	var tras := saldo - objeto.precio
	resto.text = "Precio %s · saldo tras la compra: %s" % [objeto.precio, tras] if tras >= 0 else "Precio %s · saldo actual: %s" % [objeto.precio, saldo]
	boton_comprar.visible = confirmable and motivo.is_empty()
	boton_comprar.text = "Comprar · −%s fichas" % objeto.precio
