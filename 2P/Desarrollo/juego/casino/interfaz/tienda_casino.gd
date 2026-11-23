extends RefCounted
## Presenta las compras en el libro. La campaña sigue validando y aplicando cada operación.

const Libro := preload("res://casino/interfaz/libro.gd")

signal compra_realizada

var _libro: Libro
var _campana: CampanaCasino
var _cerrar: Callable

func _init(libro: Libro, cerrar: Callable) -> void:
	_libro = libro
	_cerrar = cerrar

func abrir(campana: CampanaCasino) -> void:
	_campana = campana
	_catalogo()

func _catalogo() -> void:
	_libro.presentar("Gabinete de la anfitriona", "«Mira bien antes de gastar. Algunas piezas te acompañan toda la noche.»\nSaldo disponible: %s fichas." % _campana.saldo, "", _cerrar)
	for item: ObjetoTienda in CampanaCasino.TIENDA.objetos:
		_libro.opcion("%s    ·    %s fichas" % [item.nombre, item.precio], _elegir_producto.bind(item.id))
	_libro.opcion("Salir del gabinete", _cerrar)

func _elegir_producto(id: String) -> void:
	if id not in ["eliminar", "subir", "bajar"]:
		_confirmar_compra(id)
		return
	var item := CampanaCasino.TIENDA.buscar(id)
	_libro.presentar(item.nombre, "%s   ·   %s fichas. Saldo: %s." % [item.descripcion, item.precio, _campana.saldo], "", _catalogo)
	_libro.opcion("Volver al catálogo", _catalogo)
	for carta in _campana.baraja:
		var razon := _campana.impedimento(id, carta)
		var nombre := "%s · %s" % [carta.definicion.palo.capitalize(), carta.definicion.valor_impreso]
		_libro.opcion(nombre if razon.is_empty() else nombre + "   /   " + razon, _confirmar_compra.bind(id, carta), razon.is_empty())

func _confirmar_compra(id: String, carta: CartaEnPartida = null) -> void:
	var item := CampanaCasino.TIENDA.buscar(id)
	var razon := _campana.impedimento(id, carta)
	var detalle := item.descripcion + "\nPrecio: %s fichas. Saldo actual: %s." % [item.precio, _campana.saldo]
	if carta != null:
		detalle += " Carta: %s de %s." % [carta.definicion.valor_impreso, carta.definicion.palo]
	if not razon.is_empty():
		detalle += "\n" + razon
	var ilustracion := "res://casino/arte/objeto_%s.webp" % id if carta == null else ""
	_libro.presentar(item.nombre, detalle, ilustracion, _catalogo)
	if razon.is_empty():
		_libro.opcion("Confirmar compra", _comprar.bind(id, carta))
	_libro.opcion("Volver al catálogo", _catalogo)

func _comprar(id: String, carta: CartaEnPartida) -> void:
	if not _campana.comprar(id, carta):
		return
	compra_realizada.emit()
	_libro.presentar("Trato cerrado", "%s. Saldo tras la compra: %s fichas." % [CampanaCasino.TIENDA.buscar(id).nombre, _campana.saldo], "", _catalogo)
	_libro.opcion("Ver el catálogo", _catalogo)
	_libro.opcion("Dejar el mostrador", _cerrar)
