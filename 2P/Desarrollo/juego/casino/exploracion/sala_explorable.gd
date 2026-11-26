extends RefCounted
## Monta la sala y sus puntos de interacción. Devuelve la posición de entrada.

const Galeria := preload("res://casino/exploracion/galeria.gd")
const EntradaCasino := preload("res://casino/exploracion/entrada_casino.gd")
const PuertaVestibulo := preload("res://casino/exploracion/puerta_vestibulo.gd")
## Puerta este del vestíbulo, hacia el pasillo del Custodio.
const PUERTA_ESTE_VESTIBULO := Vector2(1150, 356)
const Libro := preload("res://casino/interfaz/libro.gd")
## Figuras del recorrido (I6-09). Los pies son el punto de apoyo sobre el suelo; el alto es el de
## la parte visible de la figura en píxeles del mundo, junto a Klein (Visitante.ALTO = 104), y la
## sombra, la fracción del ancho visible que ocupa la sombra de contacto (0: sin sombra, porque
## un mueble la tapa). La huella de colisión de cada figura está en PlanoSalas.MUEBLES.
const FIGURAS := {
	"vestibulo": [
		{"id": "anfitriona", "pies": Vector2(990, 231), "alto": 84.0, "sombra": 0.0},
		# El piano, contra el muro norte y bajo el aplique, con Amparo sentada al teclado.
		{"id": "amparo", "pies": Vector2(300, 262), "alto": 112.0, "sombra": 0.85},
		# La mesa de los jugadores, en el lateral oeste junto a la lámpara de pie.
		{"id": "jugador_porcelana", "pies": Vector2(210, 430), "alto": 118.0, "sombra": 0.72},
	],
	"pasillo_custodio": [
		{"id": "tobias", "pies": Vector2(475, 366), "alto": 96.0, "sombra": 0.9},
	],
	"pasillo_recaudador": [
		# El banco, contra el muro bajo la caja fuerte, con sitio para las piernas.
		{"id": "benavides", "pies": Vector2(960, 318), "alto": 96.0, "sombra": 0.9},
	],
	"tienda": [
		{"id": "anfitriona", "pies": Vector2(650, 174), "alto": 84.0, "sombra": 0.0},
	],
}
## Los jefes, sentados tras su mesa: la silla tapa la sombra.
const FIGURA_JEFE := {"pies": Vector2(640, 310), "alto": 95.0, "sombra": 0.0}

class SombraContacto extends Node2D:
	var radio := 20.0
	func _draw() -> void:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.28))
		draw_circle(Vector2.ZERO, radio, Color(0.02, 0.04, 0.03, 0.5))

var puntos: Array[Dictionary] = []
var _decorado: Node2D
var _marcas: Node2D

func _init(decorado: Node2D, marcas: Node2D) -> void:
	_decorado = decorado
	_marcas = marcas

func montar(sala: String, origen: String, campana: CampanaCasino, nombre_nota: String) -> Vector2:
	for capa in [_decorado, _marcas]:
		for hijo in capa.get_children():
			capa.remove_child(hijo)
			hijo.queue_free()
	puntos.clear()
	var entrada: Vector2
	if PlanoGaleria.es_pasillo(sala):
		var galeria := Galeria.new()
		galeria.pasillo = sala
		_decorado.add_child(galeria)
		_figuras(sala)
		for destino: String in PlanoGaleria.puertas(sala):
			var accion := "Entrar · %s" % CampanaCasino.NOMBRES[destino]
			_punto("puerta", PlanoGaleria.punto(sala, destino), accion, destino)
		entrada = PlanoGaleria.entrada(sala, origen)
	elif sala == "entrada":
		_decorado.add_child(EntradaCasino.new())
		_punto("puerta", EntradaCasino.UMBRAL, "Entrar al casino", "vestibulo")
		_punto("nota", EntradaCasino.FAROLA, "Examinar la farola")
		entrada = EntradaCasino.UMBRAL + Vector2(0, 70) if origen == "vestibulo" else Vector2(640, 593)
	else:
		var arte := Sprite2D.new()
		arte.texture = load("res://casino/arte/%s.webp" % sala)
		arte.centered = false
		arte.scale = Vector2(1280, 720) / arte.texture.get_size()
		_decorado.add_child(arte)
		_agregar_interacciones(sala, nombre_nota, campana)
		entrada = Vector2(640, 550 if sala == "vestibulo" else 593)
		if sala == "vestibulo" and PlanoGaleria.es_pasillo(origen):
			entrada = PUERTA_ESTE_VESTIBULO - Vector2(70, 0)
	PlanoSalas.construir(sala, _decorado)
	return entrada

func _agregar_interacciones(sala: String, nombre_nota: String, campana: CampanaCasino) -> void:
	var pasillo: String = PlanoGaleria.PADRE[sala]
	if sala == "vestibulo":
		# Se llega por la puerta de la calle y se sigue hacia delante, por la puerta del este.
		var puerta := PuertaVestibulo.new()
		puerta.abierta = campana.puerta_abierta(pasillo)
		_decorado.add_child(puerta)
		var accion := "Salir · %s" % CampanaCasino.NOMBRES[pasillo]
		_punto("puerta", PUERTA_ESTE_VESTIBULO, accion, pasillo)
		_punto("puerta", Vector2(640, 651), "Volver a la calle" if not campana.recibida else "La puerta se ha cerrado", "entrada")
	else:
		_punto("puerta", Vector2(640, 651), "Salir · %s" % CampanaCasino.NOMBRES[pasillo], pasillo)
	_figuras(sala)
	match sala:
		"vestibulo":
			_punto("anfitriona", Vector2(985, 279), "Hablar")
			_punto("nota", Vector2(640, 190), "Examinar el reloj")
		"tienda":
			_punto("tienda", Vector2(645, 290), "Abrir vitrina")
			_punto("nota", Vector2(168, 385), "Examinar la vitrina")
		_:
			_punto("mesa", Vector2(640, 521), "Hablar")
			_punto("nota", Vector2(235, 262), "Examinar " + nombre_nota.to_lower())
			if sala == "dueno":
				_punto("salida", Vector2(640, 188), "Abrir el portón")

static func figuras(sala: String) -> Array:
	if FIGURAS.has(sala):
		return FIGURAS[sala]
	if CampanaCasino.MESAS.has(sala):
		var jefe := FIGURA_JEFE.duplicate()
		jefe.id = sala
		return [jefe]
	return []

func _figuras(sala: String) -> void:
	for datos in figuras(sala):
		_figura(datos.id, datos.pies, datos.alto, datos.sombra)

## Rectángulo de la parte opaca de un recorte. Ignora el halo casi transparente del borde
## (alfa < 0,16), que `get_used_rect` sí cuenta. Se mide una vez por textura.
static var _visibles := {}

static func parte_visible(textura: Texture2D) -> Rect2:
	var clave := textura.resource_path
	if _visibles.has(clave):
		return _visibles[clave]
	var resultado := Rect2(Vector2.ZERO, textura.get_size())
	var imagen := textura.get_image()
	if imagen != null:
		if imagen.is_compressed():
			imagen.decompress()
		var minimo := Vector2i(imagen.get_width(), imagen.get_height())
		var maximo := Vector2i(-1, -1)
		for y in range(imagen.get_height()):
			for x in range(imagen.get_width()):
				if imagen.get_pixel(x, y).a >= 0.16:
					minimo = Vector2i(mini(minimo.x, x), mini(minimo.y, y))
					maximo = Vector2i(maxi(maximo.x, x), maxi(maximo.y, y))
		if maximo.x >= 0:
			resultado = Rect2(Vector2(minimo), Vector2(maximo - minimo + Vector2i.ONE))
	_visibles[clave] = resultado
	return resultado

## Coloca la figura apoyada por la base de su parte visible, no por el borde de la imagen: así
## el margen transparente de un recorte no la deja flotando ni cambia su escala.
func _figura(id: String, pies: Vector2, alto: float, sombra := 0.0) -> Sprite2D:
	var personaje := Sprite2D.new()
	personaje.name = "Figura_%s" % id
	personaje.texture = load("res://casino/arte/figura_%s.webp" % id)
	var visible_rect := parte_visible(personaje.texture)
	var escala := alto / visible_rect.size.y
	personaje.scale = Vector2.ONE * escala
	personaje.offset = personaje.texture.get_size() * 0.5 - Vector2(visible_rect.get_center().x, visible_rect.end.y)
	personaje.position = pies
	personaje.set_meta("visible", visible_rect)
	if sombra > 0.0:
		var contacto := SombraContacto.new()
		contacto.name = "Sombra_%s" % id
		contacto.radio = visible_rect.size.x * escala * sombra * 0.5
		contacto.position = pies + Vector2(0, -2)
		_decorado.add_child(contacto)
	_decorado.add_child(personaje)
	return personaje

func _punto(tipo: String, pos: Vector2, accion: String, destino := "") -> void:
	var marca: Label
	if tipo not in ["puerta", "salida"]:
		marca = Libro.rotulo("◇", 24, Libro.ORO)
		marca.add_theme_constant_override("outline_size", 5)
		marca.add_theme_color_override("font_outline_color", Color("15231e"))
		marca.position = pos - Vector2(10, 25)
		_marcas.add_child(marca)
	puntos.append({"tipo": tipo, "pos": pos, "accion": accion, "destino": destino, "marca": marca})

func cercano(posicion: Vector2) -> Dictionary:
	var distancia := 90.0
	var elegido := {}
	for punto in puntos:
		var nueva := posicion.distance_to(punto.pos)
		if nueva <= distancia:
			distancia = nueva
			elegido = punto
	return elegido

func marcar(elegido: Dictionary) -> void:
	for punto in puntos:
		if punto.marca != null:
			punto.marca.text = "◆" if punto == elegido else "◇"
