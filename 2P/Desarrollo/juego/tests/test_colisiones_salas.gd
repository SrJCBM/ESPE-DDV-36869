extends GutTest

const Casino := preload("res://casino/casino.tscn")

func test_muebles_bloquean_el_movimiento(sala = use_parameters(["vestibulo", "tienda", "custodio", "recaudador", "coleccionista", "dueno"])) -> void:
	var juego = Casino.instantiate()
	add_child_autofree(juego)
	juego.campana.recibir_invitacion()
	juego.campana.superadas = 4
	juego.entrar(sala)
	await get_tree().physics_frame
	await get_tree().physics_frame
	for id in PlanoSalas.MUEBLES[sala]:
		var mueble: StaticBody2D = juego.decorado.get_node(id)
		var rect: Rect2 = PlanoSalas.MUEBLES[sala][id]
		assert_true(_choca_con(juego.visitante, rect, mueble), "%s · %s permite cruzar su centro" % [sala, id])
	_comprobar_rutas(juego, PlanoSalas.LIMITES)
	await get_tree().process_frame

func test_en_la_galeria_se_puede_llegar_a_las_seis_puertas() -> void:
	var juego = Casino.instantiate()
	add_child_autofree(juego)
	juego.entrar("corredor", "vestibulo")
	await get_tree().physics_frame
	await get_tree().physics_frame
	_comprobar_rutas(juego, PlanoSalas.LIMITES_GALERIA)
	await get_tree().process_frame

func test_los_bordes_detectados_en_la_revision_manual_estan_cerrados(sala = use_parameters(["tienda", "custodio", "recaudador", "coleccionista", "dueno"])) -> void:
	var casos := {
		"tienda": [Vector2(1176, 193), Vector2(104, 193)],
		"custodio": [Vector2(100, 356), Vector2(1148, 190), Vector2(1180, 356)],
		"recaudador": [Vector2(99, 195), Vector2(1181, 195)],
		"coleccionista": [Vector2(120, 250), Vector2(1160, 250)],
		"dueno": [Vector2(120, 220), Vector2(1160, 220)],
	}
	var juego = Casino.instantiate()
	add_child_autofree(juego)
	juego.campana.recibir_invitacion()
	juego.campana.superadas = 4
	juego.entrar(sala)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var visitante: CharacterBody2D = juego.visitante
	var espacio := visitante.get_world_2d().direct_space_state
	var consulta := _consulta_pies(visitante)
	for punto: Vector2 in casos[sala]:
		var transformacion := visitante.global_transform
		transformacion.origin = visitante.get_parent().to_global(punto)
		consulta.transform = transformacion
		assert_false(espacio.intersect_shape(consulta, 1).is_empty(), "%s · el visitante entra en la pared en %s" % [sala, punto])
	await get_tree().process_frame

func _comprobar_rutas(juego, limites: Rect2) -> void:
	var visitante: CharacterBody2D = juego.visitante
	var espacio := visitante.get_world_2d().direct_space_state
	var consulta := _consulta_pies(visitante)
	var origen := Vector2i(visitante.position.snapped(Vector2(16,16)))
	var pendientes: Array[Vector2i] = [origen]
	var vistos := {origen: true}
	var accesibles := {}
	var indice := 0
	while indice < pendientes.size():
		var ubicacion := pendientes[indice]
		indice += 1
		var transformacion := visitante.global_transform
		transformacion.origin = visitante.get_parent().to_global(Vector2(ubicacion))
		consulta.transform = transformacion
		if not espacio.intersect_shape(consulta, 1).is_empty():
			continue
		var punto: Dictionary = juego.exploracion.cercano(Vector2(ubicacion))
		if not punto.is_empty():
			accesibles[punto.accion] = true
		for paso: Vector2i in [Vector2i(16,0), Vector2i(-16,0), Vector2i(0,16), Vector2i(0,-16)]:
			var vecino := ubicacion + paso
			if limites.has_point(Vector2(vecino)) and not vistos.has(vecino):
				vistos[vecino] = true
				pendientes.append(vecino)
	for punto: Dictionary in juego.exploracion.puntos:
		assert_has(accesibles, punto.accion, "%s · %s es accesible desde la entrada" % [juego.sala, punto.accion])

func _consulta_pies(visitante: CharacterBody2D) -> PhysicsShapeQueryParameters2D:
	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = visitante.get_child(0).shape
	consulta.exclude = [visitante.get_rid()]
	return consulta

func _choca_con(visitante: CharacterBody2D, rect: Rect2, mueble: StaticBody2D) -> bool:
	for rumbo: Vector2 in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var inicio: Vector2 = rect.get_center() + rumbo * (rect.size * rumbo.abs() * 0.5).length() + rumbo * 18
		if not PlanoSalas.LIMITES.grow(-11).has_point(inicio):
			continue
		var origen: Vector2 = visitante.get_parent().to_global(inicio)
		var destino: Vector2 = mueble.global_position
		var impacto := KinematicCollision2D.new()
		var transformacion := Transform2D(visitante.global_transform.x, visitante.global_transform.y, origen)
		if visitante.test_move(transformacion, destino - origen, impacto) and impacto.get_collider() == mueble:
			return true
	return false
