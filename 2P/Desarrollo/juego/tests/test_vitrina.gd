extends GutTest
## I4-01: la vitrina compara precios a la vista, confirma antes de cobrar y vuelve al mostrador.

func after_each() -> void:
	await get_tree().process_frame

func _casino_en_tienda(saldo := 10):
	var juego = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	juego._entregar()
	juego._cerrar()
	juego.campana.saldo = saldo
	juego.entrar("tienda")
	juego.tienda()
	return juego

func _ficha(juego, id: String):
	for ficha in juego.vitrina.fichas:
		if ficha.id == id: return ficha
	return null

func _esc(juego) -> void:
	var tecla := InputEventKey.new()
	tecla.keycode = KEY_ESCAPE
	tecla.pressed = true
	juego.vitrina._unhandled_input(tecla)

func test_cada_ficha_muestra_imagen_nombre_y_precio_sin_abrirla() -> void:
	var juego = _casino_en_tienda()
	assert_true(juego.vitrina.visible)
	assert_eq(juego.vitrina.fichas.size(), CampanaCasino.TIENDA.objetos.size())
	for objeto: ObjetoTienda in CampanaCasino.TIENDA.objetos:
		var ficha = _ficha(juego, objeto.id)
		assert_eq(ficha.precio.text, str(objeto.precio))
		assert_eq(ficha.nombre.text, objeto.nombre)
		assert_not_null(ficha.imagen.texture)
	assert_eq(juego.vitrina.saldo.cifra.text, "10")
	assert_true(juego.visitante.bloqueado)
	assert_false(juego.indicador_objetivo.visible)

func test_confirmar_cobra_una_vez_y_muestra_el_saldo_resultante() -> void:
	var juego = _casino_en_tienda()
	_ficha(juego, "lente").pressed.emit()
	assert_string_contains(juego.vitrina.detalle.resto.text, "saldo tras la compra: 4")
	assert_eq(juego.campana.saldo, 10, "Seleccionar no cobra")
	juego.vitrina.detalle.boton_comprar.pressed.emit()
	assert_eq(juego.campana.saldo, 4)
	assert_eq(juego.campana.lentes, 1)
	assert_eq(juego.vitrina.saldo.cifra.text, "4")
	assert_eq(juego.hud.saldo.cifra.text, "4", "El encabezado también se actualiza")
	assert_string_contains(juego.vitrina.confirmacion.text, "Lente de humo")
	juego.vitrina.detalle.boton_comprar.pressed.emit()
	assert_eq(juego.campana.lentes, 1, "Tras comprar, el botón ya no repite la compra")
	assert_eq(get_viewport().gui_get_focus_owner(), _ficha(juego, "lente"), "El foco vuelve al producto")

func test_un_bloqueo_explica_cuanto_falta_y_conserva_el_saldo() -> void:
	var juego = _casino_en_tienda(10)
	var corona = _ficha(juego, "corona")
	assert_eq(corona.marca_bloqueo.text, "No disponible")
	corona.pressed.emit()
	assert_eq(juego.vitrina.detalle.aviso.text, "Faltan 5 fichas.")
	assert_false(juego.vitrina.detalle.boton_comprar.visible)
	assert_eq(juego.campana.saldo, 10)

func test_esc_vuelve_del_detalle_al_catalogo_y_despues_al_mostrador() -> void:
	var juego = _casino_en_tienda()
	var lente = _ficha(juego, "lente")
	lente.pressed.emit()
	_esc(juego)
	assert_true(juego.vitrina.visible, "La primera Esc vuelve al catálogo")
	assert_eq(get_viewport().gui_get_focus_owner(), lente)
	assert_eq(juego.campana.saldo, 10, "Salir sin confirmar no cobra")
	_esc(juego)
	assert_false(juego.vitrina.visible, "La segunda Esc vuelve al mostrador")
	assert_false(juego.velo.visible)
	assert_false(juego.visitante.bloqueado)

func test_servicio_de_baraja_elige_carta_con_cambio_previsto_y_motivos() -> void:
	var juego = _casino_en_tienda(30)
	var diez: CartaEnPartida
	for carta in juego.campana.baraja:
		if carta.definicion.valor_impreso == 10: diez = carta
	_ficha(juego, "subir").pressed.emit()
	assert_true(juego.vitrina.selector.visible)
	var marco_derecho := 1320.0
	assert_lte(juego.vitrina.selector.get_rect().end.x, marco_derecho, "El selector no se sale del marco de la vitrina")
	assert_lte(juego.vitrina.selector.rejilla.get_combined_minimum_size().x, juego.vitrina.selector.size.x)
	assert_eq(juego.vitrina.selector.botones.size(), juego.campana.baraja.size())
	var indice: int = juego.campana.baraja.find(diez)
	var boton: Button = juego.vitrina.selector.botones[indice]
	assert_true(boton.disabled, "Un 10 no puede subir")
	assert_string_contains(boton.tooltip_text, "entre uno y diez")
	var uno: CartaEnPartida = juego.campana.baraja[0]
	var valor: int = uno.definicion.valor_impreso
	juego.vitrina.selector.botones[0].pressed.emit()
	assert_string_contains(juego.vitrina.detalle.efecto.text, "Pasará a %s." % (valor + 1))
	juego.vitrina.detalle.boton_comprar.pressed.emit()
	assert_eq(uno.definicion.valor_impreso, valor + 1)
	assert_eq(juego.campana.saldo, 25)

func test_retirar_respeta_el_minimo_de_doce_cartas() -> void:
	var juego = _casino_en_tienda(200)
	while juego.campana.baraja.size() > 12: juego.campana.baraja.pop_back()
	juego.vitrina._actualizar()
	var retirar = _ficha(juego, "eliminar")
	assert_eq(retirar.marca_bloqueo.text, "No disponible")
	retirar.pressed.emit()
	assert_eq(juego.vitrina.detalle.aviso.text, "Deben quedar doce cartas.")
	assert_eq(juego.campana.baraja.size(), 12)

func test_abrir_y_cerrar_la_vitrina_no_deja_nodos_huerfanos() -> void:
	await get_tree().process_frame
	var antes := Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	var juego = load("res://casino/casino.tscn").instantiate()
	add_child(juego)
	juego._entregar()
	juego._cerrar()
	juego.entrar("tienda")
	juego.tienda()
	juego.vitrina.fichas[1].pressed.emit()
	juego.vitrina.fichas[5].pressed.emit()
	juego._cerrar()
	juego.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT), antes, "Cada etiqueta se crea una sola vez")
