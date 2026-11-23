extends GutTest
## I4-05: tapete del Custodio, acciones a la derecha, patrones fuera del tapete y dial con aro.

const Mesa := preload("res://mesa/mesa.tscn")
const DialCampanadas := preload("res://mesa/interfaz/dial_campanadas.gd")

func after_each() -> void:
	await get_tree().process_frame

func _mesa(sala := "", reducido := true):
	var mesa = Mesa.instantiate()
	if not sala.is_empty():
		var campana := CampanaCasino.new()
		campana.recibir_invitacion()
		campana.superadas = CampanaCasino.MESAS.find(sala)
		assert_true(campana.iniciar(sala))
		mesa.campana = campana
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	mesa.establecer_movimiento_reducido(reducido)
	return mesa

func test_el_custodio_usa_el_tapete_ilustrado_y_las_demas_mesas_no() -> void:
	assert_not_null(_mesa().tapete, "Mesa suelta del Custodio")
	assert_not_null(_mesa("custodio").tapete)
	assert_null(_mesa("recaudador").tapete)

func test_acciones_apiladas_bajo_el_boleto_con_el_mismo_ancho() -> void:
	var mesa = _mesa()
	await get_tree().process_frame
	var pedir: Rect2 = mesa.boton_iniciar_pedir.get_rect()
	var plantar: Rect2 = mesa.boton_plantarse.get_rect()
	assert_eq(pedir.size, Vector2(230, 64))
	assert_eq(plantar.size.x, pedir.size.x)
	assert_gte(pedir.position.y, mesa.boleto.get_rect().end.y, "Debajo del boleto")
	assert_gt(plantar.position.y, pedir.end.y - 1, "Pedir arriba, Plantarse debajo")
	assert_gte(pedir.position.x, mesa.tapete.get_rect().end.x, "Fuera de la columna central")

func test_los_patrones_quedan_fuera_del_tapete() -> void:
	var mesa = _mesa()
	mesa.controlador.procesar_comando(IniciarMano.new())
	await get_tree().process_frame
	assert_true(mesa.franja_patrones.visible)
	assert_gte(mesa.franja_patrones.get_rect().position.y, mesa.tapete.get_rect().end.y)

func test_los_botones_solo_muestran_la_accion_y_un_coste_real() -> void:
	var mesa = _mesa()
	assert_eq(mesa.boton_iniciar_pedir.get_node("Etiqueta").text, "INICIAR MANO")
	assert_eq(mesa.boton_iniciar_pedir.get_node("Coste").text, "−1 campanada")
	mesa.controlador.procesar_comando(IniciarMano.new())
	assert_eq(mesa.boton_iniciar_pedir.get_node("Etiqueta").text, "PEDIR")
	assert_eq(mesa.boton_iniciar_pedir.get_node("Coste").text, "", "Pedir no cuesta campanadas")
	assert_eq(mesa.boton_plantarse.get_node("Coste").text, "")
	var recaudador = _mesa("recaudador")
	recaudador.controlador.procesar_comando(IniciarMano.new())
	assert_eq(recaudador.boton_iniciar_pedir.get_node("Coste").text, "−1 ficha")

func test_iniciar_una_mano_gira_el_aro_y_pedir_o_reiniciar_lo_dejan_quieto() -> void:
	var mesa = _mesa("", false)
	var aro: TextureRect = mesa.dial.aro
	var inicial := aro.rotation
	mesa.controlador.procesar_comando(IniciarMano.new())
	assert_true(mesa.dial.giro != null and mesa.dial.giro.is_valid(), "El gasto dispara el giro")
	assert_eq(mesa._contador.text, "9", "La cifra cambia de inmediato a su valor real")
	await get_tree().create_timer(0.4).timeout
	assert_almost_eq(aro.rotation, inicial + DialCampanadas.PASO, 0.001)
	var tras_inicio := aro.rotation
	mesa.controlador.procesar_comando(PedirCarta.new())
	await get_tree().process_frame
	assert_eq(aro.rotation, tras_inicio, "Pedir no gasta campanadas")
	mesa.controlador.reiniciar()
	await get_tree().process_frame
	assert_eq(aro.rotation, tras_inicio, "Reiniciar no gira el aro")
	assert_eq(mesa._contador.text, "10")

func test_abrir_un_menu_a_mitad_del_giro_lo_deja_en_su_posicion_final() -> void:
	var mesa = _mesa("", false)
	var inicial: float = mesa.dial.aro.rotation
	mesa.controlador.procesar_comando(IniciarMano.new())
	mesa.mostrar_ayuda()
	assert_almost_eq(mesa.dial.aro.rotation, inicial + DialCampanadas.PASO, 0.001)

func test_con_movimiento_reducido_el_aro_no_anima() -> void:
	var mesa = _mesa()
	var inicial: float = mesa.dial.aro.rotation
	mesa.controlador.procesar_comando(IniciarMano.new())
	assert_false(mesa.dial.giro != null and mesa.dial.giro.is_valid())
	assert_almost_eq(mesa.dial.aro.rotation, inicial + DialCampanadas.PASO, 0.001)

func test_una_devolucion_de_campanada_lleva_su_propio_aviso() -> void:
	var dial := DialCampanadas.new()
	add_child_autofree(dial)
	dial.presentar(9, 10, 1, "DE 10", true)
	var rotacion := dial.aro.rotation
	dial.presentar(10, 10, 1, "DE 10", true)
	assert_eq(dial.aviso.text, "+1 campanada")
	assert_eq(dial.aro.rotation, rotacion, "Una devolución no gira el aro")
	dial.presentar(9, 10, 2, "DE 10", true)
	assert_eq(dial.aviso.text, "", "La mano siguiente retira el aviso")

func test_el_boleto_se_ilumina_al_sumar_y_vuelve_a_su_color() -> void:
	var mesa = _mesa("", false)
	mesa.controlador.cargar_demostracion()
	mesa.establecer_movimiento_reducido(true)
	mesa.controlador.procesar_comando(IniciarMano.new())
	mesa.controlador.procesar_comando(PedirCarta.new())
	mesa.establecer_movimiento_reducido(false)
	mesa.controlador.procesar_comando(Plantarse.new())
	await get_tree().create_timer(2.5).timeout
	assert_eq(mesa._lectura.text, "+102 puntos")
	assert_eq(mesa.boleto.modulate, Color.WHITE)

func test_intervalo_y_umbral_se_leen_en_la_misma_linea() -> void:
	var mesa = _mesa()
	mesa.controlador.procesar_comando(IniciarMano.new())
	assert_string_contains(mesa._lectura_titulo.text, "UMBRAL 17")
