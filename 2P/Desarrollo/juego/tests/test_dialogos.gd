extends GutTest
## I4-06: conversaciones como datos en una escena compartida, conectadas a la campaña.

const ANFITRIONA: Conversacion = preload("res://datos/dialogos/anfitriona.tres")
const DialogoNovela := preload("res://casino/dialogos/dialogo_novela.gd")

func after_each() -> void:
	await get_tree().process_frame

func _casino():
	var juego = load("res://casino/casino.tscn").instantiate()
	juego.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	juego.size = Vector2(1440, 810)
	add_child_autofree(juego)
	return juego

func _tecla(juego, codigo: Key) -> void:
	var tecla := InputEventKey.new()
	tecla.keycode = codigo
	tecla.physical_keycode = codigo
	tecla.pressed = true
	juego.get_viewport().push_input(tecla)

func test_el_dialogo_de_la_anfitriona_no_tiene_referencias_rotas() -> void:
	assert_eq(ANFITRIONA.errores(), PackedStringArray())

func test_la_anfitriona_responde_antes_y_despues_de_la_invitacion() -> void:
	var campana := CampanaCasino.new()
	assert_eq(ANFITRIONA.inicio(campana.cumple), "saludo")
	assert_eq(ANFITRIONA.opciones("saludo", campana.cumple).size(), 2)
	campana.recibir_invitacion()
	assert_eq(ANFITRIONA.inicio(campana.cumple), "pista_0")
	campana.superadas = 3
	assert_eq(ANFITRIONA.inicio(campana.cumple), "pista_3")
	campana.superadas = 4
	assert_eq(ANFITRIONA.inicio(campana.cumple), "pista_4")

func test_condiciones_y_solicitudes_las_decide_la_campana() -> void:
	var campana := CampanaCasino.new()
	assert_true(campana.cumple("sin_invitacion"))
	assert_false(campana.cumple("con_invitacion"))
	assert_true(campana.atender("entregar_invitacion"))
	assert_false(campana.atender("entregar_invitacion"), "La invitación se entrega una sola vez")
	assert_false(campana.atender("desconocida"))
	campana.superadas = 2
	assert_true(campana.cumple("sellos==2"))
	assert_true(campana.cumple("sellos>=1"))
	assert_false(campana.cumple("sellos>=3"))

func test_entregar_la_invitacion_desde_el_dialogo_solo_una_vez() -> void:
	var juego = _casino()
	juego._recepcion()
	assert_true(juego.dialogo.visible)
	assert_true(juego.visitante.bloqueado, "El visitante queda quieto")
	assert_eq(juego.dialogo.nombre.text, "La anfitriona")
	assert_not_null(juego.dialogo.retrato.texture)
	assert_false(juego.campana.recibida, "Abrir no cambia el progreso")
	juego.dialogo.avanzar()
	assert_eq(juego.dialogo.botones.size(), 2)
	assert_false(juego.campana.recibida, "Avanzar tampoco")
	juego.dialogo.elegir(0)
	assert_eq(juego.dialogo.actual, "oferta")
	assert_false(juego.campana.recibida, "Entregar la invitación abre la oferta; aún no entrega nada")
	juego.dialogo.completar()
	assert_eq(juego.dialogo.botones.size(), 4)
	juego.dialogo.elegir(2)
	assert_true(juego.campana.recibida)
	assert_eq(juego.campana.saldo, 10)
	assert_eq(juego.campana.amuletos, ["moneda"] as Array[String])
	assert_eq(juego.dialogo.actual, "entrega")
	assert_eq(juego.hud.saldo.cifra.text, "10")
	juego.dialogo.completar()
	juego.dialogo.avanzar()
	assert_false(juego.dialogo.visible)
	assert_false(juego.visitante.bloqueado, "Recupera el control al cerrar")
	juego.campana.saldo = 3
	juego._recepcion()
	assert_eq(juego.dialogo.actual, "pista_0", "Ya no ofrece entregarla")
	assert_eq(juego.campana.saldo, 3)

func test_volver_y_esc_cierran_sin_aplicar_nada() -> void:
	var juego = _casino()
	juego._recepcion()
	juego.dialogo.completar()
	juego.dialogo.elegir(1)
	assert_false(juego.dialogo.visible)
	assert_false(juego.campana.recibida)
	juego._recepcion()
	_tecla(juego, KEY_ESCAPE)
	assert_false(juego.dialogo.visible)
	assert_false(juego.menu.visible, "Esc cierra el diálogo y no abre la pausa")
	assert_false(juego.campana.recibida)

func test_la_primera_pulsacion_completa_la_linea_que_se_escribe() -> void:
	var juego = _casino()
	juego.dialogo.reducido = false
	juego.dialogo.abrir(ANFITRIONA, juego.campana.cumple, false)
	assert_true(juego.dialogo.escribiendo())
	assert_eq(juego.dialogo.botones.size(), 0, "Las respuestas esperan a la línea completa")
	_tecla(juego, KEY_E)
	assert_false(juego.dialogo.escribiendo())
	assert_eq(juego.dialogo.botones.size(), 2)
	assert_eq(juego.get_viewport().gui_get_focus_owner(), juego.dialogo.botones[0])
	_tecla(juego, KEY_E)
	assert_eq(juego.dialogo.actual, "oferta", "E elige la respuesta enfocada")

func test_con_movimiento_reducido_el_texto_aparece_completo() -> void:
	var juego = _casino()
	juego.dialogo.abrir(ANFITRIONA, juego.campana.cumple, true)
	assert_false(juego.dialogo.escribiendo())
	assert_eq(juego.dialogo.texto.visible_characters, -1)
	assert_eq(juego.dialogo.botones.size(), 2)
	juego.dialogo.completar()
	assert_eq(juego.dialogo.botones.size(), 2, "Completar otra vez no repite las respuestas")
	assert_eq(juego.dialogo.respuestas.get_child_count(), 2)

func test_otra_conversacion_usa_la_misma_escena_solo_con_datos() -> void:
	var datos := Conversacion.new()
	datos.personajes = {"custodio": {"nombre": "El Custodio", "retrato": "res://recursos/arte/custodio-grabado.png"}}
	datos.entradas = [{"si": "sellos>=1", "ir": "despedida"}, {"ir": "uno"}]
	datos.intervenciones = {
		"uno": {"personaje": "custodio", "texto": "Primera línea.", "siguiente": "dos"},
		"dos": {"personaje": "custodio", "texto": "Segunda línea."},
		"despedida": {"personaje": "custodio", "texto": "Ya tienes tu sello."},
	}
	assert_eq(datos.errores(), PackedStringArray())
	var dialogo := DialogoNovela.new()
	add_child_autofree(dialogo)
	var campana := CampanaCasino.new()
	assert_true(dialogo.abrir(datos, campana.cumple, true))
	assert_eq(dialogo.texto.text, "Primera línea.")
	dialogo.avanzar()
	assert_eq(dialogo.texto.text, "Segunda línea.")
	watch_signals(dialogo)
	dialogo.avanzar()
	assert_signal_emitted(dialogo, "cerrado")
	campana.superadas = 1
	dialogo.abrir(datos, campana.cumple, true)
	assert_eq(dialogo.actual, "despedida")

func test_una_referencia_rota_se_detecta() -> void:
	var datos := Conversacion.new()
	datos.personajes = {"a": {"nombre": "A"}}
	datos.entradas = [{"ir": "x"}]
	datos.intervenciones = {"x": {"personaje": "a", "texto": "Hola", "siguiente": "falta"}}
	assert_eq(datos.errores().size(), 1)
