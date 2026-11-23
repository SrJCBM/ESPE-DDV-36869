class_name PlanoGaleria
extends RefCounted
## Puertas del corredor común, alineadas con el arte de `casino/arte/corredor.webp` (I4-02).
## Las seis puertas están en la pared del norte: el vestíbulo y el Gabinete a la izquierda y
## las cuatro mesas a continuación, en orden de progresión. Coordenadas del mundo de 1280 × 720.

const PUERTA_Y := 302.0 ## Punto de interacción, al pie de cada puerta.
const REGRESO_Y := 375.0 ## Al volver de una sala, el visitante queda frente a su puerta.
const PUERTAS := {
	"vestibulo": {"x": 136.0, "placa": "Vestíbulo"},
	"tienda": {"x": 337.0, "placa": "Gabinete"},
	"custodio": {"x": 538.0, "placa": "I · Custodio"},
	"recaudador": {"x": 739.0, "placa": "II · Recaudador"},
	"coleccionista": {"x": 940.0, "placa": "III · Coleccionista"},
	"dueno": {"x": 1141.0, "placa": "IV · Dueño"},
}
const REQUISITOS := ["Habla con la anfitriona", "Falta el primer sello", "Falta el segundo sello", "Falta el tercer sello"]

static func punto(destino: String) -> Vector2:
	return Vector2(PUERTAS[destino].x, PUERTA_Y)

## Al volver de una sala, el visitante queda frente a su puerta y con espacio para caminar.
static func entrada(origen: String) -> Vector2:
	return Vector2(PUERTAS.get(origen, PUERTAS["vestibulo"]).x, REGRESO_Y)

## Requisito breve de una mesa cerrada, para la placa y el aviso.
static func requisito(destino: String) -> String:
	var nivel := CampanaCasino.MESAS.find(destino)
	return REQUISITOS[nivel] if nivel >= 0 else ""

## Puerta que conduce al siguiente paso del intento: la que se ilumina.
static func siguiente(campana: CampanaCasino) -> String:
	if not campana.recibida:
		return "vestibulo"
	return CampanaCasino.MESAS[mini(campana.superadas, CampanaCasino.MESAS.size() - 1)]

## Estado de una puerta para la placa: el texto acompaña al icono y a la luz.
static func estado(destino: String, campana: CampanaCasino) -> String:
	var nivel := CampanaCasino.MESAS.find(destino)
	if not campana.puerta_abierta(destino): return "Cerrada"
	if nivel >= 0 and nivel < campana.superadas: return "Superada"
	if destino == siguiente(campana): return "Siguiente"
	return "Abierta"
