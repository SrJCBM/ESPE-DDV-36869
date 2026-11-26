class_name PlanoGaleria
extends RefCounted
## Pasillos de los jefes (I5). Cada pasillo es una pantalla con sus propias puertas: la mesa
## de su jefe al norte, la sala que le corresponde al sur y las puertas a los pasillos vecinos
## a los lados. El recorrido avanza de oeste a este: el vestíbulo queda al oeste del pasillo
## del Custodio (I5-10), así que desde la recepción se sigue hacia delante. Las puertas entre pasillos se abren con los sellos de `CampanaCasino.ACCESO`.

const NORTE := 302.0 ## Punto de interacción al pie de las puertas del norte.
const SUR := 602.0 ## Punto de interacción antes del primer escalón del Gabinete.
const LATERAL := 445.0 ## Altura de las puertas del este y del oeste.
const ESTE := 1195.0
const OESTE := 85.0
## Orden de los pasillos de oeste a este.
const ORDEN := ["pasillo_custodio", "pasillo_recaudador", "pasillo_coleccionista", "pasillo_dueno"]
const PASILLOS := {
	"pasillo_custodio": {
		"custodio": {"lado": "norte", "x": 640.0, "placa": "I · Custodio"},
		"vestibulo": {"lado": "oeste", "placa": "Vestíbulo"},
		"pasillo_recaudador": {"lado": "este", "placa": "Hacia el Recaudador"},
	},
	"pasillo_recaudador": {
		"recaudador": {"lado": "norte", "x": 640.0, "placa": "II · Recaudador"},
		"tienda": {"lado": "sur", "x": 640.0, "placa": "Tienda"},
		"pasillo_custodio": {"lado": "oeste", "placa": "Hacia el Custodio"},
		"pasillo_coleccionista": {"lado": "este", "placa": "Hacia la Coleccionista"},
	},
	"pasillo_coleccionista": {
		"coleccionista": {"lado": "norte", "x": 640.0, "placa": "III · Coleccionista"},
		"pasillo_recaudador": {"lado": "oeste", "placa": "Hacia el Recaudador"},
		"pasillo_dueno": {"lado": "este", "placa": "Hacia el Dueño"},
	},
	"pasillo_dueno": {
		"dueno": {"lado": "norte", "x": 640.0, "placa": "IV · Dueño"},
		"pasillo_coleccionista": {"lado": "oeste", "placa": "Hacia la Coleccionista"},
	},
}
## Pasillo al que sale cada sala.
const PADRE := {
	"vestibulo": "pasillo_custodio", "custodio": "pasillo_custodio",
	"recaudador": "pasillo_recaudador", "tienda": "pasillo_recaudador",
	"coleccionista": "pasillo_coleccionista", "dueno": "pasillo_dueno",
}

static func es_pasillo(sala: String) -> bool:
	return PASILLOS.has(sala)

static func puertas(pasillo: String) -> Dictionary:
	return PASILLOS.get(pasillo, {})

static func lado(pasillo: String, destino: String) -> String:
	return str(puertas(pasillo)[destino].lado)

static func norte(pasillo: String, destino: String) -> bool:
	return lado(pasillo, destino) == "norte"

static func punto(pasillo: String, destino: String) -> Vector2:
	var puerta: Dictionary = puertas(pasillo)[destino]
	match str(puerta.lado):
		"norte": return Vector2(puerta.x, NORTE)
		"sur": return Vector2(puerta.x, SUR)
		"este": return Vector2(ESTE, LATERAL)
	return Vector2(OESTE, LATERAL)

## Al llegar desde una sala o un pasillo, el visitante queda frente a esa puerta con espacio para caminar.
static func entrada(pasillo: String, origen: String) -> Vector2:
	var lista := puertas(pasillo)
	var destino: String = origen if lista.has(origen) else str(lista.keys()[0])
	var puerta: Dictionary = lista[destino]
	match str(puerta.lado):
		"norte": return Vector2(puerta.x, 375.0)
		"sur": return Vector2(puerta.x, SUR - 70.0)
		"este": return Vector2(ESTE - 70.0, LATERAL)
	return Vector2(OESTE + 70.0, LATERAL)

## Texto que aparece al intentar abrir una puerta cerrada.
static func requisito(destino: String) -> String:
	match destino:
		"pasillo_custodio": return "Habla con la anfitriona antes de seguir."
		"pasillo_recaudador": return "No tienes el sello necesario para abrir esta puerta."
	return "No tienes los sellos necesarios para abrir esta puerta."

## Sala a la que lleva el siguiente paso del intento.
static func objetivo(campana: CampanaCasino) -> String:
	if not campana.recibida:
		return "vestibulo"
	return CampanaCasino.MESAS[mini(campana.superadas, CampanaCasino.MESAS.size() - 1)]

## Puerta de este pasillo que acerca al siguiente paso: la que se ilumina.
static func siguiente(campana: CampanaCasino, pasillo: String) -> String:
	var meta := objetivo(campana)
	if puertas(pasillo).has(meta):
		return meta
	var aqui := ORDEN.find(pasillo)
	var alla := ORDEN.find(PADRE.get(meta, ""))
	var vecino: String = ORDEN[aqui + signi(alla - aqui)] if aqui >= 0 and alla >= 0 and alla != aqui else ""
	return vecino if puertas(pasillo).has(vecino) else ""

## Estado de una puerta para la placa: el texto acompaña al icono y a la luz.
static func estado(destino: String, campana: CampanaCasino, pasillo: String) -> String:
	var nivel := CampanaCasino.MESAS.find(destino)
	if not campana.puerta_abierta(destino): return "Cerrada"
	if nivel >= 0 and nivel < campana.superadas: return "Superada"
	if destino == siguiente(campana, pasillo): return "Siguiente"
	return "Abierta"
