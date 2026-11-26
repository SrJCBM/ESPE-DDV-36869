extends Control
## Plano de la sala y posición real del visitante. M alterna la vista de todo el casino.

const Libro := preload("res://casino/interfaz/libro.gd")
const AREA := Rect2(1136, 64, 208, 143)
const PLANO := Rect2(1148, 76, 184, 102)
const MUNDO := Vector2(1280, 720)
const CENTROS := {
	"entrada": Vector2(215, 442),
	"vestibulo": Vector2(408, 442),
	"pasillo_custodio": Vector2(604, 442),
	"pasillo_recaudador": Vector2(800, 442),
	"pasillo_coleccionista": Vector2(996, 442),
	"pasillo_dueno": Vector2(1192, 442),
	"custodio": Vector2(604, 281),
	"recaudador": Vector2(800, 281),
	"coleccionista": Vector2(996, 281),
	"dueno": Vector2(1192, 281),
	"tienda": Vector2(800, 588),
	"salida": Vector2(1192, 182),
}
const NOMBRES := {
	"entrada": "Entrada",
	"vestibulo": "Vestíbulo",
	"pasillo_custodio": "Pasillo I",
	"pasillo_recaudador": "Pasillo II",
	"pasillo_coleccionista": "Pasillo III",
	"pasillo_dueno": "Pasillo IV",
	"custodio": "Custodio",
	"recaudador": "Recaudador",
	"coleccionista": "Coleccionista",
	"dueno": "Dueño",
	"tienda": "Gabinete",
	"salida": "Salida",
}
const CONEXION := Color("a78b59")
const PAPEL := Color("f4e5c8")

var ampliado := false:
	set(valor):
		ampliado = valor
		queue_redraw()
var _sala := ""
var _posicion := Vector2.ZERO
var _puntos: Array[Dictionary] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	accessibility_name = "Plano del casino"

func presentar(sala: String, posicion: Vector2, puntos: Array[Dictionary]) -> void:
	if sala == _sala and posicion == _posicion:
		return
	_sala = sala
	_posicion = posicion
	_puntos = puntos
	queue_redraw()

func _draw() -> void:
	if ampliado:
		_dibujar_plano()
	elif not _sala.is_empty():
		_dibujar_sala()

func _dibujar_sala() -> void:
	draw_rect(AREA, Color(0.03, 0.09, 0.07, 0.68))
	draw_rect(AREA, Color(0.83, 0.71, 0.47, 0.45), false, 1)
	var factor := PLANO.size / MUNDO
	var limites := PlanoSalas.limites(_sala)
	var suelo := Rect2(PLANO.position + limites.position * factor, limites.size * factor)
	draw_rect(suelo, Color(0.83, 0.71, 0.47, 0.14))
	draw_rect(suelo, CONEXION, false, 1)
	for punto in _puntos:
		if punto.tipo in ["puerta", "salida"]:
			draw_circle(PLANO.position + Vector2(punto.pos) * factor, 2.6, Libro.ORO)
	var jugador := PLANO.position + _posicion * factor
	draw_circle(jugador, 5, Color("132b24"))
	draw_circle(jugador, 3.3, PAPEL)
	_centrar("M · Plano", Vector2(AREA.get_center().x, 195), AREA.size.x, 14)

func _dibujar_plano() -> void:
	draw_rect(Rect2(0, 0, 1440, 810), Color(0.02, 0.05, 0.04, 0.82))
	var panel := Rect2(113, 90, 1214, 629)
	draw_rect(panel, Color(0.04, 0.12, 0.09, 0.92))
	draw_rect(panel, CONEXION, false, 1.5)
	draw_string(Libro.SERIF, Vector2(160, 155), "Plano del casino", HORIZONTAL_ALIGNMENT_LEFT, -1, 38, PAPEL)
	_unir("entrada", "vestibulo")
	_unir("dueno", "salida")
	for sala: String in PlanoGaleria.PADRE:
		_unir(sala, PlanoGaleria.PADRE[sala])
	for i in range(1, PlanoGaleria.ORDEN.size()):
		_unir(PlanoGaleria.ORDEN[i - 1], PlanoGaleria.ORDEN[i])
	for sala: String in CENTROS:
		var centro: Vector2 = CENTROS[sala]
		var caja := Rect2(centro - Vector2(77, 22), Vector2(154, 44))
		draw_rect(caja, Color("365143") if sala == _sala else Color("132b24"))
		draw_rect(caja, Libro.ORO if sala == _sala else CONEXION, false, 2 if sala == _sala else 1)
		_centrar(NOMBRES[sala], centro + Vector2(0, 5), caja.size.x, 17)
	_centrar("M / Esc · Volver", Vector2(720, 674), 250, 16)

func _unir(origen: String, destino: String) -> void:
	draw_line(CENTROS[origen], CENTROS[destino], CONEXION, 2, true)

func _centrar(texto: String, centro: Vector2, ancho: float, tamano: int) -> void:
	draw_string(Libro.SANS, centro - Vector2(ancho / 2, 0), texto, HORIZONTAL_ALIGNMENT_CENTER, ancho, tamano, PAPEL)
