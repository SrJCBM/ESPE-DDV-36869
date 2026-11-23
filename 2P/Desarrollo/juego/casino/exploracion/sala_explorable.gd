extends RefCounted
## Monta la sala y sus puntos de interacción. Devuelve la posición de entrada.

const Galeria := preload("res://casino/exploracion/galeria.gd")
const Libro := preload("res://casino/interfaz/libro.gd")

var puntos: Array[Dictionary] = []
## Galería montada, para que resalte la puerta cercana; null fuera del corredor.
var galeria: Galeria
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
	galeria = null
	var entrada: Vector2
	if sala == "corredor":
		galeria = Galeria.new()
		galeria.campana = campana
		galeria.capa_placas = _marcas
		_decorado.add_child(galeria)
		for destino: String in PlanoGaleria.PUERTAS:
			var accion: String = "Entrar · %s" % CampanaCasino.NOMBRES[destino] if campana.puerta_abierta(destino) else PlanoGaleria.requisito(destino)
			_punto("puerta", PlanoGaleria.punto(destino), accion, destino)
		entrada = PlanoGaleria.entrada(origen)
	else:
		var arte := Sprite2D.new()
		arte.texture = load("res://casino/arte/%s.webp" % sala)
		arte.centered = false
		arte.scale = Vector2(1280, 720) / arte.texture.get_size()
		_decorado.add_child(arte)
		_agregar_interacciones(sala, nombre_nota)
		entrada = Vector2(640, 550 if sala == "vestibulo" else 593)
	PlanoSalas.construir(sala, _decorado)
	return entrada

func _agregar_interacciones(sala: String, nombre_nota: String) -> void:
	_punto("puerta", Vector2(640, 651), "Salir a la galería", "corredor")
	match sala:
		"vestibulo":
			_figura("anfitriona", Vector2(990, 231), 84)
			_punto("anfitriona", Vector2(985, 279), "Hablar")
			_punto("nota", Vector2(640, 190), "Examinar el reloj")
		"tienda":
			_figura("anfitriona", Vector2(650, 174), 84)
			_punto("tienda", Vector2(645, 290), "Abrir vitrina")
			_punto("nota", Vector2(168, 385), "Examinar la vitrina")
		_:
			_figura(sala, Vector2(640, 310), 95)
			_punto("mesa", Vector2(640, 521), "Hablar")
			_punto("nota", Vector2(235, 262), "Examinar " + nombre_nota.to_lower())
			if sala == "dueno":
				_punto("salida", Vector2(640, 188), "Abrir el portón")

func _figura(id: String, pies: Vector2, alto: float) -> void:
	var personaje := Sprite2D.new()
	personaje.texture = load("res://casino/arte/figura_%s.webp" % id)
	personaje.scale = Vector2.ONE * alto / personaje.texture.get_height()
	personaje.offset = Vector2(0, -personaje.texture.get_height() * 0.5)
	personaje.position = pies
	_decorado.add_child(personaje)

func _punto(tipo: String, pos: Vector2, accion: String, destino := "") -> void:
	var marca := Libro.rotulo("◇", 24, Libro.ORO)
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
		punto.marca.text = "◆" if punto == elegido else "◇"
	if galeria != null:
		galeria.resaltar(str(elegido.get("destino", "")) if elegido.get("tipo", "") == "puerta" else "")
