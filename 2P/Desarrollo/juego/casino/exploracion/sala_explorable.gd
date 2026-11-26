extends RefCounted
## Monta la sala y sus puntos de interacción. Devuelve la posición de entrada.

const Galeria := preload("res://casino/exploracion/galeria.gd")
const EntradaCasino := preload("res://casino/exploracion/entrada_casino.gd")
const PuertaVestibulo := preload("res://casino/exploracion/puerta_vestibulo.gd")
## Puerta este del vestíbulo, hacia el pasillo del Custodio.
const PUERTA_ESTE_VESTIBULO := Vector2(1150, 356)
const Libro := preload("res://casino/interfaz/libro.gd")

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
		match sala:
			"pasillo_custodio":
				_figura("tobias", Vector2(475, 366), 94)
			"pasillo_recaudador":
				_figura("benavides", Vector2(894, 365), 86)
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
	match sala:
		"vestibulo":
			_figura("anfitriona", Vector2(990, 231), 84)
			_figura("amparo", Vector2(255, 316), 112)
			_figura("jugador_porcelana", Vector2(316, 540), 106)
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
