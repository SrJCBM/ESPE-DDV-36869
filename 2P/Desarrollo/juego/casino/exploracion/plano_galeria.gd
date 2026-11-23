class_name PlanoGaleria
extends RefCounted
## Organización del corredor común según la diapositiva «Plano del casino» (I4-02):
## las cuatro mesas al norte, en orden de izquierda a derecha, y el vestíbulo y la tienda
## al sur, bajo las dos primeras. La salida se alcanza desde la sala del Dueño.
## Las mesas usan sus puertas del arte de `corredor.webp`. El fondo todavía no tiene puertas
## al sur ni sustituye las dos primeras puertas del norte: ver el pedido en Diseno/ARTE_I4.md.

const NORTE := 302.0 ## Punto de interacción al pie de las puertas del norte.
const SUR := 572.0 ## Punto de interacción ante las puertas del sur, sobre la barandilla.
const PUERTAS := {
	"custodio": {"lado": "norte", "x": 538.0, "placa": "I · Custodio"},
	"recaudador": {"lado": "norte", "x": 739.0, "placa": "II · Recaudador"},
	"coleccionista": {"lado": "norte", "x": 940.0, "placa": "III · Coleccionista"},
	"dueno": {"lado": "norte", "x": 1141.0, "placa": "IV · Dueño"},
	"vestibulo": {"lado": "sur", "x": 538.0, "placa": "Vestíbulo"},
	"tienda": {"lado": "sur", "x": 739.0, "placa": "Tienda"},
}
## Puertas del arte que el plano no usa: se apagan y no tienen interacción.
const PUERTAS_SIN_USO := [136.0, 337.0]
const REQUISITOS := ["Habla con la anfitriona", "Falta el primer sello", "Falta el segundo sello", "Falta el tercer sello"]

static func norte(destino: String) -> bool:
	return PUERTAS[destino].lado == "norte"

static func punto(destino: String) -> Vector2:
	return Vector2(PUERTAS[destino].x, NORTE if norte(destino) else SUR)

## Al volver de una sala, el visitante queda frente a su puerta y con espacio para caminar.
static func entrada(origen: String) -> Vector2:
	var destino := origen if PUERTAS.has(origen) else "vestibulo"
	return Vector2(PUERTAS[destino].x, 375.0 if norte(destino) else 500.0)

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
