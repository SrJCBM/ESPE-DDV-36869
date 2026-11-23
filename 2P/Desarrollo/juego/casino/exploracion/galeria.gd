extends Node2D
## Corredor común sobre su arte (`corredor.webp`) con la organización del plano (I4-02).
## Las mesas usan sus puertas del norte; el vestíbulo y la tienda abren al sur. Encima se
## marca el estado: la próxima puerta se ilumina, las cerradas llevan candado y la placa
## dice su estado y, al acercarse, el requisito. Las posiciones salen de PlanoGaleria.

const FONDO := preload("res://casino/arte/corredor.webp")
const LETRA := preload("res://recursos/fuentes/DMSans.ttf")
const SERIF := preload("res://recursos/fuentes/CormorantGaramond.ttf")
const ORO := Color("cfaa64")
const APAGADO := Color("8e887c")
const PAPEL := Color("f4e5c8")
## Hoja de una puerta del norte en el arte, respecto de su eje.
const HOJA := Rect2(-50, 80, 100, 196)
## Vano provisional de una puerta del sur sobre la barandilla, hasta tener su arte.
const VANO_SUR := Rect2(-58, 598, 116, 96)

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
	for x: float in PlanoGaleria.PUERTAS_SIN_USO:
		# Puertas del arte que el plano no usa: apagadas y sin placa.
		draw_rect(Rect2(Vector2(x, 0) + HOJA.position, HOJA.size), Color(0.02, 0.03, 0.03, 0.6))
	var siguiente := PlanoGaleria.siguiente(campana)
	for destino: String in PlanoGaleria.PUERTAS:
		var hoja := _hoja(destino)
		if not PlanoGaleria.norte(destino):
			_vano_sur(hoja)
		if destino == siguiente:
			# Luz cálida: la hoja se aclara, el marco brilla y un halo suave cae al suelo.
			draw_rect(hoja, Color(1.0, 0.82, 0.5, 0.16))
			draw_rect(hoja.grow(3), Color(1.0, 0.82, 0.45, 0.85), false, 2.0)
			var suelo := PlanoGaleria.punto(destino) + Vector2(0, 10 if PlanoGaleria.norte(destino) else -10)
			for radio in [90.0, 64.0, 40.0]:
				draw_set_transform(suelo, 0.0, Vector2(1.0, 0.32))
				draw_circle(Vector2.ZERO, radio, Color(1.0, 0.8, 0.45, 0.06))
			draw_set_transform(Vector2.ZERO)
		elif not campana.puerta_abierta(destino):
			draw_rect(hoja, Color(0.02, 0.03, 0.03, 0.42))
			_candado(hoja.get_center())

func _hoja(destino: String) -> Rect2:
	var x: float = PlanoGaleria.PUERTAS[destino].x
	var forma := HOJA if PlanoGaleria.norte(destino) else VANO_SUR
	return Rect2(Vector2(x, 0) + forma.position, forma.size)

## Vano de latón que interrumpe la barandilla: marcador provisional de las puertas del sur.
func _vano_sur(hoja: Rect2) -> void:
	draw_rect(hoja.grow(6), Color("2a1a10"))
	draw_rect(hoja, Color("120c08"))
	draw_rect(hoja.grow(6), ORO, false, 3.0)
	draw_line(Vector2(hoja.position.x - 6, hoja.position.y), Vector2(hoja.end.x + 6, hoja.position.y), Color("e2c27e"), 2.0)

## Candado dibujado con primitivas: no depende de que la fuente tenga el glifo.
func _candado(centro: Vector2) -> void:
	draw_circle(centro + Vector2(0, 3), 22.0, Color(0.05, 0.06, 0.05, 0.78))
	draw_arc(centro + Vector2(0, -6), 9.0, PI, TAU, 16, APAGADO, 3.0)
	draw_rect(Rect2(centro + Vector2(-12, -6), Vector2(24, 20)), APAGADO)
	draw_circle(centro + Vector2(0, 3), 3.0, Color("15100c"))

func _dibujar_placas() -> void:
	for destino: String in PlanoGaleria.PUERTAS:
		var x: float = PlanoGaleria.PUERTAS[destino].x
		var y := 232.0 if PlanoGaleria.norte(destino) else 644.0
		var estado := PlanoGaleria.estado(destino, campana)
		var marco := ORO if estado != "Cerrada" else APAGADO
		_placas.draw_rect(Rect2(x - 94, y, 188, 46), Color("10221eef"))
		_placas.draw_rect(Rect2(x - 94, y, 188, 46), marco, false, 1.2, true)
		_placas.draw_string(SERIF, Vector2(x - 92, y + 21), str(PlanoGaleria.PUERTAS[destino].placa), HORIZONTAL_ALIGNMENT_CENTER, 184, 21, PAPEL)
		var linea := estado
		if estado == "Cerrada" and destino == _cercana:
			linea = PlanoGaleria.requisito(destino)
		var color := Color("ffd38a") if estado == "Siguiente" else (Color("d9b8a0") if estado == "Cerrada" else Color("c8c0a8"))
		_placas.draw_string(LETRA, Vector2(x - 92, y + 40), linea, HORIZONTAL_ALIGNMENT_CENTER, 184, 14, color)
