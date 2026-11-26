extends GutTest
## I6-09: las figuras del recorrido se apoyan por la base de su parte visible, guardan escala
## con Klein, llevan sombra de contacto cuando nada la tapa y su huella de colisión está bajo sus
## pies. El piano y el banco quedan contra un muro y el vano del este, dentro de su nicho.

const Sala := preload("res://casino/exploracion/sala_explorable.gd")
const Visitante := preload("res://casino/exploracion/visitante.gd")
const Puerta := preload("res://casino/exploracion/puerta_vestibulo.gd")
## Figura → mueble de PlanoSalas que hace de huella.
const HUELLAS := {"amparo": "piano", "jugador_porcelana": "mesa_jugadores", "tobias": "tobias", "benavides": "banco_benavides"}

func after_each() -> void:
	await get_tree().process_frame

func _juego():
	var juego = load("res://casino/casino.tscn").instantiate()
	add_child_autofree(juego)
	juego._entregar()
	juego._cerrar()
	juego.campana.superadas = 3
	return juego

func _salas() -> Array:
	return ["vestibulo", "pasillo_custodio", "pasillo_recaudador", "tienda", "custodio", "recaudador", "coleccionista", "dueno"]

func test_cada_figura_se_apoya_en_sus_pies_con_el_alto_pedido() -> void:
	var juego = _juego()
	for sala in _salas():
		juego.entrar(sala)
		for datos in Sala.figuras(sala):
			var figura: Sprite2D = juego.decorado.find_child("Figura_%s" % datos.id, true, false)
			assert_not_null(figura, "%s · %s" % [sala, datos.id])
			var visible_rect: Rect2 = figura.get_meta("visible")
			var base: float = figura.position.y + (figura.offset.y + figura.texture.get_height() * 0.5 - (figura.texture.get_height() - visible_rect.end.y)) * figura.scale.y
			assert_almost_eq(base, datos.pies.y, 0.5, "%s · %s: la base visible toca el suelo en sus pies" % [sala, datos.id])
			assert_almost_eq(visible_rect.size.y * figura.scale.y, datos.alto, 0.5, "%s · %s: el alto es el de la parte visible" % [sala, datos.id])

func test_el_margen_transparente_no_hace_flotar_a_los_jugadores() -> void:
	var juego = _juego()
	juego.entrar("vestibulo")
	var jugadores: Sprite2D = juego.decorado.find_child("Figura_jugador_porcelana", true, false)
	var visible_rect: Rect2 = jugadores.get_meta("visible")
	assert_lt(visible_rect.end.y, float(jugadores.texture.get_height()), "La imagen tiene margen transparente bajo la mesa")
	assert_gt(jugadores.offset.y, -jugadores.texture.get_height() * 0.5, "y el apoyo lo compensa")

func test_la_escala_guarda_proporcion_con_klein() -> void:
	for sala in Sala.FIGURAS:
		for datos in Sala.FIGURAS[sala]:
			assert_between(datos.alto / Visitante.ALTO, 0.78, 1.2, "%s junto a Klein" % datos.id)

func test_sombra_de_contacto_solo_donde_nada_la_tapa() -> void:
	var juego = _juego()
	for sala in _salas():
		juego.entrar(sala)
		for datos in Sala.figuras(sala):
			var sombra = juego.decorado.find_child("Sombra_%s" % datos.id, true, false)
			if datos.sombra > 0.0:
				assert_not_null(sombra, "%s lleva sombra" % datos.id)
				assert_eq(sombra.get_index() + 1, juego.decorado.find_child("Figura_%s" % datos.id, true, false).get_index(), "La sombra queda detrás de la figura")
			else:
				assert_null(sombra, "%s: la tapa un mueble" % datos.id)

func test_la_huella_de_cada_figura_esta_bajo_sus_pies() -> void:
	for sala in Sala.FIGURAS:
		for datos in Sala.FIGURAS[sala]:
			if not HUELLAS.has(datos.id):
				continue
			var huella: Rect2 = PlanoSalas.MUEBLES[sala][HUELLAS[datos.id]]
			assert_true(huella.position.x <= datos.pies.x and datos.pies.x <= huella.end.x, "%s: centrada bajo la figura" % datos.id)
			assert_almost_eq(huella.end.y, datos.pies.y, 2.0, "%s: el borde delantero de la huella coincide con los pies" % datos.id)

func test_el_piano_y_el_banco_quedan_contra_un_muro() -> void:
	var piano: Rect2 = PlanoSalas.MUEBLES.vestibulo.piano
	var muro: Rect2 = PlanoSalas.MUEBLES.vestibulo.pared_norte_oeste
	assert_lte(piano.position.y - muro.end.y, 2.0, "El piano toca el muro norte")
	var banco: Rect2 = PlanoSalas.MUEBLES.pasillo_recaudador.banco_benavides
	assert_lte(banco.position.y - PlanoSalas.LIMITES_GALERIA.position.y, 4.0, "El banco toca el muro del pasillo")
	var jugadores: Rect2 = PlanoSalas.MUEBLES.vestibulo.mesa_jugadores
	assert_lt(jugadores.get_center().x, 300.0, "La mesa de jugadores, en el lateral oeste")

func test_el_vano_del_este_queda_dentro_de_su_nicho() -> void:
	var nicho := Rect2(1232, 304, 32, 98)
	assert_true(nicho.encloses(Puerta.VANO), "El vano no sobresale de las molduras del arte")

func test_klein_puede_rodear_las_figuras_y_llegar_a_las_puertas() -> void:
	var juego = _juego()
	juego.entrar("pasillo_recaudador", "pasillo_custodio")
	juego.visitante.position = Vector2(960, 380)
	for i in range(20):
		juego.visitante.move_and_collide(Vector2(0, -4))
	assert_gt(juego.visitante.position.y, PlanoSalas.MUEBLES.pasillo_recaudador.banco_benavides.end.y, "El banco detiene a Klein delante, no encima")
	juego.entrar("vestibulo", "entrada")
	juego.visitante.position = Vector2(640, 550)
	var hasta := Vector2(1150, 356)
	for i in range(160):
		var paso: Vector2 = (hasta - juego.visitante.position).limit_length(5.0)
		if paso.length() < 0.5:
			break
		juego.visitante.move_and_collide(paso)
	assert_lt(juego.visitante.position.distance_to(hasta), 12.0, "La puerta del este sigue al alcance")
