extends GutTest
## I4-04: sellos ilustrados y saldo con icono, iguales en exploración y mesa.

const SellosCampana := preload("res://casino/interfaz/hud/sellos_campana.gd")
const HudCampana := preload("res://casino/interfaz/hud/hud_campana.gd")
const Mesa := preload("res://mesa/mesa.tscn")

func after_each() -> void:
	await get_tree().process_frame

func _obtenidos(sellos) -> Array:
	var estados := []
	for recuadro in sellos.recuadros: estados.append(recuadro.get_meta("obtenido"))
	return estados

func test_los_cuatro_estados_se_distinguen_sin_depender_del_color() -> void:
	var sellos = SellosCampana.new()
	add_child_autofree(sellos)
	var esperados := [[false, false, false], [true, false, false], [true, true, false], [true, true, true]]
	for ganados in range(4):
		sellos.presentar(ganados, true)
		assert_eq(_obtenidos(sellos), esperados[ganados])
		# Pendiente: opacidad baja y texto «pendiente»; conseguido: opaco y «conseguido».
		for i in range(3):
			var recuadro: TextureRect = sellos.recuadros[i]
			assert_eq(recuadro.modulate.a < 0.5, i >= ganados)
			assert_string_contains(recuadro.tooltip_text, "pendiente" if i >= ganados else "conseguido")
	sellos.presentar(4, true)
	assert_eq(_obtenidos(sellos), [true, true, true], "La victoria sobre el Dueño no añade un cuarto sello")

func test_el_sello_nuevo_se_estampa_una_vez_y_se_asienta() -> void:
	var sellos = SellosCampana.new()
	add_child_autofree(sellos)
	sellos.presentar(0)
	assert_eq(sellos.recuadros[0].scale, Vector2.ONE, "La primera presentación no anima")
	sellos.presentar(1)
	assert_gt(sellos.recuadros[0].scale.x, 1.0, "El sello ganado cae más grande")
	await get_tree().create_timer(0.5).timeout
	assert_eq(sellos.recuadros[0].scale, Vector2.ONE)
	sellos.presentar(1)
	assert_eq(sellos.recuadros[0].scale, Vector2.ONE, "Repetir la presentación no vuelve a estampar")

func test_con_movimiento_reducido_el_sello_aparece_de_inmediato() -> void:
	var sellos = SellosCampana.new()
	add_child_autofree(sellos)
	sellos.presentar(0, true)
	sellos.presentar(1, true)
	assert_eq(sellos.recuadros[0].scale, Vector2.ONE)
	assert_true(sellos.recuadros[0].get_meta("obtenido"))

func test_el_casino_muestra_sellos_y_saldo_reales() -> void:
	var juego = load("res://casino/casino.tscn").instantiate()
	add_child_autofree(juego)
	assert_false(juego.hud.saldo.visible, "Sin invitación no hay fichas")
	juego._entregar()
	assert_true(juego.hud.saldo.visible)
	assert_eq(juego.hud.saldo.cifra.text, "10")
	juego.campana.saldo = 37
	juego.campana.superadas = 2
	juego._refrescar()
	assert_eq(juego.hud.saldo.cifra.text, "37")
	assert_eq(_obtenidos(juego.hud.sellos), [true, true, false])
	juego.inventario()
	assert_string_contains(juego.libro.cuerpo.text, "Sello del Recaudador · conseguido")
	assert_string_contains(juego.libro.cuerpo.text, "Sello de la Coleccionista · pendiente")

func test_la_mesa_de_campana_usa_el_mismo_recuadro() -> void:
	var campana := CampanaCasino.new()
	campana.recibir_invitacion()
	campana.superadas = 1
	assert_true(campana.iniciar("recaudador"))
	var mesa = Mesa.instantiate()
	mesa.campana = campana
	mesa.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mesa.size = Vector2(1440, 810)
	add_child_autofree(mesa)
	assert_not_null(mesa.hud)
	assert_eq(mesa.hud.saldo.cifra.text, str(campana.saldo), "Incluye las quince fichas del Recaudador")
	assert_eq(_obtenidos(mesa.hud.sellos), [true, false, false])
	assert_false(mesa._subtitulo.visible)
