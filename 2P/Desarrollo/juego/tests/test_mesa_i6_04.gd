extends GutTest
## I6-04: la mesa se organiza por lo que se puede decidir. En la espera, tapete, objetivo e
## Iniciar mano; durante la mano, cartas, lectura y los cinco patrones en su propia fila (siempre
## visibles desde la revisión de pantallas del 26 nov 2026), y el coste se lee como una ficha.

func after_each() -> void:
	await get_tree().process_frame

func _mesa(jefe := "custodio"):
	var juego = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	juego._entregar()
	juego._cerrar()
	juego.campana.superadas = CampanaCasino.MESAS.find(jefe)
	juego.entrar(jefe)
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	juego.mesa.establecer_movimiento_reducido(true)
	juego.mesa.comentarios = false
	return juego

func _cartas(juego, datos: Array) -> void:
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.mazo.clear()
	for d in datos:
		m.partida.mazo.append(FabricaCartas.crear_carta(d[0], d[1]))

func _tecla(mesa, codigo: Key) -> void:
	var evento := InputEventKey.new()
	evento.keycode = codigo
	evento.pressed = true
	mesa._unhandled_input(evento)

func test_en_la_espera_el_tapete_muestra_el_objetivo_y_no_hay_lectura_ni_patrones() -> void:
	var mesa = _mesa().mesa
	assert_true(mesa.tapete.visible)
	assert_true(mesa.mano.objetivo.is_visible_in_tree(), "El objetivo de la mesa va dentro del tapete")
	assert_string_contains(mesa.mano.objetivo.text, "Meta 200")
	assert_string_contains(mesa.mano.objetivo.text, "umbral 17")
	assert_false(mesa.mano.objetivo.text.contains("campanadas"), "Las campanadas ya se leen en el dial")
	assert_false(mesa._lectura.visible)
	assert_false(mesa.boton_patrones.visible, "Sin cartas no hay patrones que consultar")
	assert_false(mesa.franja_patrones.visible)
	assert_eq(mesa.get_viewport().gui_get_focus_owner(), mesa.boton_iniciar_pedir, "La primera acción tiene el foco")

func test_durante_la_mano_los_patrones_se_ven_sin_tapar_la_lectura() -> void:
	var juego = _mesa()
	var mesa = juego.mesa
	_cartas(juego, [["llaves", 4], ["velas", 6]])
	mesa.boton_iniciar_pedir.pressed.emit()
	assert_true(mesa.franja_patrones.visible, "Los patrones están siempre a la vista")
	assert_true(mesa._lectura.visible, "y la lectura también")
	assert_false(mesa.boton_patrones.visible, "No hay botón para abrirlos")
	for control in [mesa._lectura, mesa._lectura_titulo, mesa._explicacion, mesa._mensaje]:
		assert_false(mesa.franja_patrones.get_global_rect().intersects(control.get_global_rect()), "%s no se cruza con la franja" % control.name)
	_tecla(mesa, KEY_T)
	var foco: Control = mesa.get_viewport().gui_get_focus_owner()
	assert_eq(foco.get_parent(), mesa.franja_patrones, "T lleva el foco al primer patrón")
	assert_false(mesa._mensaje.text.is_empty(), "El patrón enfocado se explica en la línea de detalle")
	_tecla(mesa, KEY_ESCAPE)
	assert_true(mesa.franja_patrones.visible, "Esc no los esconde")
	assert_ne(mesa.get_viewport().gui_get_focus_owner().get_parent(), mesa.franja_patrones, "solo devuelve el foco a la acción")

func test_tras_la_ayuda_los_patrones_siguen_a_la_vista() -> void:
	var juego = _mesa()
	var mesa = juego.mesa
	_cartas(juego, [["llaves", 4], ["velas", 6]])
	mesa.boton_iniciar_pedir.pressed.emit()
	mesa.abrir_patrones()
	mesa.mostrar_ayuda()
	mesa.cerrar_modal()
	assert_true(mesa.franja_patrones.visible)

func test_esc_cancela_la_llave_aunque_se_haya_consultado_patrones() -> void:
	var juego = _mesa()
	var mesa = juego.mesa
	_cartas(juego, [["llaves", 4], ["velas", 6], ["relojes", 2]])
	mesa.boton_iniciar_pedir.pressed.emit()
	_tecla(mesa, KEY_T)
	_tecla(mesa, KEY_L)
	assert_true(mesa.eleccion_llave.visible)
	assert_true(mesa.franja_patrones.visible, "La franja no salta al elegir una Llave")
	_tecla(mesa, KEY_T)
	assert_ne(mesa.get_viewport().gui_get_focus_owner().get_parent(), mesa.franja_patrones, "T espera a que termine la elección")
	_tecla(mesa, KEY_ESCAPE)
	assert_false(mesa.eleccion_llave.visible)
	assert_true(mesa.vista.acciones.devolver, "No se gastó la devolución")

func test_el_progreso_de_los_patrones_no_se_repite_sobre_el_tapete() -> void:
	var juego = _mesa()
	var mesa = juego.mesa
	_cartas(juego, [["velas", 9], ["relojes", 9]])
	mesa.boton_iniciar_pedir.pressed.emit()
	assert_eq(mesa._cercano.text, "", "La franja ya muestra el progreso de cada patrón")
	var textos: Array = mesa.franja_patrones.get_children().filter(func(b): return b.visible).map(func(b): return b.text)
	assert_true(textos.any(func(t): return t.begins_with("Punto exacto")), "Punto exacto se lee en la franja")

func test_mano_larga_a_una_carta_se_lee_en_la_franja() -> void:
	var juego = _mesa()
	var mesa = juego.mesa
	_cartas(juego, [["llaves", 2], ["velas", 3], ["relojes", 2], ["velas", 1], ["llaves", 1]])
	mesa.boton_iniciar_pedir.pressed.emit()
	mesa.boton_iniciar_pedir.pressed.emit()
	mesa.boton_iniciar_pedir.pressed.emit()
	var larga: Array = mesa.franja_patrones.get_children().filter(func(b): return b.visible and b.text.begins_with("Mano larga"))
	assert_string_contains(larga[0].text, "4/5")

func test_una_mascara_oculta_no_se_anuncia_como_activa() -> void:
	var juego = _mesa()
	var mesa = juego.mesa
	_cartas(juego, [["velas", 9], ["mascaras", 8]])
	mesa.boton_iniciar_pedir.pressed.emit()
	assert_false(mesa._cercano.text.contains("activo"), "No se puede prometer un patrón que depende de una Máscara oculta")

func test_el_coste_se_lee_como_una_ficha_con_icono() -> void:
	var juego = _mesa()
	var mesa = juego.mesa
	var ficha: Control = mesa.boton_iniciar_pedir.get_node("Ficha")
	assert_true(ficha.visible)
	assert_eq(ficha.get_node("Cantidad").text, "−1")
	assert_eq(ficha.get_node("Icono").texture.resource_path, preload("res://mesa/piezas_mesa.gd").ICONO_CAMPANADA)
	assert_string_contains(mesa.boton_iniciar_pedir.tooltip_text, "−1 campanada", "El nombre accesible conserva el coste completo")
	_cartas(juego, [["llaves", 4], ["velas", 6]])
	mesa.boton_iniciar_pedir.pressed.emit()
	assert_false(ficha.visible, "Pedir no cuesta nada en el Custodio")
	assert_false(mesa.boton_plantarse.get_node("Ficha").visible)

func test_en_el_recaudador_pedir_muestra_la_ficha_y_el_saldo_sigue_a_la_vista() -> void:
	var juego = _mesa("recaudador")
	var mesa = juego.mesa
	_cartas(juego, [["velas", 9], ["relojes", 5], ["llaves", 3]])
	mesa.boton_iniciar_pedir.pressed.emit()
	var ficha: Control = mesa.boton_iniciar_pedir.get_node("Ficha")
	assert_true(ficha.visible)
	assert_eq(ficha.get_node("Icono").texture.resource_path, preload("res://mesa/piezas_mesa.gd").ICONO_FICHA)
	assert_true(mesa.hud.saldo.is_visible_in_tree(), "El saldo del Recaudador queda en la cabecera")
	assert_string_contains(mesa._regla_texto.text, "Saldo")

func test_cinco_cartas_se_ven_enteras_y_la_sexta_desplaza_sin_encoger() -> void:
	var mesa = _mesa().mesa
	var medida_cinco: Vector2 = mesa.mano.medida_carta(5)
	assert_gt(mesa.mano.medida_carta(2).x, medida_cinco.x, "Con pocas cartas, más grandes")
	assert_eq(mesa.mano.medida_carta(8), medida_cinco)
	assert_gte(medida_cinco.x * 1024.0 / 1440.0, 85.0, "A 1024 × 576, cada carta conserva 85 px de ancho o más")

func test_al_resolver_se_lee_el_resultado_con_sus_patrones() -> void:
	var juego = _mesa()
	var mesa = juego.mesa
	_cartas(juego, [["velas", 9], ["relojes", 9]])
	mesa.boton_iniciar_pedir.pressed.emit()
	mesa.boton_plantarse.pressed.emit()
	await get_tree().process_frame
	assert_true(mesa.boton_desglose.visible)
	assert_string_contains(mesa._lectura.text, "puntos")
	assert_string_contains(mesa._explicacion.text, "Exacto +3", "Los patrones obtenidos, en el desglose breve")
	assert_eq(mesa._cercano.text, "", "Fuera de la decisión no hay patrón cercano")
