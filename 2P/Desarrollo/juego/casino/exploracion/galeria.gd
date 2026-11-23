extends Node2D
## Corredor común con formas simples, mientras se rehace su fondo (I4-02).
## Las puertas salen de PlanoGaleria. La próxima se ilumina, las cerradas llevan candado
## y, al acercarse, su placa muestra el requisito. El estado también se lee en la placa.

const LETRA := preload("res://recursos/fuentes/DMSans.ttf")
const SERIF := preload("res://recursos/fuentes/CormorantGaramond.ttf")
const SUELO := Rect2(48, 288, 1184, 310)
const ANCHO_PUERTA := 112.0
const ORO := Color("cfaa64")
const APAGADO := Color("8e887c")
const PAPEL := Color("f4e5c8")

var campana: CampanaCasino
## Capa del casino sobre el visitante y bajo los diálogos; sin ella, las placas van en la galería.
var capa_placas: Node2D
var _placas: Node2D
var _cercana := ""

func _ready() -> void:
	# Las placas quedan sobre el visitante para que se lean al acercarse a una puerta.
	_placas = Node2D.new()
	_placas.name = "Placas"
	_placas.draw.connect(_dibujar_placas)
	if capa_placas != null: capa_placas.add_child(_placas)
	else: add_child(_placas)

## destino de la puerta cercana, o vacío. Solo esa puerta muestra su requisito.
func resaltar(destino: String) -> void:
	if destino == _cercana:
		return
	_cercana = destino
	if is_instance_valid(_placas):
		_placas.queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color("0c1814"))
	draw_rect(Rect2(SUELO.position.x, 100, SUELO.size.x, SUELO.position.y - 100), Color("173a2d"))
	draw_rect(Rect2(SUELO.position.x, SUELO.end.y, SUELO.size.x, 720 - SUELO.end.y), Color("173a2d"))
	draw_rect(SUELO, Color("1d4636"))
	# Alfombra granate a lo largo del corredor.
	draw_rect(Rect2(SUELO.position.x, 418, SUELO.size.x, 56), Color("5a1f22"))
	draw_rect(Rect2(SUELO.position.x, 418, SUELO.size.x, 56), Color("8a5a35"), false, 2.0)
	var siguiente := PlanoGaleria.siguiente(campana)
	for destino: String in PlanoGaleria.PUERTAS:
		_dibujar_puerta(destino, destino == siguiente)

func _marco_puerta(destino: String) -> Rect2:
	var puerta: Dictionary = PlanoGaleria.PUERTAS[destino]
	if puerta.lado == "norte":
		return Rect2(puerta.x - ANCHO_PUERTA * 0.5, SUELO.position.y - 118, ANCHO_PUERTA, 118)
	return Rect2(puerta.x - ANCHO_PUERTA * 0.5, SUELO.end.y, ANCHO_PUERTA, 50)

func _dibujar_puerta(destino: String, es_siguiente: bool) -> void:
	var marco := _marco_puerta(destino)
	var abierta := campana.puerta_abierta(destino)
	if es_siguiente:
		# Luz cálida que sale de la próxima puerta hacia el corredor.
		var norte: bool = PlanoGaleria.PUERTAS[destino].lado == "norte"
		var luz := Rect2(marco.position.x - 18, SUELO.position.y if norte else SUELO.end.y - 70, marco.size.x + 36, 70)
		draw_rect(luz, Color(1.0, 0.78, 0.4, 0.16))
	draw_rect(marco, Color("2a1a10") if abierta else Color("15100c"))
	draw_rect(marco, ORO if abierta else APAGADO, false, 3.0)
	if not abierta:
		_candado(marco.get_center())

## Candado dibujado con primitivas: no depende de que la fuente tenga el glifo.
func _candado(centro: Vector2) -> void:
	draw_arc(centro + Vector2(0, -6), 9.0, PI, TAU, 16, APAGADO, 3.0)
	draw_rect(Rect2(centro + Vector2(-12, -6), Vector2(24, 20)), APAGADO)
	draw_circle(centro + Vector2(0, 3), 3.0, Color("15100c"))

func _dibujar_placas() -> void:
	for destino: String in PlanoGaleria.PUERTAS:
		var puerta: Dictionary = PlanoGaleria.PUERTAS[destino]
		var norte: bool = puerta.lado == "norte"
		var x: float = puerta.x
		var y := 114.0 if norte else 656.0
		var estado := PlanoGaleria.estado(destino, campana)
		var marco_color := ORO if estado != "Cerrada" else APAGADO
		_placas.draw_rect(Rect2(x - 96, y, 192, 46), Color("10221eef"))
		_placas.draw_rect(Rect2(x - 96, y, 192, 46), marco_color, false, 1.2, true)
		_placas.draw_string(SERIF, Vector2(x - 94, y + 21), str(puerta.placa), HORIZONTAL_ALIGNMENT_CENTER, 188, 21, PAPEL)
		var linea := estado
		if estado == "Cerrada" and destino == _cercana:
			linea = PlanoGaleria.requisito(destino)
		var color_linea := Color("ffd38a") if estado == "Siguiente" else (Color("d9b8a0") if estado == "Cerrada" else Color("c8c0a8"))
		_placas.draw_string(LETRA, Vector2(x - 94, y + 40), linea, HORIZONTAL_ALIGNMENT_CENTER, 188, 14, color_linea)
