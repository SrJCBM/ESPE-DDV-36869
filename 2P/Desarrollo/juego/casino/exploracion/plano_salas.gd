class_name PlanoSalas
extends RefCounted
## Huellas sobre el suelo del fondo cenital de 1280 × 720. La zona transitable
## deja paso a ambos lados de cada mesa, a los asientos y al portón del Dueño.

const LIMITES := Rect2(87, 178, 1106, 475)
const LIMITES_GALERIA := Rect2(48, 288, 1184, 310)
## Franjas que las paredes dibujadas ocupan dentro del recorrido rectangular.
const PAREDES := {
	"custodio": {
		"pared_oeste": [Vector2(87, 178), Vector2(128, 178), Vector2(125, 260), Vector2(100, 520), Vector2(87, 650)],
		"pared_este": [Vector2(1193, 178), Vector2(1152, 178), Vector2(1155, 260), Vector2(1180, 520), Vector2(1193, 650)],
	},
	"dueno": {
		"esquina_oeste": [Vector2(87, 178), Vector2(350, 178), Vector2(313, 201), Vector2(267, 225), Vector2(183, 262), Vector2(133, 281), Vector2(87, 300)],
		"esquina_este": [Vector2(1193, 178), Vector2(930, 178), Vector2(967, 201), Vector2(1013, 225), Vector2(1095, 262), Vector2(1147, 281), Vector2(1193, 300)],
	},
}
const MUEBLES := {
	"vestibulo": {
		"mostrador": Rect2(846, 165, 265, 102),
		"banco_oeste": Rect2(80, 463, 50, 175),
		"banco_este": Rect2(1152, 463, 55, 175),
		"maceta": Rect2(440, 178, 60, 62),
		"base_reloj": Rect2(570, 178, 140, 38),
	},
	"tienda": {
		"mostrador": Rect2(315, 165, 650, 128),
		"estante_oeste": Rect2(82, 178, 77, 375),
		"estante_este": Rect2(1120, 178, 78, 375),
		"vitrina_oeste": Rect2(85, 558, 240, 90),
		"vitrina_este": Rect2(955, 558, 240, 90),
	},
	"custodio": {
		"mesa": Rect2(450, 303, 382, 161),
		"silla_crupier": Rect2(600, 240, 84, 70),
		"silla_visitante": Rect2(599, 460, 86, 89),
		"aparador_oeste": Rect2(135, 278, 67, 165),
		"aparador_este": Rect2(1078, 278, 67, 165),
		"consola_oeste": Rect2(320, 178, 190, 58),
		"consola_este": Rect2(770, 178, 195, 58),
		"base_reloj": Rect2(600, 178, 115, 32),
		"columna_oeste": Rect2(130, 178, 38, 60),
		"columna_este": Rect2(1112, 178, 38, 60),
	},
	"recaudador": {
		"mesa": Rect2(432, 298, 410, 167),
		"silla_crupier": Rect2(600, 240, 84, 70),
		"silla_visitante": Rect2(603, 466, 82, 99),
		"vitrina_oeste": Rect2(175, 288, 75, 220),
		"vitrina_este": Rect2(1030, 288, 75, 220),
		"escritorio": Rect2(250, 178, 270, 70),
		"balanza": Rect2(570, 178, 145, 50),
		"cajonera": Rect2(790, 178, 260, 55),
		"columna_oeste": Rect2(87, 178, 25, 45),
		"columna_este": Rect2(1168, 178, 25, 45),
	},
	"coleccionista": {
		"mesa": Rect2(457, 285, 365, 149),
		"silla_crupier": Rect2(600, 230, 84, 65),
		"silla_visitante": Rect2(600, 436, 83, 95),
		"expositor_oeste": Rect2(220, 186, 85, 307),
		"expositor_este": Rect2(975, 186, 85, 307),
		"vitrina_oeste": Rect2(240, 513, 180, 125),
		"vitrina_este": Rect2(860, 513, 180, 125),
		"expositor_fondo": Rect2(340, 178, 600, 20),
		"columna_oeste": Rect2(87, 178, 95, 140),
		"columna_este": Rect2(1098, 178, 95, 140),
	},
	"dueno": {
		"mesa": Rect2(420, 319, 439, 154),
		"silla_crupier": Rect2(596, 274, 87, 60),
		"silla_visitante": Rect2(598, 470, 87, 86),
		"columna_oeste": Rect2(182, 238, 68, 52),
		"columna_este": Rect2(1028, 238, 64, 52),
	},
}

static func construir(sala: String, padre: Node2D) -> void:
	var area := LIMITES_GALERIA if sala == "corredor" else LIMITES
	var a := area.position
	var b := area.end
	_agregar(padre, "Norte", Rect2(a - Vector2(30,30), Vector2(area.size.x+60,30)))
	_agregar(padre, "Sur", Rect2(a.x-30,b.y,area.size.x+60,30))
	_agregar(padre, "Oeste", Rect2(a.x-30,a.y,30,area.size.y))
	_agregar(padre, "Este", Rect2(b.x,a.y,30,area.size.y))
	var muebles: Dictionary = MUEBLES.get(sala, {})
	for id: String in muebles:
		_agregar(padre, id, muebles[id])
	var paredes: Dictionary = PAREDES.get(sala, {})
	for id: String in paredes:
		var cuerpo := StaticBody2D.new()
		cuerpo.name = id
		var colision := CollisionPolygon2D.new()
		colision.polygon = PackedVector2Array(paredes[id])
		cuerpo.add_child(colision)
		padre.add_child(cuerpo)

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
