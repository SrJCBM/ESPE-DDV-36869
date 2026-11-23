extends GutTest
## I3-08: los muebles detienen al visitante y ningún obstáculo cierra el paso a puertas, personajes o mesas.

const SALAS := ["vestibulo", "tienda", "custodio", "recaudador", "coleccionista", "dueno"]
const RADIO := 10.0 # radio de los pies del visitante (visitante.gd)
const ALCANCE := 90.0 # distancia de interacción (casino.gd, cercano)
const PASO := 10.0

func _casino_en(sala: String):
	var juego = load("res://casino/casino.tscn").instantiate()
	# Con tamaño cero la página se escala a cero y todo el mundo colapsa en un punto.
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	juego.campana.recibir_invitacion()
	juego.campana.superadas = 4
	juego.entrar(sala, "vestibulo")
	await get_tree().physics_frame
	await get_tree().physics_frame
	return juego

## Cada sala comparte el espacio físico: hay que retirar la anterior antes de medir la siguiente.
func _retirar(juego) -> void:
	juego.queue_free()
	await get_tree().physics_frame
	await get_tree().physics_frame

## ¿Cabe el círculo de los pies del visitante en este punto del mundo?
func _libre(juego, punto: Vector2) -> bool:
	var escala: float = juego.mundo.get_global_transform().get_scale().x
	var forma := CircleShape2D.new()
	forma.radius = RADIO * escala
	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = forma
	consulta.transform = Transform2D(0, juego.mundo.to_global(punto))
	consulta.exclude = [juego.visitante.get_rid()]
	return juego.mundo.get_world_2d().direct_space_state.intersect_shape(consulta, 1).is_empty()

func test_cada_mueble_detiene_al_visitante_que_camina_hacia_el() -> void:
	for sala: String in SALAS:
		var juego = await _casino_en(sala)
		var visitante: CharacterBody2D = juego.visitante
		for rect: Rect2 in juego.MUEBLES[sala]:
			# Desde el suelo libre más cercano bajo el mueble, camina hacia su centro.
			var inicio := Vector2(rect.get_center().x, rect.end.y + RADIO + 2)
			while not _libre(juego, inicio) and inicio.y < 700: inicio.y += PASO
			if inicio.y >= 700: continue # mueble contra el muro inferior: se prueba desde arriba
			var desde := Transform2D(0, juego.mundo.to_global(inicio))
			var hacia: Vector2 = juego.mundo.to_global(rect.get_center()) - desde.origin
			assert_true(visitante.test_move(desde, hacia), "%s: el visitante atraviesa %s" % [sala, rect])
		await _retirar(juego)

func test_los_puntos_de_interaccion_siguen_alcanzables() -> void:
	for sala: String in SALAS:
		var juego = await _casino_en(sala)
		# Relleno por pasos desde donde aparece el visitante.
		var origen: Vector2 = juego.visitante.position.snapped(Vector2(PASO, PASO))
		assert_true(_libre(juego, origen), "%s: el visitante aparece dentro de un obstáculo" % sala)
		var alcanzados := {origen: true}
		var pendientes: Array[Vector2] = [origen]
		while not pendientes.is_empty():
			var punto: Vector2 = pendientes.pop_back()
			for d in [Vector2(PASO, 0), Vector2(-PASO, 0), Vector2(0, PASO), Vector2(0, -PASO)]:
				var vecino: Vector2 = punto + d
				if alcanzados.has(vecino) or vecino.x < 0 or vecino.x > 1280 or vecino.y < 0 or vecino.y > 720: continue
				if _libre(juego, vecino):
					alcanzados[vecino] = true
					pendientes.append(vecino)
		for destino: Dictionary in juego.puntos:
			var cerca := false
			for punto: Vector2 in alcanzados:
				if punto.distance_to(destino.pos) <= ALCANCE - PASO:
					cerca = true
					break
			assert_true(cerca, "%s: no se puede llegar a «%s»" % [sala, destino.accion])
		await _retirar(juego)

## Puntos donde el visitante se subía a la pared en la prueba manual de Kenned (capturas del 22 de noviembre).
func test_las_paredes_y_esquinas_senaladas_en_la_prueba_manual_estan_cerradas() -> void:
	var casos := {
		"tienda": [Vector2(1176,193), Vector2(104,193)], # hueco sobre las vitrinas laterales
		"custodio": [Vector2(100,356), Vector2(1148,190), Vector2(1180,356)], # pared en perspectiva y columna de la esquina
		"dueno": [Vector2(120,220), Vector2(1160,220)], # esquinas curvas del fondo
		"coleccionista": [Vector2(120,250), Vector2(1160,250)], # columnas de las esquinas
		"recaudador": [Vector2(99,195), Vector2(1181,195)],
	}
	for sala: String in casos:
		var juego = await _casino_en(sala)
		for punto: Vector2 in casos[sala]:
			assert_false(_libre(juego, punto), "%s: el visitante cabe en %s, sobre la pared" % [sala, punto])
		await _retirar(juego)

