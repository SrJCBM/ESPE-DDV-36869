extends Node2D
## Corredor común con su arte (`corredor.webp`) y, encima, el estado de cada puerta (I4-02):
## la próxima se ilumina, las cerradas llevan candado y la placa dice su estado y, al
## acercarse, el requisito. Las posiciones salen de PlanoGaleria.

const FONDO := preload("res://casino/arte/corredor.webp")
const LETRA := preload("res://recursos/fuentes/DMSans.ttf")
const SERIF := preload("res://recursos/fuentes/CormorantGaramond.ttf")
const ORO := Color("cfaa64")
const APAGADO := Color("8e887c")
const PAPEL := Color("f4e5c8")
## Hoja de la puerta en el arte, respecto de su eje: arco superior a umbral.
const HOJA := Rect2(-50, 80, 100, 196)

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

## destino de la puerta cercana, o vacío. Solo esa placa muestra el requisito.
func resaltar(destino: String) -> void:
	if destino == _cercana:
		return
	_cercana = destino
	if is_instance_valid(_placas):
		_placas.queue_redraw()

func _draw() -> void:
	draw_texture_rect(FONDO, Rect2(0, 0, 1280, 720), false)
	var siguiente := PlanoGaleria.siguiente(campana)
	for destino: String in PlanoGaleria.PUERTAS:
		var x: float = PlanoGaleria.PUERTAS[destino].x
		if destino == siguiente:
			# Luz cálida: la hoja se aclara, el marco brilla y un halo suave cae al suelo.
			var hoja := Rect2(Vector2(x, 0) + HOJA.position, HOJA.size)
			draw_rect(hoja, Color(1.0, 0.82, 0.5, 0.16))
			draw_rect(hoja.grow(3), Color(1.0, 0.82, 0.45, 0.85), false, 2.0)
			for radio in [90.0, 64.0, 40.0]:
				draw_set_transform(Vector2(x, 312), 0.0, Vector2(1.0, 0.32))
				draw_circle(Vector2.ZERO, radio, Color(1.0, 0.8, 0.45, 0.06))
			draw_set_transform(Vector2.ZERO)
		elif not campana.puerta_abierta(destino):
			# La puerta cerrada se oscurece y lleva un candado, sin tapar el dibujo.
			draw_rect(Rect2(Vector2(x, 0) + HOJA.position, HOJA.size), Color(0.02, 0.03, 0.03, 0.42))
			_candado(Vector2(x, 176))

## Candado dibujado con primitivas: no depende de que la fuente tenga el glifo.
func _candado(centro: Vector2) -> void:
	draw_circle(centro + Vector2(0, 3), 22.0, Color(0.05, 0.06, 0.05, 0.78))
	draw_arc(centro + Vector2(0, -6), 9.0, PI, TAU, 16, APAGADO, 3.0)
	draw_rect(Rect2(centro + Vector2(-12, -6), Vector2(24, 20)), APAGADO)
	draw_circle(centro + Vector2(0, 3), 3.0, Color("15100c"))

func _dibujar_placas() -> void:
	for destino: String in PlanoGaleria.PUERTAS:
		var x: float = PlanoGaleria.PUERTAS[destino].x
		var estado := PlanoGaleria.estado(destino, campana)
		var marco := ORO if estado != "Cerrada" else APAGADO
		_placas.draw_rect(Rect2(x - 94, 232, 188, 46), Color("10221eef"))
		_placas.draw_rect(Rect2(x - 94, 232, 188, 46), marco, false, 1.2, true)
		_placas.draw_string(SERIF, Vector2(x - 92, 253), str(PlanoGaleria.PUERTAS[destino].placa), HORIZONTAL_ALIGNMENT_CENTER, 184, 21, PAPEL)
		var linea := estado
		if estado == "Cerrada" and destino == _cercana:
			linea = PlanoGaleria.requisito(destino)
		var color := Color("ffd38a") if estado == "Siguiente" else (Color("d9b8a0") if estado == "Cerrada" else Color("c8c0a8"))
		_placas.draw_string(LETRA, Vector2(x - 92, 272), linea, HORIZONTAL_ALIGNMENT_CENTER, 184, 14, color)
