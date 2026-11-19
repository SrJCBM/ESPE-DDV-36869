extends Node2D
## Las placas de la galería reflejan los sellos del intento.
const DESTINOS := ["vestibulo", "tienda", "custodio", "recaudador", "coleccionista", "dueno"]
const PLACAS := ["Vestíbulo","Gabinete","I  ·  Custodio","II  ·  Recaudador","III  ·  Coleccionista","IV  ·  Dueño"]
const FONDO := preload("res://casino/arte/corredor.webp")
const LETRA := preload("res://recursos/fuentes/CormorantGaramond.ttf")
var campana: CampanaCasino
## Capa del casino sobre el visitante y bajo los diálogos; sin ella, las placas van en la galería.
var capa_placas: Node2D

static func eje(i: int) -> float:
	return 136.0 + 201.0 * i

func _ready() -> void:
	# Las placas quedan sobre el visitante para que se lean al acercarse a una puerta.
	var placas := Node2D.new()
	placas.name = "Placas"
	placas.draw.connect(_dibujar_placas.bind(placas))
	if capa_placas != null: capa_placas.add_child(placas)
	else: add_child(placas)

func _draw() -> void:
	draw_texture_rect(FONDO,Rect2(0,0,1280,720),false)

func _dibujar_placas(lienzo: Node2D) -> void:
	for i in range(DESTINOS.size()):
		var x := eje(i)
		var marco := Color("cfaa64") if campana.puerta_abierta(DESTINOS[i]) else Color("8e887c")
		lienzo.draw_rect(Rect2(x-94,240,188,34),Color("10221eef"))
		lienzo.draw_rect(Rect2(x-94,240,188,34),marco,false,1.2,true)
		lienzo.draw_string(LETRA,Vector2(x-92,263),PLACAS[i],HORIZONTAL_ALIGNMENT_CENTER,184,22,Color("f4e5c8"))
