class_name CampanaCasino
extends RefCounted
## Recursos de un intento local. Solo un encuentro activo puede pagar su recompensa.

const MESAS := ["custodio", "recaudador", "coleccionista", "dueno"]
const NOMBRES := {"vestibulo":"Vestíbulo", "corredor":"Galería de los sellos", "tienda":"Gabinete de la anfitriona", "custodio":"El Custodio", "recaudador":"El Recaudador", "coleccionista":"La Coleccionista", "dueno":"El Dueño de la Casa"}
## Usos por mesa del Sello del prudente (BALANCE_CAMPANA.md).
const USOS_PRUDENTE := 1
## Catálogos de datos (Resources): condiciones de las mesas y productos de la tienda.
const MESAS_CAMPANA: CatalogoMesas = preload("res://datos/mesas/mesas_campana.tres")
const TIENDA: CatalogoTienda = preload("res://datos/tienda/catalogo_tienda.tres")
var recibida := false
var saldo := 0
var superadas := 0
var activa := ""
var derrota := false
var lentes := 0
var amuletos: Array[String] = []
var baraja: Array[CartaEnPartida] = []
var ajustadas := {}
var _recompensas: Array[CartaDef] = []
var azar_recompensas := RandomNumberGenerator.new()

func recibir_invitacion() -> void:
	if recibida: return
	recibida = true
	saldo = 10
	baraja = FabricaCartas.crear_baraja()

## Condiciones de progreso que usan los diálogos: «sin_invitacion», «con_invitacion»,
## «sellos==N» y «sellos>=N». Una condición desconocida no se cumple.
func cumple(condicion: String) -> bool:
	match condicion:
		"sin_invitacion": return not recibida
		"con_invitacion": return recibida
	if condicion.begins_with("sellos==") and condicion.trim_prefix("sellos==").is_valid_int():
		return superadas == int(condicion.trim_prefix("sellos=="))
	if condicion.begins_with("sellos>=") and condicion.trim_prefix("sellos>=").is_valid_int():
		return superadas >= int(condicion.trim_prefix("sellos>="))
	push_warning("Condición de diálogo desconocida: %s" % condicion)
	return false

## Una elección de diálogo pide un cambio; la campaña decide si corresponde y lo aplica.
func atender(solicitud: String) -> bool:
	match solicitud:
		"entregar_invitacion":
			if recibida: return false
			recibir_invitacion()
			return true
	return false

## Objetivo de exploración derivado solo del progreso; tienda y paseos no lo cambian.
func objetivo() -> String:
	if not recibida: return "Habla con la anfitriona"
	match superadas:
		0: return "Encuentra la mesa del Custodio"
		1: return "Encuentra la mesa del Recaudador"
		2: return "Encuentra la mesa de la Coleccionista"
		3: return "Encuentra la mesa del Dueño de la Casa"
	return "Abre el portón del amanecer"

func puerta_abierta(sala: String) -> bool:
	var nivel := MESAS.find(sala)
	return nivel < 0 or (recibida and nivel <= superadas)

func iniciar(sala: String) -> bool:
	if derrota or not activa.is_empty() or hay_recompensa() or MESAS.find(sala) != superadas or not MESAS.has(sala) or not puerta_abierta(sala): return false
	activa = sala
	FabricaCrupieres.para(activa).al_sentarse(self)
	return true

func cerrar(victoria: bool, exactos: int) -> int:
	if activa.is_empty(): return 0
	activa = ""
	derrota = not victoria
	if derrota: return 0
	superadas += 1
	var premio := 10 + 5 * exactos
	saldo += premio
	if superadas < MESAS.size():
		_recompensas = OfertaCartas.generar(azar_recompensas)
	return premio

func hay_recompensa() -> bool:
	return not _recompensas.is_empty()

func opciones_recompensa() -> Array[Dictionary]:
	var opciones: Array[Dictionary] = []
	for carta in _recompensas:
		opciones.append({"palo": carta.palo, "valor": carta.valor_impreso})
	return opciones

## -1 omite la oferta. Un índice inválido conserva la decisión pendiente.
func resolver_recompensa(indice: int = -1) -> bool:
	if not hay_recompensa() or indice < -1 or indice >= _recompensas.size():
		return false
	if indice >= 0:
		var carta := _recompensas[indice]
		baraja.append(FabricaCartas.crear_carta(carta.palo, carta.valor_impreso))
	_recompensas.clear()
	return true

func impedimento(id: String, carta: CartaEnPartida = null) -> String:
	var producto := TIENDA.buscar(id)
	if producto == null or not recibida or derrota or not activa.is_empty() or hay_recompensa(): return "Compra no disponible."
	if saldo < producto.precio: return "Fichas insuficientes."
	if id == "lente" and lentes >= 2: return "Ya llevas dos consumibles."
	if amuletos.has(id): return "Ya llevas este amuleto."
	if id in ["eliminar", "subir", "bajar"]:
		if not baraja.has(carta): return "Selecciona una carta de tu baraja."
		if id == "eliminar": return "Deben quedar doce cartas." if baraja.size() <= 12 else ""
		if ajustadas.has(carta.id_instancia): return "Esta carta ya fue ajustada."
		if (id == "subir" and carta.definicion.valor_impreso >= 10) or (id == "bajar" and carta.definicion.valor_impreso <= 1): return "El valor debe quedar entre uno y diez."
	return ""

func comprar(id: String, carta: CartaEnPartida = null) -> bool:
	if not impedimento(id, carta).is_empty(): return false
	saldo -= TIENDA.buscar(id).precio
	match id:
		"lente": lentes += 1
		"eliminar": baraja.erase(carta)
		"subir", "bajar":
			carta.definicion.valor_impreso += 1 if id == "subir" else -1
			ajustadas[carta.id_instancia] = true
		_: amuletos.append(id)
	return true
