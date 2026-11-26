extends GutTest
## I6-08: el texto y las acciones no se cruzan en recompensa, inventario, derrota, botones de
## mesa ni en la toma de Ignacio del prólogo.

func after_each() -> void:
	await get_tree().process_frame

func _casino():
	var juego = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	return juego

func _cartas(juego, datos: Array) -> void:
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.mazo.clear()
	for d in datos:
		m.partida.mazo.append(FabricaCartas.crear_carta(d[0], d[1]))

## Fin del párrafo y comienzo de la lista, y que el panel siga dentro del lienzo.
func _sin_cruces(juego, que: String) -> void:
	await get_tree().process_frame
	var libro = juego.libro
	var fin_cuerpo: float = libro.cuerpo.position.y + libro.cuerpo.size.y
	var lista: Control = libro.lista.get_parent()
	assert_true(fin_cuerpo <= lista.position.y, "%s: el párrafo (hasta %s) termina antes de la lista (%s)" % [que, fin_cuerpo, lista.position.y])
	var fuente: Font = libro.cuerpo.get_theme_font("font")
	var alto := fuente.get_multiline_string_size(libro.cuerpo.text, HORIZONTAL_ALIGNMENT_LEFT, libro.cuerpo.size.x, libro.cuerpo.get_theme_font_size("font_size")).y
	assert_true(alto <= libro.cuerpo.size.y + 1.0, "%s: el párrafo cabe entero en su espacio" % que)
	assert_true(libro.position.y >= 0 and libro.position.y + libro.size.y <= 810, "%s: el panel no sale del lienzo" % que)
	var fin_lista: float = lista.position.y + libro.lista.get_combined_minimum_size().y
	assert_true(fin_lista <= libro.size.y, "%s: la lista cabe en el panel o se desplaza" % que)

func _vencer_al_custodio(juego) -> void:
	juego._entregar()
	juego._cerrar()
	juego.entrar("custodio")
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.meta = 1
	_cartas(juego, [["llaves", 2], ["velas", 3]])
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	juego.mesa.boton_plantarse.pressed.emit()
	juego.mesa.boton_iniciar_pedir.pressed.emit()

func test_la_recompensa_deja_leer_la_frase_completa_del_custodio() -> void:
	var juego = _casino()
	_vencer_al_custodio(juego)
	assert_string_contains(juego.libro.cuerpo.text, "Él no olvida")
	await _sin_cruces(juego, "Recompensa")

func test_la_recompensa_se_elige_u_omite_una_sola_vez() -> void:
	var juego = _casino()
	_vencer_al_custodio(juego)
	var antes: int = juego.campana.baraja.size()
	var fila = juego.libro.lista.get_children().filter(func(n): return n.has_signal("elegida"))[0]
	fila.get_child(0).pressed.emit()
	assert_eq(juego.campana.baraja.size(), antes + 1, "La carta elegida entra en la baraja")
	assert_false(juego.campana.hay_recompensa())
	assert_false(juego.campana.resolver_recompensa(1), "Una segunda elección no se aplica")
	assert_eq(juego.campana.baraja.size(), antes + 1)

func test_omitir_la_recompensa_no_agrega_cartas() -> void:
	var juego = _casino()
	_vencer_al_custodio(juego)
	var antes: int = juego.campana.baraja.size()
	juego.libro.lista.get_children().filter(func(n): return n is Button).back().pressed.emit()
	assert_eq(juego.campana.baraja.size(), antes)
	assert_false(juego.campana.hay_recompensa())

func test_el_inventario_con_un_sello_no_tapa_ver_baraja() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.campana.superadas = 1
	juego.entrar("pasillo_custodio")
	juego.inventario()
	assert_string_contains(juego.libro.cuerpo.text, "Sello del Custodio")
	await _sin_cruces(juego, "Inventario")

func test_la_derrota_ofrece_nuevo_intento_sin_tapar_el_parrafo() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.campana.superadas = 1
	juego.entrar("recaudador")
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	juego._levantarse(false, 0)
	assert_eq(juego.libro.primero.text, "Nuevo intento", "El juego vuelve a la entrada: la acción lo dice")
	assert_string_contains(juego.libro.cuerpo.text, "Archivado")
	await _sin_cruces(juego, "Derrota")
	juego.libro.primero.pressed.emit()
	assert_eq(juego.sala, "entrada")

func test_el_coste_de_la_mesa_no_pisa_el_nombre_de_la_accion() -> void:
	var juego = _casino()
	juego._entregar()
	juego._cerrar()
	juego.campana.superadas = 1
	juego.entrar("recaudador")
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	await get_tree().process_frame
	var boton: Button = juego.mesa.boton_iniciar_pedir
	_comprobar_boton(boton, "INICIAR MANO", "−1 campanada")
	_cartas(juego, [["llaves", 2], ["relojes", 3], ["velas", 2]])
	boton.pressed.emit()
	await get_tree().process_frame
	_comprobar_boton(boton, "PEDIR", "−1 ficha")

func _comprobar_boton(boton: Button, titulo: String, coste: String) -> void:
	var nombre: Label = boton.get_node("Etiqueta")
	var detalle: Label = boton.get_node("Coste")
	var ficha: Control = boton.get_node("Ficha")
	assert_eq(nombre.text, titulo)
	assert_eq(detalle.text, coste, "El coste completo queda como texto accesible")
	# I6-04: el coste se lee como una ficha con icono y cantidad, en su propio espacio.
	assert_true(ficha.visible, "%s muestra su ficha de coste" % coste)
	assert_eq(ficha.get_node("Cantidad").text, coste.get_slice(" ", 0))
	var ancho_nombre := nombre.get_theme_font("font").get_string_size(nombre.text, HORIZONTAL_ALIGNMENT_LEFT, -1, nombre.get_theme_font_size("font_size")).x
	assert_true(ancho_nombre <= nombre.size.x, "%s cabe en su línea (%s de %s)" % [titulo, ancho_nombre, nombre.size.x])
	var caja_nombre := Rect2(nombre.position, Vector2(ancho_nombre, nombre.size.y))
	assert_false(caja_nombre.intersects(ficha.get_rect()), "%s y su ficha no se cruzan" % titulo)
	assert_true(Rect2(Vector2.ZERO, boton.size).encloses(ficha.get_rect()), "La ficha queda dentro del botón")

func test_en_la_toma_de_ignacio_no_hay_cara_recortada() -> void:
	var juego = _casino()
	juego.iniciar_prologo()
	var h = juego.historia
	h.reducido = true
	for i in range(60):
		if h.actual == "p0a_2": break
		h.completar()
		h.avanzar()
	assert_eq(h.nombre.text, "Ignacio Ferrer")
	assert_true(h.presentes.has("ignacio"), "Ignacio está en escena de cuerpo entero")
	assert_false(h.cara.visible, "Su figura y su nombre lo identifican: sin cara pequeña")
	assert_false(h.retrato.visible and h.retrato.texture != null, "Tampoco el retrato grande")

func test_la_cara_pequena_no_cruza_la_barra() -> void:
	var juego = _casino()
	var h = juego.dialogo
	assert_true(h.cara.position.y + h.cara.size.y <= h.barra.position.y - 8, "La cara termina antes de Historial, Auto y Saltar")

func _tecla(juego, codigo: Key) -> void:
	var tecla := InputEventKey.new()
	tecla.keycode = codigo
	tecla.physical_keycode = codigo
	tecla.pressed = true
	juego.get_viewport().push_input(tecla)
	var suelta := tecla.duplicate()
	suelta.pressed = false
	juego.get_viewport().push_input(suelta)

func test_la_recompensa_se_elige_con_el_teclado() -> void:
	var juego = _casino()
	_vencer_al_custodio(juego)
	await get_tree().process_frame
	var antes: int = juego.campana.baraja.size()
	var fila = juego.libro.lista.get_children().filter(func(n): return n.has_signal("elegida"))[0]
	assert_true(fila.get_child(0).focus_mode != Control.FOCUS_NONE, "Las cartas se alcanzan con el teclado")
	fila.get_child(1).grab_focus()
	_tecla(juego, KEY_ENTER)
	await get_tree().process_frame
	assert_eq(juego.campana.baraja.size(), antes + 1, "Enter sobre la carta enfocada la elige")
	assert_false(juego.campana.hay_recompensa())
	assert_false(juego.libro.visible, "El panel se cierra tras elegir")
