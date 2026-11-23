extends Control
## Vitrina del Gabinete de la anfitriona (I4-01). Coordina fichas, detalle y selector de cartas.
## La campaña valida y aplica cada compra; la vitrina solo la solicita y presenta el resultado.
## Esc vuelve del detalle al catálogo y del catálogo al mostrador; el foco regresa al producto.

const Libro := preload("res://casino/interfaz/libro.gd")
const FichaProducto := preload("res://casino/interfaz/vitrina/ficha_producto.gd")
const DetalleProducto := preload("res://casino/interfaz/vitrina/detalle_producto.gd")
const SelectorCartas := preload("res://casino/interfaz/vitrina/selector_cartas.gd")
const SaldoFichas := preload("res://casino/interfaz/hud/saldo_fichas.gd")
const SERVICIOS := ["eliminar", "subir", "bajar"]
const GLIFOS := {"eliminar": "✕", "subir": "+1", "bajar": "−1"}
const ARTE_SERVICIO := preload("res://cartas/arte/carta-llaves-grabado.png")

signal cerrada
signal compra_realizada(id: String)

var campana: CampanaCasino
var fichas: Array[FichaProducto] = []
var detalle := DetalleProducto.new()
var selector := SelectorCartas.new()
var saldo := SaldoFichas.new(32, 24)
var confirmacion := Label.new()
var _producto := ""
var _carta: CartaEnPartida

func _init() -> void:
	name = "VitrinaGabinete"
	size = Vector2(1440, 810)
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()

func _ready() -> void:
	var marco := Panel.new()
	marco.position = Vector2(120, 70)
	marco.size = Vector2(1200, 670)
	var madera := Libro.caja(Color("1c120b"), Libro.ORO)
	madera.set_border_width_all(2)
	marco.add_theme_stylebox_override("panel", madera)
	marco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(marco)
	var titulo := Libro.rotulo("Gabinete de la anfitriona", 36, Libro.PAPEL, true)
	titulo.position = Vector2(156, 86)
	add_child(titulo)
	saldo.position = Vector2(1140, 92)
	add_child(saldo)
	_seccion("OBJETOS", Vector2(156, 146))
	_seccion("TU BARAJA", Vector2(156, 432))
	var objetos := HBoxContainer.new()
	objetos.position = Vector2(156, 172)
	objetos.add_theme_constant_override("separation", 12)
	add_child(objetos)
	var baraja := HBoxContainer.new()
	baraja.position = Vector2(156, 458)
	baraja.add_theme_constant_override("separation", 12)
	add_child(baraja)
	for objeto: ObjetoTienda in CampanaCasino.TIENDA.objetos:
		var ficha := FichaProducto.new()
		var servicio := SERVICIOS.has(objeto.id)
		ficha.configurar(objeto, ARTE_SERVICIO if servicio else load("res://casino/arte/objeto_%s.webp" % objeto.id), GLIFOS.get(objeto.id, ""))
		ficha.pressed.connect(_elegir.bind(objeto.id))
		(baraja if servicio else objetos).add_child(ficha)
		fichas.append(ficha)
	detalle.position = Vector2(892, 146)
	detalle.size = Vector2(392, 300)
	detalle.custom_minimum_size = Vector2(392, 0)
	detalle.compra_confirmada.connect(_confirmar)
	add_child(detalle)
	# Cinco columnas y la barra de desplazamiento caben dentro del marco (borde derecho en 1320).
	selector.position = Vector2(892, 458)
	selector.size = Vector2(392, 206)
	selector.carta_elegida.connect(_elegir_carta)
	selector.motivo_consultado.connect(func(texto: String) -> void: detalle.aviso.text = texto)
	add_child(selector)
	confirmacion = Libro.rotulo("", 18, Libro.ORO)
	confirmacion.name = "Confirmacion"
	confirmacion.position = Vector2(156, 690)
	confirmacion.size = Vector2(700, 30)
	add_child(confirmacion)
	var salir := Libro.rotulo("Esc · volver al mostrador", 15, Color("b9a98a"))
	salir.position = Vector2(1040, 700)
	add_child(salir)

func _seccion(texto: String, posicion: Vector2) -> void:
	var rotulo := Libro.rotulo(texto, 14, Libro.ORO)
	rotulo.position = posicion
	add_child(rotulo)

func abrir(sesion: CampanaCasino) -> void:
	campana = sesion
	_producto = ""
	_carta = null
	confirmacion.text = ""
	show()
	_actualizar()
	detalle.vaciar("Compara precios a simple vista. Elige una pieza para ver su efecto antes de comprar.")
	selector.hide()
	fichas[0].grab_focus()

func cerrar() -> void:
	hide()
	cerrada.emit()

func _actualizar() -> void:
	saldo.presentar(campana.saldo)
	for ficha in fichas:
		ficha.presentar(not _motivo_general(ficha.id).is_empty())

## Motivo legible: el saldo insuficiente indica cuánto falta.
func _motivo(id: String, carta: CartaEnPartida) -> String:
	var objeto := CampanaCasino.TIENDA.buscar(id)
	if campana.saldo < objeto.precio:
		var faltan := objeto.precio - campana.saldo
		return "Falta 1 ficha." if faltan == 1 else "Faltan %s fichas." % faltan
	return campana.impedimento(id, carta)

## Bloqueo que no depende de la carta elegida (saldo, límites de objetos o de baraja).
func _motivo_general(id: String) -> String:
	if not SERVICIOS.has(id):
		return _motivo(id, null)
	var objeto := CampanaCasino.TIENDA.buscar(id)
	if campana.saldo < objeto.precio:
		return _motivo(id, null)
	if id == "eliminar" and campana.baraja.size() <= 12:
		return "Deben quedar doce cartas."
	return ""

func _elegir(id: String) -> void:
	_producto = id
	_carta = null
	confirmacion.text = ""
	var objeto := CampanaCasino.TIENDA.buscar(id)
	if SERVICIOS.has(id):
		var bloqueo := _motivo_general(id)
		detalle.presentar(objeto, objeto.descripcion, bloqueo if not bloqueo.is_empty() else "Elige la carta en el selector.", campana.saldo, false)
		selector.presentar(id, campana)
		selector.show()
		if bloqueo.is_empty():
			selector.enfocar_primera()
		return
	selector.hide()
	detalle.presentar(objeto, objeto.descripcion, _motivo(id, null), campana.saldo, true)
	if detalle.boton_comprar.visible:
		detalle.boton_comprar.grab_focus()

func _elegir_carta(carta: CartaEnPartida) -> void:
	_carta = carta
	var objeto := CampanaCasino.TIENDA.buscar(_producto)
	var cambio := "%s de %s. %s" % [carta.definicion.valor_impreso, Palos.NOMBRES.get(carta.definicion.palo, ""), SelectorCartas._cambio(_producto, carta)]
	detalle.presentar(objeto, "%s\n%s" % [objeto.descripcion, cambio], _motivo(_producto, carta), campana.saldo, true)
	if detalle.boton_comprar.visible:
		detalle.boton_comprar.grab_focus()

## Cobra y aplica una sola vez: la campaña rechaza la compra si algo cambió.
func _confirmar() -> void:
	if _producto.is_empty() or not campana.comprar(_producto, _carta):
		return
	var objeto := CampanaCasino.TIENDA.buscar(_producto)
	var vendido := _producto
	confirmacion.text = "Comprado: %s. Te quedan %s fichas." % [objeto.nombre, campana.saldo]
	compra_realizada.emit(vendido)
	_actualizar()
	_volver_al_catalogo()

func _volver_al_catalogo() -> void:
	var anterior := _producto
	_producto = ""
	_carta = null
	selector.hide()
	detalle.vaciar("Elige otra pieza o pulsa Esc para volver al mostrador.")
	for ficha in fichas:
		if ficha.id == anterior:
			ficha.grab_focus()
			return
	fichas[0].grab_focus()

func _unhandled_key_input(evento: InputEvent) -> void:
	if not visible or not evento is InputEventKey or not evento.pressed or evento.echo:
		return
	if evento.keycode == KEY_ESCAPE:
		if _producto.is_empty(): cerrar()
		else: _volver_al_catalogo()
		get_viewport().set_input_as_handled()
