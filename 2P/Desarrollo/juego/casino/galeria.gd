extends Node2D
## Las placas de la galería reflejan los sellos del intento.
const DESTINOS := ["vestibulo", "tienda", "custodio", "recaudador", "coleccionista", "dueno"]
const PLACAS := ["Vestíbulo","Gabinete","I  ·  Custodio","II  ·  Recaudador","III  ·  Coleccionista","IV  ·  Dueño"]
const FONDO := preload("res://casino/arte/corredor.webp")
const LETRA := preload("res://recursos/fuentes/CormorantGaramond.ttf")
var campana: CampanaCasino

static func eje(i: int) -> float:
	return 136.0 + 201.0 * i

func _draw() -> void:
	draw_texture_rect(FONDO,Rect2(0,0,1280,720),false)
	for i in range(DESTINOS.size()):
		var x := eje(i)
		var marco := Color("cfaa64") if campana.puerta_abierta(DESTINOS[i]) else Color("8e887c")
		draw_rect(Rect2(x-94,240,188,34),Color("10221eef"))
		draw_rect(Rect2(x-94,240,188,34),marco,false,1.2,true)
		draw_string(LETRA,Vector2(x-92,263),PLACAS[i],HORIZONTAL_ALIGNMENT_CENTER,184,22,Color("f4e5c8"))
