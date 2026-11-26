extends GutTest

const Casino := preload("res://casino/casino.tscn")

func test_muebles_bloquean_el_movimiento(sala = use_parameters(["entrada", "vestibulo", "tienda", "custodio", "recaudador", "coleccionista", "dueno"])) -> void:
	var juego = Casino.instantiate()
	add_child_autofree(juego)
	juego.campana.recibir_invitacion()
	juego.campana.superadas = 4
	juego.entrar(sala)
	await get_tree().physics_frame
	await get_tree().physics_frame
	for id in PlanoSalas.MUEBLES.get(sala, {}):
		var mueble: StaticBody2D = juego.decorado.get_node(id)
		var rect: Rect2 = PlanoSalas.MUEBLES[sala][id]
		assert_true(_choca_con(juego.visitante, rect, mueble), "%s · %s no bloquea los accesos probados" % [sala, id])
	_comprobar_rutas(juego, PlanoSalas.limites(sala))
	await get_tree().process_frame

func test_en_cada_pasillo_se_puede_llegar_a_todas_sus_puertas(pasillo = use_parameters(PlanoGaleria.ORDEN)) -> void:
	var juego = Casino.instantiate()
	add_child_autofree(juego)
	juego.campana.recibir_invitacion()
	juego.campana.superadas = 3
	juego.entrar(pasillo)
	assert_eq(juego.sala, pasillo)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_comprobar_rutas(juego, PlanoSalas.LIMITES_GALERIA)
	await get_tree().process_frame

func _comprobar_rutas(juego, limites: Rect2) -> void:
	var visitante: CharacterBody2D = juego.visitante
	var espacio := visitante.get_world_2d().direct_space_state
	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = visitante.get_child(0).shape
	consulta.exclude = [visitante.get_rid()]
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
		for punto: Dictionary in juego.exploracion.puntos:
			if Vector2(ubicacion).distance_to(punto.pos) <= 86:
				accesibles[punto.accion] = true
		for paso: Vector2i in [Vector2i(16,0), Vector2i(-16,0), Vector2i(0,16), Vector2i(0,-16)]:
			var vecino := ubicacion + paso
			if limites.has_point(Vector2(vecino)) and not vistos.has(vecino):
				vistos[vecino] = true
				pendientes.append(vecino)
	for punto: Dictionary in juego.exploracion.puntos:
		assert_has(accesibles, punto.accion, "%s · %s es accesible desde la entrada" % [juego.sala, punto.accion])

func _choca_con(visitante: CharacterBody2D, rect: Rect2, mueble: StaticBody2D) -> bool:
	for rumbo: Vector2 in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var tangente := rumbo.orthogonal()
		# Un mueble cercano puede bloquear el camino al centro de la pared. Probar también
		# a ambos lados comprueba la pared desde un tramo que sí se puede alcanzar.
		for fraccion: float in [0.0, -0.3, 0.3]:
			var interior := rect.get_center() + (rect.size * tangente) * fraccion
			var inicio := interior + rumbo * ((rect.size * rumbo.abs() * 0.5).length() + 18.0)
			if not PlanoSalas.LIMITES.grow(-11).has_point(inicio):
				continue
			var origen: Vector2 = visitante.get_parent().to_global(inicio)
			var destino: Vector2 = visitante.get_parent().to_global(interior)
			var impacto := KinematicCollision2D.new()
			var transformacion := Transform2D(visitante.global_transform.x, visitante.global_transform.y, origen)
			if visitante.test_move(transformacion, destino - origen, impacto) and impacto.get_collider() == mueble:
				return true
	return false
