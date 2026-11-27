extends GutTest
## Comprobación de la entrega del piloto I6-07 (26 nov 2026): una campaña entera por los caminos
## reales del juego (objeto inicial, cuatro mesas, levantarse con P, recompensa, tienda, guardar y
## continuar) con cada objeto inicial. En cada mesa el inventario enseña lo que se lleva y nada
## más, y no aparece ningún error del motor.

const RUTA_PRUEBA := "user://partida_prueba_entrega.json"
var _ruta_partida := ""
var _ruta_ajustes := ""

func before_each() -> void:
	_ruta_partida = PartidaGuardada.ruta
	_ruta_ajustes = AjustesJuego.ruta
	PartidaGuardada.ruta = RUTA_PRUEBA
	AjustesJuego.ruta = "user://ajustes_prueba_entrega.cfg"
	PartidaGuardada.borrar()

func after_each() -> void:
	PartidaGuardada.borrar()
	PartidaGuardada.ruta = _ruta_partida
	DirAccess.remove_absolute(ProjectSettings.globalize_path(AjustesJuego.ruta))
	AjustesJuego.ruta = _ruta_ajustes
	await get_tree().process_frame

func _casino():
	var juego = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	juego.guardado_activo = true
	return juego

func _tecla(nodo: Node, codigo: Key) -> void:
	var evento := InputEventKey.new()
	evento.keycode = codigo
	evento.physical_keycode = codigo
	evento.pressed = true
	nodo._unhandled_key_input(evento)

func _sentar(juego, jefe: String) -> void:
	juego.entrar(jefe)
	juego._presentar_jefe()
	juego._solicitud("tomar_asiento")
	juego.mesa.establecer_movimiento_reducido(true)

func _mazo(juego, cartas: Array) -> void:
	var m: ControladorMesa = juego.mesa.controlador
	m.partida.mazo.clear()
	for d in cartas:
		m.partida.mazo.append(FabricaCartas.crear_carta(d[0], d[1]))

func _ids_inventario_mesa(juego) -> Array:
	juego.mesa._ver_objetos()
	var ids: Array = juego.mesa.modal.contenido.find_children("Objeto_*", "", true, false).map(func(t): return t.id)
	juego.mesa.cerrar_modal()
	ids.sort()
	return ids

func _llevados(campana: CampanaCasino) -> Array:
	var ids: Array = Array(campana.amuletos).duplicate()
	if campana.lentes > 0: ids.append("lente")
	ids.sort()
	return ids

## Gana la mesa con una mano exacta y se levanta con P, como en el juego.
func _ganar(juego) -> void:
	var mesa = juego.mesa
	var umbral: int = mesa.controlador.partida.umbral
	mesa.controlador.partida.meta = 1
	_mazo(juego, [["llaves", umbral - 10], ["velas", 10]])
	mesa.boton_iniciar_pedir.pressed.emit()
	mesa.boton_plantarse.pressed.emit()
	assert_true(mesa.vista.get("terminado", false) and mesa.vista.get("victoria", false), "Mesa ganada")
	_tecla(mesa, KEY_P)

func _campana_completa(inicial: String) -> void:
	var juego = _casino()
	juego._solicitud("objeto_inicial:" + inicial)
	assert_eq(_llevados(juego.campana), [inicial], "Solo el objeto elegido: %s" % inicial)
	for jefe in CampanaCasino.MESAS:
		_sentar(juego, jefe)
		assert_not_null(juego.mesa, "Se sienta con %s" % jefe)
		assert_eq(_ids_inventario_mesa(juego), _llevados(juego.campana), "%s: el inventario de la mesa enseña lo que se lleva" % jefe)
		if juego.campana.lentes > 0:
			_mazo(juego, [["mascaras", 3], ["velas", 2]])
			juego.mesa.boton_iniciar_pedir.pressed.emit()
			var antes: int = juego.campana.lentes
			juego.mesa._usar_lente()
			assert_eq(juego.campana.lentes, antes - 1, "%s: la Lente se gasta al usarla" % jefe)
			assert_eq(_ids_inventario_mesa(juego), _llevados(juego.campana), "%s: tras gastarla, el inventario coincide" % jefe)
			juego.mesa.boton_plantarse.pressed.emit()
		_ganar(juego)
		assert_null(juego.mesa, "%s: se levanta sin cerrarse el juego" % jefe)
		if jefe == "dueno":
			assert_false(juego.recompensa.visible, "Tras el Dueño no hay carta")
			assert_string_contains(juego.libro.cuerpo.text, "portón", "sino el camino a la salida")
			juego._cerrar()
			juego.interactuar({"tipo": "salida"})
			assert_eq(juego.libro.nombre.text, "El primer amanecer", "La verja se abre con los cuatro sellos")
			break
		assert_true(juego.recompensa.visible, "%s: se elige carta" % jefe)
		assert_not_null(juego.recompensa._retrato.texture, "%s: con su retrato" % jefe)
		var baraja: int = juego.campana.baraja.size()
		_tecla(juego.recompensa, KEY_1)
		juego.recompensa.boton_confirmar.pressed.emit()
		assert_eq(juego.campana.baraja.size(), baraja + 1, "%s: la carta entra en la baraja" % jefe)
		assert_false(juego.recompensa.visible)
		if jefe == "custodio":
			juego.campana.saldo = 200
			var compra := "lente" if inicial != "lente" else "corona"
			assert_true(juego.campana.comprar(compra), "La tienda vende %s" % compra)
			juego._refrescar()
			var otro = _casino()
			assert_true(otro.continuar(), "La partida guardada se continúa")
			assert_eq(_llevados(otro.campana), _llevados(juego.campana), "con los mismos objetos")
			assert_eq(otro.campana.superadas, 1)
			otro.queue_free()
		juego.inventario()
		var en_libro: Array = juego.libro.lista.find_children("Objeto_*", "", true, false).map(func(t): return t.id)
		en_libro.sort()
		assert_eq(en_libro, _llevados(juego.campana), "%s: las pertenencias coinciden" % jefe)
		juego._cerrar()
	assert_eq(juego.campana.superadas, 4, "Cuatro sellos")
	assert_engine_error_count(0, "Sin errores del motor en toda la campaña")

func test_campana_completa_con_la_lente() -> void:
	_campana_completa("lente")

func test_campana_completa_con_el_sello_del_prudente() -> void:
	_campana_completa("prudente")

func test_campana_completa_con_la_moneda() -> void:
	_campana_completa("moneda")

func test_la_moneda_cuenta_sus_usos_en_la_mesa() -> void:
	var juego = _casino()
	juego._solicitud("objeto_inicial:moneda")
	_sentar(juego, "custodio")
	var umbral: int = juego.mesa.controlador.partida.umbral
	_mazo(juego, [["llaves", umbral - 10], ["velas", 10]])
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	juego.mesa.boton_plantarse.pressed.emit()
	juego.mesa._ver_objetos()
	var moneda = juego.mesa.modal.contenido.find_child("Objeto_moneda", true, false)
	assert_eq(moneda.usos_encendidos(), 2, "Un Punto exacto gasta un uso de tres")
	assert_engine_error_count(0)

func test_perder_borra_la_partida_y_vuelve_a_empezar_sin_objetos() -> void:
	var juego = _casino()
	juego._solicitud("objeto_inicial:prudente")
	_sentar(juego, "custodio")
	juego.mesa.controlador.partida.campanadas = 1
	_mazo(juego, [["llaves", 10], ["velas", 7]])
	juego.mesa.boton_iniciar_pedir.pressed.emit()
	juego.mesa.boton_plantarse.pressed.emit()
	assert_true(juego.mesa.vista.get("terminado", false) and not juego.mesa.vista.get("victoria", true), "Sin campanadas y lejos de la meta")
	_tecla(juego.mesa, KEY_P)
	assert_null(juego.mesa)
	assert_false(PartidaGuardada.existe(), "La derrota borra la partida")
	assert_engine_error_count(0)
