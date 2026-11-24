class_name CampanaCasino
extends RefCounted
## Recursos de un intento local. Solo un encuentro activo puede pagar su recompensa.

const MESAS := ["custodio", "recaudador", "coleccionista", "dueno"]
const NOMBRES := {"entrada":"Entrada al casino", "vestibulo":"Vestíbulo", "pasillo_custodio":"Pasillo del Custodio", "pasillo_recaudador":"Pasillo del Recaudador", "pasillo_coleccionista":"Pasillo de la Coleccionista", "tienda":"Gabinete de la anfitriona", "custodio":"El Custodio", "recaudador":"El Recaudador", "coleccionista":"La Coleccionista", "dueno":"El Dueño de la Casa"}
## Usos por mesa del Sello del prudente (BALANCE_CAMPANA.md).
const USOS_PRUDENTE := 1
## Objetos que la anfitriona ofrece gratis al aceptar la invitación (I5). Uno por intento.
const OBJETOS_INICIALES := ["lente", "prudente", "moneda"]
## Sellos que exige cada espacio que no es una mesa (I5). Todos piden además la invitación;
## un espacio que no figura aquí está siempre abierto.
const ACCESO := {"pasillo_custodio": 0, "pasillo_recaudador": 1, "tienda": 1, "pasillo_coleccionista": 2}
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
## id_instancia → cambio aplicado (+1 o −1). Una carta solo se ajusta una vez por intento.
var ajustadas := {}
## id_instancia de las cartas ganadas como recompensa.
var ganadas := {}
## Cartas retiradas en la tienda: [{"palo", "valor"}].
var retiradas: Array[Dictionary] = []
## Variante de I5: una de las tres cartas de recompensa es una Vela que cuenta doble para Racha.
var variante_vela := true
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
## «objeto_inicial:<id>» entrega la baraja, las fichas y el objeto elegido en una sola
## operación; una segunda confirmación no entrega nada. «entregar_invitacion» entrega solo
## la baraja y las fichas (pruebas y capturas).
func atender(solicitud: String) -> bool:
	if solicitud == "entregar_invitacion":
		if recibida: return false
		recibir_invitacion()
		return true
	if solicitud.begins_with("objeto_inicial:"):
		var id := solicitud.trim_prefix("objeto_inicial:")
		if recibida or not OBJETOS_INICIALES.has(id): return false
		recibir_invitacion()
		if id == "lente": lentes += 1
		else: amuletos.append(id)
		return true
	return false

## Estado del intento como datos simples, para la partida guardada (I5). Solo se guarda
## entre encuentros: la mesa en curso (`activa`) y la derrota no forman parte de los datos.
func a_datos() -> Dictionary:
	var cartas := []
	for carta in baraja:
		cartas.append({"id": carta.id_instancia, "palo": carta.definicion.palo,
			"valor": carta.definicion.valor_impreso, "rasgo": carta.definicion.rasgo})
	var oferta := []
	for carta in _recompensas:
		oferta.append({"palo": carta.palo, "valor": carta.valor_impreso, "rasgo": carta.rasgo})
	return {
		"recibida": recibida, "saldo": saldo, "superadas": superadas, "lentes": lentes,
		"amuletos": Array(amuletos), "baraja": cartas, "ajustadas": ajustadas.duplicate(),
		"ganadas": ganadas.keys(), "retiradas": retiradas.duplicate(true),
		"recompensas": oferta, "variante_vela": variante_vela,
	}

## Reconstruye un intento desde `a_datos()`. Descarta lo que no sea válido (palos,
## valores, objetos desconocidos) en lugar de fallar: un archivo editado no rompe el juego.
static func desde_datos(datos: Dictionary) -> CampanaCasino:
	var c := CampanaCasino.new()
	c.recibida = bool(datos.get("recibida", false))
	c.saldo = maxi(0, int(datos.get("saldo", 0)))
	c.superadas = clampi(int(datos.get("superadas", 0)), 0, MESAS.size())
	c.lentes = clampi(int(datos.get("lentes", 0)), 0, 2)
	c.variante_vela = bool(datos.get("variante_vela", true))
	for id in datos.get("amuletos", []):
		if TIENDA.buscar(str(id)) != null and str(id) != "lente" and not c.amuletos.has(str(id)):
			c.amuletos.append(str(id))
	for d in datos.get("baraja", []):
		if not d is Dictionary or not _carta_valida(d): continue
		c.baraja.append(FabricaCartas.crear_carta(str(d.palo), int(d.valor), str(d.get("id", "")), str(d.get("rasgo", ""))))
	var ajustes: Dictionary = datos.get("ajustadas", {}) if datos.get("ajustadas") is Dictionary else {}
	for id in ajustes:
		c.ajustadas[str(id)] = clampi(int(ajustes[id]), -1, 1)
	for id in datos.get("ganadas", []):
		c.ganadas[str(id)] = true
	for d in datos.get("retiradas", []):
		if d is Dictionary and _carta_valida(d):
			c.retiradas.append({"palo": str(d.palo), "valor": int(d.valor)})
	for d in datos.get("recompensas", []):
		if d is Dictionary and _carta_valida(d):
			c._recompensas.append(CartaDef.new("%s_%02d" % [d.palo, int(d.valor)], str(d.palo), int(d.valor), str(d.get("rasgo", ""))))
	return c

static func _carta_valida(d: Dictionary) -> bool:
	return Palos.es_valido(str(d.get("palo", ""))) and int(d.get("valor", 0)) >= 1 and int(d.get("valor", 0)) <= 10

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
	if nivel >= 0: return recibida and nivel <= superadas
	if ACCESO.has(sala): return recibida and superadas >= int(ACCESO[sala])
	return true

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
		_recompensas = OfertaCartas.generar(azar_recompensas, variante_vela)
	return premio

func hay_recompensa() -> bool:
	return not _recompensas.is_empty()

func opciones_recompensa() -> Array[Dictionary]:
	var opciones: Array[Dictionary] = []
	for carta in _recompensas:
		opciones.append({"palo": carta.palo, "valor": carta.valor_impreso, "rasgo": carta.rasgo})
	return opciones

## -1 omite la oferta. Un índice inválido conserva la decisión pendiente.
func resolver_recompensa(indice: int = -1) -> bool:
	if not hay_recompensa() or indice < -1 or indice >= _recompensas.size():
		return false
	if indice >= 0:
		var carta := _recompensas[indice]
		var nueva := FabricaCartas.crear_carta(carta.palo, carta.valor_impreso, "", carta.rasgo)
		baraja.append(nueva)
		ganadas[nueva.id_instancia] = true
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
		"eliminar":
			baraja.erase(carta)
			retiradas.append({"palo": carta.definicion.palo, "valor": carta.definicion.valor_impreso})
		"subir", "bajar":
			var cambio := 1 if id == "subir" else -1
			carta.definicion.valor_impreso += cambio
			ajustadas[carta.id_instancia] = cambio
		_: amuletos.append(id)
	return true
