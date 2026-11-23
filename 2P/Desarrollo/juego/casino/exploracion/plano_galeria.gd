class_name PlanoGaleria
extends RefCounted
## Plano del corredor común según la diapositiva «Plano del casino» (I4-02).
## Las cuatro mesas quedan al norte, en orden de izquierda a derecha; el vestíbulo y
## la tienda conectan desde el sur. Coordenadas del mundo de 1280 × 720.

const NORTE := 300.0 ## Punto de interacción de las puertas del norte.
const SUR := 588.0 ## Punto de interacción de las puertas del sur.
const PUERTAS := {
	"custodio": {"lado": "norte", "x": 250.0, "placa": "I · Custodio"},
	"recaudador": {"lado": "norte", "x": 510.0, "placa": "II · Recaudador"},
	"coleccionista": {"lado": "norte", "x": 770.0, "placa": "III · Coleccionista"},
	"dueno": {"lado": "norte", "x": 1030.0, "placa": "IV · Dueño"},
	"vestibulo": {"lado": "sur", "x": 380.0, "placa": "Vestíbulo"},
	"tienda": {"lado": "sur", "x": 900.0, "placa": "Gabinete"},
}
const REQUISITOS := ["Habla con la anfitriona", "Falta el primer sello", "Falta el segundo sello", "Falta el tercer sello"]

static func punto(destino: String) -> Vector2:
	var puerta: Dictionary = PUERTAS[destino]
	return Vector2(puerta.x, NORTE if puerta.lado == "norte" else SUR)

## Al volver de una sala, el visitante queda frente a su puerta y con espacio para caminar.
static func entrada(origen: String) -> Vector2:
	var puerta: Dictionary = PUERTAS.get(origen, PUERTAS["vestibulo"])
	return Vector2(puerta.x, 372.0 if puerta.lado == "norte" else 512.0)

## Requisito breve de una mesa cerrada, para la placa y el aviso.
static func requisito(destino: String) -> String:
	var nivel := CampanaCasino.MESAS.find(destino)
	return REQUISITOS[nivel] if nivel >= 0 else ""

## Puerta que conduce al siguiente paso del intento: la que se ilumina.
static func siguiente(campana: CampanaCasino) -> String:
	if not campana.recibida:
		return "vestibulo"
	return CampanaCasino.MESAS[mini(campana.superadas, CampanaCasino.MESAS.size() - 1)]

## Estado de una puerta para la placa: el texto acompaña al icono y al color.
static func estado(destino: String, campana: CampanaCasino) -> String:
	var nivel := CampanaCasino.MESAS.find(destino)
	if not campana.puerta_abierta(destino): return "Cerrada"
	if nivel >= 0 and nivel < campana.superadas: return "Superada"
	if destino == siguiente(campana): return "Siguiente"
	return "Abierta"
