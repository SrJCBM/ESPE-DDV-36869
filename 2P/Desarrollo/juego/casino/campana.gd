class_name CampanaCasino
extends RefCounted
## Recursos de un intento local. Solo un encuentro activo puede pagar su recompensa.

const MESAS := ["custodio", "recaudador", "coleccionista", "dueno"]
const NOMBRES := {"vestibulo":"Vestíbulo", "corredor":"Galería de los sellos", "tienda":"Gabinete de la anfitriona", "custodio":"El Custodio", "recaudador":"El Recaudador", "coleccionista":"La Coleccionista", "dueno":"El Dueño de la Casa"}
## Usos por mesa del Sello del prudente (BALANCE_CAMPANA.md).
const USOS_PRUDENTE := 1
## [umbral, meta, campanadas] por mesa. Coleccionista y Dueño ajustados con tests/sim_campana.gd (BALANCE_CAMPANA.md).
const REGLAS := [[17,200,10], [21,400,12], [25,700,12], [25,750,18]]
const CATALOGO := {
	"lente": ["Lente de humo", 6, "Revela todas las Máscaras ocultas de la mano. Se consume al usarla."],
	"corona": ["Corona del riesgo", 15, "+2 al multiplicador al plantarte con una Máscara aún oculta en una mano válida."],
	"prudente": ["Sello del prudente", 12, "Recupera una campanada al quedar tres o más por debajo. Una vez por mesa."],
	"moneda": ["Moneda mellada", 10, "Gana dos fichas por un Punto exacto. Tres veces por mesa."],
	"eliminar": ["Retirar una carta", 4, "Elige una carta. Deben quedar al menos doce."],
	"subir": ["Ajustar valor +1", 5, "Elige una carta. Solo puedes ajustar su valor una vez por intento."],
	"bajar": ["Ajustar valor −1", 5, "Elige una carta. Solo puedes ajustar su valor una vez por intento."],
}
var recibida := false
var saldo := 0
var superadas := 0
var activa := ""
var derrota := false
var lentes := 0
var amuletos: Array[String] = []
var baraja: Array[CartaEnPartida] = []
var ajustadas := {}

func recibir_invitacion() -> void:
	if recibida: return
	recibida = true
	saldo = 10
	baraja = FabricaCartas.crear_baraja()

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
	if derrota or not activa.is_empty() or MESAS.find(sala) != superadas or not MESAS.has(sala) or not puerta_abierta(sala): return false
	activa = sala
	if activa == "recaudador": saldo += 15
	return true

func cerrar(victoria: bool, exactos: int) -> int:
	if activa.is_empty(): return 0
	activa = ""
	derrota = not victoria
	if derrota: return 0
	superadas += 1
	var premio := 10 + 5 * exactos
	saldo += premio
	return premio

func impedimento(id: String, carta: CartaEnPartida = null) -> String:
	if not CATALOGO.has(id) or not recibida or derrota or not activa.is_empty(): return "Compra no disponible."
	if saldo < int(CATALOGO[id][1]): return "Fichas insuficientes."
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
	saldo -= int(CATALOGO[id][1])
	match id:
		"lente": lentes += 1
		"eliminar": baraja.erase(carta)
		"subir", "bajar":
			carta.definicion.valor_impreso += 1 if id == "subir" else -1
			ajustadas[carta.id_instancia] = true
		_: amuletos.append(id)
	return true
