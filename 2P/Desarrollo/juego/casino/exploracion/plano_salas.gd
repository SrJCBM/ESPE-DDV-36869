class_name PlanoSalas
extends RefCounted
## Huellas sobre el suelo del fondo cenital de 1280 × 720. La zona transitable
## deja paso a ambos lados de cada mesa, a los asientos y al portón del Dueño.

const LIMITES := Rect2(87, 178, 1106, 475)
const LIMITES_GALERIA := Rect2(48, 288, 1184, 310)
const MUEBLES := {
	"entrada": {
		"fachada": Rect2(87, 178, 1106, 140),
	},
	"vestibulo": {
		"pared_norte_oeste": Rect2(87, 178, 360, 27),
		"pared_norte_centro": Rect2(482, 178, 63, 27),
		"reloj": Rect2(545, 178, 190, 37),
		"pared_norte_este": Rect2(735, 178, 126, 27),
		"mostrador": Rect2(861, 170, 247, 98),
		"banco_oeste": Rect2(87, 485, 40, 139),
		"banco_este": Rect2(1154, 485, 39, 139),
		"maceta": Rect2(447, 193, 35, 49),
	},
	"tienda": {
		"mostrador": Rect2(310, 180, 654, 120),
		"estante_oeste": Rect2(87, 178, 68, 377),
		"estante_este": Rect2(1121, 178, 72, 377),
		"vitrina_oeste": Rect2(87, 557, 228, 91),
		"vitrina_este": Rect2(955, 557, 238, 91),
	},
	"custodio": {
		"pared_norte": Rect2(87, 178, 1106, 24),
		"columna_oeste_norte": Rect2(87, 202, 40, 108),
		"columna_oeste_sur": Rect2(87, 443, 40, 192),
		"columna_este_norte": Rect2(1153, 202, 40, 104),
		"columna_este_sur": Rect2(1153, 449, 40, 186),
		"mesa": Rect2(450, 303, 382, 161),
		"silla_crupier": Rect2(600, 240, 84, 70),
		"silla_visitante": Rect2(599, 460, 86, 89),
		"aparador_oeste": Rect2(126, 310, 72, 133),
		"aparador_este": Rect2(1083, 306, 68, 143),
	},
	"recaudador": {
		"pared_norte_oeste": Rect2(87, 178, 160, 30),
		"pared_norte_centro": Rect2(524, 178, 44, 22),
		"balanza": Rect2(568, 178, 146, 72),
		"pared_norte_este": Rect2(714, 178, 89, 22),
		"pared_norte_fondo": Rect2(1049, 178, 144, 30),
		"mesa": Rect2(432, 298, 410, 167),
		"silla_crupier": Rect2(600, 240, 84, 70),
		"silla_visitante": Rect2(603, 466, 82, 99),
		"vitrina_oeste": Rect2(176, 303, 77, 188),
		"vitrina_este": Rect2(1023, 301, 79, 192),
		"escritorio": Rect2(247, 178, 277, 66),
		"cajonera": Rect2(803, 178, 246, 68),
	},
	"coleccionista": {
		"columna_oeste": Rect2(87, 178, 93, 140),
		"pared_norte_oeste": Rect2(180, 178, 38, 22),
		"pared_norte_centro": Rect2(306, 178, 663, 22),
		"pared_norte_este": Rect2(1064, 178, 34, 22),
		"columna_este": Rect2(1098, 178, 95, 140),
		"mesa": Rect2(457, 285, 365, 149),
		"silla_crupier": Rect2(600, 230, 84, 65),
		"silla_visitante": Rect2(600, 436, 83, 95),
		"expositor_oeste": Rect2(218, 178, 88, 318),
		"expositor_este": Rect2(969, 178, 95, 318),
		"vitrina_oeste": Rect2(228, 515, 193, 128),
		"vitrina_este": Rect2(853, 515, 193, 128),
	},
	"dueno": {
		"pilares_oeste": Rect2(87, 178, 190, 110),
		"pared_norte_oeste": Rect2(277, 178, 220, 25),
		"pared_norte_este": Rect2(783, 178, 220, 25),
		"pilares_este": Rect2(1003, 178, 190, 110),
		"mesa": Rect2(420, 319, 439, 154),
		"silla_crupier": Rect2(596, 274, 87, 60),
		"silla_visitante": Rect2(598, 470, 87, 86),
	},
}

static func construir(sala: String, padre: Node2D) -> void:
	var area := LIMITES_GALERIA if PlanoGaleria.es_pasillo(sala) else LIMITES
	var a := area.position
	var b := area.end
	_agregar(padre, "Norte", Rect2(a - Vector2(30,30), Vector2(area.size.x+60,30)))
	_agregar(padre, "Sur", Rect2(a.x-30,b.y,area.size.x+60,30))
	_agregar(padre, "Oeste", Rect2(a.x-30,a.y,30,area.size.y))
	_agregar(padre, "Este", Rect2(b.x,a.y,30,area.size.y))
	var muebles: Dictionary = MUEBLES.get(sala, {})
	for id: String in muebles:
		_agregar(padre, id, muebles[id])

static func _agregar(padre: Node2D, id: String, rect: Rect2) -> void:
	var cuerpo := StaticBody2D.new()
	cuerpo.name = id
	cuerpo.position = rect.get_center()
	var colision := CollisionShape2D.new()
	if id == "mesa":
		var x := rect.size.x * 0.5
		var y := rect.size.y * 0.5
		var poligono := ConvexPolygonShape2D.new()
		poligono.points = PackedVector2Array([
			Vector2(-x*0.78,-y), Vector2(x*0.78,-y), Vector2(x,-y*0.46),
			Vector2(x,y*0.46), Vector2(x*0.78,y), Vector2(-x*0.78,y),
			Vector2(-x,y*0.46), Vector2(-x,-y*0.46)])
		colision.shape = poligono
	else:
		var rectangulo := RectangleShape2D.new()
		rectangulo.size = rect.size
		colision.shape = rectangulo
	cuerpo.add_child(colision)
	padre.add_child(cuerpo)
