extends GutTest
## Tamaño de los personajes y orden de dibujo por la altura de los pies.

const Visitante := preload("res://casino/exploracion/visitante.gd")

func _casino():
	var juego = load("res://casino/casino.tscn").instantiate()
	add_child_autofree(juego)
	return juego

func _figuras(juego) -> Array:
	var lista: Array = []
	for nodo in juego.decorado.get_children():
		if nodo is Sprite2D and str(nodo.texture.resource_path).contains("figura_"): lista.append(nodo)
	return lista

func test_visitante_y_personajes_tienen_altura_legible() -> void:
	assert_gte(Visitante.ALTO, 100.0)
	var juego = _casino()
	juego.entrar("vestibulo")
	var anfitriona: Sprite2D = _figuras(juego)[0]
	assert_almost_eq(anfitriona.texture.get_height() * anfitriona.scale.y, 84.0, 0.5)
	juego.campana.recibir_invitacion()
	juego.entrar("custodio")
	var custodio: Sprite2D = _figuras(juego)[0]
	assert_almost_eq(custodio.texture.get_height() * custodio.scale.y, 95.0, 0.5)
	await get_tree().process_frame
	await get_tree().process_frame

func test_las_figuras_se_ordenan_por_los_pies() -> void:
	var juego = _casino()
	assert_true(juego.mundo.y_sort_enabled)
	assert_true(juego.decorado.y_sort_enabled)
	juego.entrar("vestibulo")
	var anfitriona: Sprite2D = _figuras(juego)[0]
	assert_eq(anfitriona.position, Vector2(990, 231), "El origen de la figura está en sus pies.")
	assert_almost_eq(anfitriona.offset.y, -anfitriona.texture.get_height() * 0.5, 0.01)
	for punto in juego.exploracion.puntos: assert_eq(punto.marca.get_parent(), juego.capa_superior)
	await get_tree().process_frame
	await get_tree().process_frame

func test_rombos_y_placas_quedan_sobre_el_mundo_y_bajo_los_dialogos() -> void:
	var juego = _casino()
	var indice: int = juego.capa_superior.get_index()
	assert_gt(indice, juego.mundo.get_index())
	assert_lt(indice, juego.velo.get_index())
	assert_lt(indice, juego.libro.get_index())
	assert_eq(juego.capa_superior.z_index, 0)

func test_las_placas_de_la_galeria_quedan_sobre_el_visitante() -> void:
	var juego = _casino()
	juego.campana.recibir_invitacion()
	juego.entrar("pasillo_custodio", "vestibulo")
	var placas: Node2D = juego.capa_superior.get_node("Placas")
	assert_eq(placas.z_index, 0, "Sin z_index: un valor alto las pondría sobre los diálogos.")
	juego.entrar("vestibulo")
	await get_tree().process_frame
	assert_null(juego.capa_superior.get_node_or_null("Placas"), "Al salir de la galería se retiran.")
	await get_tree().process_frame
	await get_tree().process_frame

func test_no_se_puede_pasar_entre_el_jefe_y_su_silla() -> void:
	var juego = _casino()
	juego.campana.recibir_invitacion()
	juego.entrar("custodio")
	await get_tree().physics_frame
	juego.visitante.position = Vector2(540,250)
	Input.action_press("este")
	for i in range(40): await get_tree().physics_frame
	Input.action_release("este")
	assert_lt(juego.visitante.position.x, 595.0, "La silla del jefe (x ≥ 600) bloquea el paso.")
	assert_gt(juego.visitante.position.x, 545.0, "El visitante sí avanzó hasta la silla.")
	await get_tree().process_frame
	await get_tree().process_frame

func test_se_puede_rodear_al_jefe_por_detras() -> void:
	var juego = _casino()
	juego.campana.recibir_invitacion()
	juego.entrar("custodio")
	await get_tree().physics_frame
	juego.visitante.position = Vector2(560,220)
	Input.action_press("este")
	for i in range(60): await get_tree().physics_frame
	Input.action_release("este")
	assert_gt(juego.visitante.position.x, 690.0, "Detrás de la silla queda paso libre.")
	await get_tree().process_frame
	await get_tree().process_frame
