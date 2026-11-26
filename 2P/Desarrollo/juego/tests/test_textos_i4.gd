extends GutTest
## I4-03: durante la exploración solo hay un objetivo y una pista cuando hay algo cerca.

func after_each() -> void:
	await get_tree().process_frame

func _casino():
	var juego = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	return juego

func _textos(nodo: Node) -> PackedStringArray:
	var textos := PackedStringArray()
	for etiqueta in nodo.find_children("*", "Label", true, false):
		if etiqueta.is_visible_in_tree(): textos.append(etiqueta.text)
	return textos

func test_sin_interaccion_cerca_no_hay_pista_ni_tira_de_teclas() -> void:
	var juego = _casino()
	juego.visitante.position = Vector2(400, 450)
	juego._process(0.0)
	assert_eq(juego.pista.text, "", "El objetivo ya dice adónde ir")
	for texto in _textos(juego.pagina):
		assert_false(texto.contains("WASD"), "La tira fija de teclas se retira")

func test_cerca_de_algo_aparece_una_sola_accion_breve() -> void:
	var juego = _casino()
	juego.entrar("vestibulo")
	juego.visitante.position = Vector2(985, 300)
	juego._process(0.0)
	assert_eq(juego.pista.text, "E · Hablar")
	juego._entregar()
	juego._cerrar()
	juego.campana.superadas = 1
	juego.entrar("tienda")
	juego.visitante.position = Vector2(645, 310)
	juego._process(0.0)
	assert_eq(juego.pista.text, "E · Abrir vitrina")

func test_las_puertas_solo_muestran_el_control_al_acercarse() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.entrar("pasillo_custodio", "vestibulo")
	juego.visitante.position = PlanoGaleria.punto("pasillo_custodio", "pasillo_recaudador") + Vector2(-20, 0)
	juego._process(0.0)
	assert_eq(juego.pista.text, "E · Examinar la puerta")
	juego.visitante.position = PlanoGaleria.punto("pasillo_custodio", "custodio") + Vector2(0, 20)
	juego._process(0.0)
	assert_eq(juego.pista.text, "E · Entrar")

func test_la_presentacion_del_crupier_muestra_tres_cifras_y_tomar_asiento() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._presentar_jefe()
	assert_true(juego.dialogo.visible, "I5-10: el crupier habla en la escena de novela visual")
	var cifras: Node = juego.dialogo.get_node("CifrasMesa")
	assert_not_null(cifras)
	var regla := CampanaCasino.MESAS_CAMPANA.de("custodio")
	var valores := PackedStringArray()
	for bloque in cifras.get_children(): valores.append(bloque.get_child(0).text)
	assert_eq(valores, PackedStringArray([str(regla.umbral), str(regla.meta), str(regla.campanadas)]))
	for i in range(6):
		if not juego.dialogo.botones.is_empty(): break
		juego.dialogo.completar()
		if juego.dialogo.botones.is_empty(): juego.dialogo.avanzar()
	assert_eq(juego.dialogo.botones[0].text, "Tomar asiento")
	assert_false(juego.dialogo.texto.text.contains("{"), "Las marcas del guion se sustituyen")
	juego.dialogo.elegir(0)
	assert_not_null(juego.mesa, "Tomar asiento abre la mesa")
	assert_true(juego.visitante.bloqueado, "El visitante no se mueve con la mesa abierta")
