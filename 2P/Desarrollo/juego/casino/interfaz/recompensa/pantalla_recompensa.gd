extends Control
## Recompensa tras vencer a un crupier (revisión de pantallas, 26 nov 2026).
## El crupier despide la mesa con su frase junto a su retrato; las tres cartas llegan boca abajo y
## se voltean una tras otra. Al enfocar o señalar una carta, el panel inferior dice qué cambia en
## la baraja (cantidad total y reparto por palos) antes de decidir. La primera pulsación elige la
## carta; la segunda, o «Añadir a la baraja», la confirma. Esc equivale a seguir sin carta.

const Carta := preload("res://cartas/carta.tscn")
const Libro := preload("res://casino/interfaz/libro.gd")
const RETRATOS := {"custodio": "res://recursos/arte/custodio-grabado.png"}
const EFECTOS := {
	Palos.VELAS: "Cada Vela conservada en una mano válida suma +1 al multiplicador.",
	Palos.LLAVES: "Una vez por mano puedes devolverla al fondo del mazo y recibir otra carta.",
	Palos.RELOJES: "Vale uno menos que lo impreso: pides con menos riesgo, pero suma menos.",
	Palos.MASCARAS: "Su valor se oculta hasta plantarte; mientras tanto ves un intervalo.",
}
const ANCHO_CARTA := 196.0
const ALTO_CARTA := 278.0
const SEPARACION := 44.0
## Columna de contenido a la derecha del retrato.
const CONTENIDO := Rect2(500, 92, 820, 640)

signal resuelta(indice: int)

var cartas: Array[Button] = []
var boton_confirmar: Button
var boton_omitir: Button
var dicho: Label
var titulo_detalle: Label
var texto_detalle: Label
var movimiento_reducido := false
var elegida := -1
var _opciones: Array[Dictionary] = []
var _baraja: Dictionary = {}
var _total := 0
var _barras: Dictionary = {}
var _cifras: Dictionary = {}
var _cifra_total: Label
var _retrato: TextureRect
var _cabecera: Label
var _premio: Label
var _nombre_jefe: Label
var _marca_elegida: Label
var _tween: Tween

func _init() -> void:
	name = "PantallaRecompensa"
	size = Vector2(1440, 810)
	mouse_filter = Control.MOUSE_FILTER_STOP
	# El tema de la mesa da a las cartas su cifra con remate.
	theme = preload("res://temas/mesa.tres")
	hide()

func _ready() -> void:
	var fondo := ColorRect.new()
	fondo.color = Color(0.02, 0.05, 0.04, 0.9)
	fondo.size = size
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fondo)
	var marco := Panel.new()
	marco.position = Vector2(80, 48)
	marco.size = Vector2(1280, 714)
	var estilo := Libro.caja(Color("0f231d"), Libro.ORO)
	estilo.set_border_width_all(2)
	marco.add_theme_stylebox_override("panel", estilo)
	marco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(marco)
	_construir_crupier()
	_construir_cabecera()
	_construir_detalle()
	_construir_botones()

func _construir_crupier() -> void:
	var ventana := Panel.new()
	ventana.position = Vector2(112, 80)
	ventana.size = Vector2(340, 372)
	ventana.add_theme_stylebox_override("panel", Libro.caja(Color("08150f"), Color("645c44")))
	ventana.clip_contents = true
	ventana.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ventana)
	_retrato = TextureRect.new()
	_retrato.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_retrato.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_retrato.size = ventana.size
	_retrato.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ventana.add_child(_retrato)
	# Bocadillo del crupier bajo su retrato, con la cola hacia arriba.
	var bocadillo := Panel.new()
	bocadillo.position = Vector2(112, 470)
	bocadillo.size = Vector2(340, 260)
	var papel := Libro.caja(Color("efe2c4"), Color("8a6f3e"))
	papel.set_corner_radius_all(4)
	bocadillo.add_theme_stylebox_override("panel", papel)
	bocadillo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bocadillo)
	var cola := Polygon2D.new()
	cola.polygon = PackedVector2Array([Vector2(150, 471), Vector2(170, 454), Vector2(190, 471)])
	cola.color = Color("efe2c4")
	add_child(cola)
	_nombre_jefe = Libro.rotulo("", 13, Color("6b4f22"))
	_nombre_jefe.position = Vector2(132, 482)
	_nombre_jefe.size = Vector2(300, 18)
	add_child(_nombre_jefe)
	dicho = Libro.rotulo("", 21, Color("2a1d10"), true)
	dicho.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dicho.position = Vector2(132, 504)
	dicho.size = Vector2(300, 216)
	dicho.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	add_child(dicho)

func _construir_cabecera() -> void:
	_cabecera = Libro.rotulo("", 14, Libro.ORO)
	_cabecera.position = Vector2(CONTENIDO.position.x, 84)
	add_child(_cabecera)
	var titulo := Libro.rotulo("Una carta de la casa", 46, Libro.PAPEL, true)
	titulo.position = Vector2(CONTENIDO.position.x, 104)
	add_child(titulo)
	_premio = Libro.rotulo("", 19, Color("d9cfb4"))
	_premio.position = Vector2(CONTENIDO.position.x, 164)
	_premio.size = Vector2(CONTENIDO.size.x, 26)
	add_child(_premio)
	_marca_elegida = Libro.rotulo("ELEGIDA", 12, Color("1a120b"))
	_marca_elegida.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_marca_elegida.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var placa := StyleBoxFlat.new()
	placa.bg_color = Libro.ORO
	placa.set_corner_radius_all(3)
	_marca_elegida.add_theme_stylebox_override("normal", placa)
	_marca_elegida.size = Vector2(84, 22)
	_marca_elegida.hide()
	add_child(_marca_elegida)

func _construir_detalle() -> void:
	var panel := Panel.new()
	panel.position = Vector2(CONTENIDO.position.x, 524)
	panel.size = Vector2(CONTENIDO.size.x, 132)
	panel.add_theme_stylebox_override("panel", Libro.caja(Color("0a1813"), Color("3d4a3c")))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	titulo_detalle = Libro.rotulo("", 24, Libro.PAPEL, true)
	titulo_detalle.position = Vector2(CONTENIDO.position.x + 22, 534)
	titulo_detalle.size = Vector2(420, 30)
	add_child(titulo_detalle)
	texto_detalle = Libro.rotulo("", 16, Color("cfc6ad"))
	texto_detalle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto_detalle.position = Vector2(CONTENIDO.position.x + 22, 568)
	texto_detalle.size = Vector2(410, 80)
	texto_detalle.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	add_child(texto_detalle)
	# Reparto de la baraja: una barra por palo; la del palo ofrecido crece en dorado.
	var x := CONTENIDO.position.x + 462
	var rotulo := Libro.rotulo("TU BARAJA", 12, Libro.ORO)
	rotulo.position = Vector2(x, 536)
	add_child(rotulo)
	_cifra_total = Libro.rotulo("", 14, Libro.PAPEL)
	_cifra_total.position = Vector2(x + 150, 534)
	_cifra_total.size = Vector2(186, 20)
	_cifra_total.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_cifra_total)
	var y := 562.0
	for palo in Palos.TODOS:
		var nombre := Libro.rotulo(Palos.NOMBRES[palo], 13, Color("b9c4a8"))
		nombre.position = Vector2(x, y - 2)
		nombre.size = Vector2(76, 18)
		add_child(nombre)
		var barra := ProgressBar.new()
		barra.show_percentage = false
		barra.position = Vector2(x + 80, y + 3)
		barra.size = Vector2(200, 9)
		barra.max_value = 1.0
		barra.step = 0.0
		var pista := StyleBoxFlat.new()
		pista.bg_color = Color("1d2e26")
		pista.set_corner_radius_all(4)
		var relleno := StyleBoxFlat.new()
		relleno.bg_color = Color("8b8a72")
		relleno.set_corner_radius_all(4)
		barra.add_theme_stylebox_override("background", pista)
		barra.add_theme_stylebox_override("fill", relleno)
		barra.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(barra)
		_barras[palo] = barra
		var cifra := Libro.rotulo("", 13, Libro.PAPEL)
		cifra.position = Vector2(x + 288, y - 2)
		cifra.size = Vector2(48, 18)
		cifra.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		add_child(cifra)
		_cifras[palo] = cifra
		y += 22.0

func _construir_botones() -> void:
	boton_confirmar = _boton("AÑADIR A LA BARAJA  ·  %s" % Acciones.tecla(Acciones.ACEPTAR), Vector2(CONTENIDO.position.x, 676), Vector2(400, 52), true)
	boton_confirmar.pressed.connect(_confirmar)
	boton_omitir = _boton("SEGUIR SIN CARTA  ·  %s" % Acciones.tecla(Acciones.VOLVER), Vector2(CONTENIDO.position.x + 420, 676), Vector2(400, 52), false)
	boton_omitir.pressed.connect(func() -> void: resuelta.emit(-1))

func _boton(texto: String, posicion: Vector2, medida: Vector2, primario: bool) -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.position = posicion
	boton.size = medida
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	boton.add_theme_font_override("font", Libro.SANS)
	boton.add_theme_font_size_override("font_size", Tipografia.MINIMA)
	var color := Color("efe2c4") if primario else Color("17342a")
	var texto_color := Color("1a120b") if primario else Libro.PAPEL
	var normal := Libro.caja(color, Color("8a6f3e") if primario else Color("645c44"))
	var foco := Libro.caja(color.lightened(0.08), Libro.PAPEL if not primario else Color("1a120b"))
	foco.set_border_width_all(2)
	var apagado := Libro.caja(Color("2a2f29"), Color("3d4a3c"))
	boton.add_theme_stylebox_override("normal", normal)
	boton.add_theme_stylebox_override("hover", foco)
	boton.add_theme_stylebox_override("focus", foco)
	boton.add_theme_stylebox_override("pressed", foco)
	boton.add_theme_stylebox_override("disabled", apagado)
	for estado in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		boton.add_theme_color_override(estado, texto_color)
	boton.add_theme_color_override("font_disabled_color", Color("7d8574"))
	add_child(boton)
	return boton

## jefe: id de la mesa ("custodio"…); premio: fichas ganadas; baraja: la baraja actual del intento.
func presentar(jefe: String, frase: String, premio: int, superadas: int, opciones: Array[Dictionary], baraja: Array[CartaEnPartida]) -> void:
	_opciones = opciones
	elegida = -1
	_retrato.texture = load(RETRATOS.get(jefe, "res://casino/arte/personaje_%s.webp" % jefe))
	_nombre_jefe.text = str(CampanaCasino.NOMBRES.get(jefe, "")).to_upper()
	_ajustar_dicho(frase)
	_cabecera.text = "MESA SUPERADA  ·  SELLO %s DE 4" % ["I", "II", "III", "IV"][clampi(superadas - 1, 0, 3)]
	# Los botones ya dicen qué hacer: arriba solo queda lo que se ha ganado.
	_premio.text = "+%s fichas" % premio if premio > 0 else ""
	_baraja.clear()
	for palo in Palos.TODOS: _baraja[palo] = 0
	for carta in baraja:
		_baraja[carta.definicion.palo] = int(_baraja.get(carta.definicion.palo, 0)) + 1
	_total = baraja.size()
	for carta in cartas:
		remove_child(carta)
		carta.queue_free()
	cartas.clear()
	var ancho := opciones.size() * ANCHO_CARTA + maxi(opciones.size() - 1, 0) * SEPARACION
	var x0 := CONTENIDO.position.x + (CONTENIDO.size.x - ancho) * 0.5
	for i in range(opciones.size()):
		var datos := _datos_carta(opciones[i])
		var carta := Carta.instantiate() as Button
		carta.name = "Recompensa%d" % i
		carta.position = Vector2(x0 + i * (ANCHO_CARTA + SEPARACION), 210)
		carta.size = Vector2(ANCHO_CARTA, ALTO_CARTA)
		add_child(carta)
		carta.establecer_movimiento_reducido(movimiento_reducido)
		carta.presentar(datos if movimiento_reducido else {"palo": datos.palo, "oculta": true})
		_rotular(carta, i)
		carta.pressed.connect(_pulsar.bind(i))
		carta.focus_entered.connect(_mostrar.bind(i))
		carta.mouse_entered.connect(_mostrar.bind(i))
		carta.mouse_exited.connect(func() -> void: _mostrar(elegida))
		cartas.append(carta)
	for i in range(cartas.size()):
		var vecino_izq := cartas[i - 1] if i > 0 else cartas[i]
		var vecino_der := cartas[i + 1] if i < cartas.size() - 1 else cartas[i]
		cartas[i].focus_neighbor_left = vecino_izq.get_path()
		cartas[i].focus_neighbor_right = vecino_der.get_path()
		cartas[i].focus_neighbor_bottom = boton_confirmar.get_path()
	boton_confirmar.focus_neighbor_top = cartas[0].get_path() if not cartas.is_empty() else NodePath()
	boton_omitir.focus_neighbor_top = cartas[-1].get_path() if not cartas.is_empty() else NodePath()
	_actualizar_seleccion()
	_mostrar(-1)
	show()
	_revelar()
	if not cartas.is_empty():
		cartas[0].grab_focus()
	else:
		boton_omitir.grab_focus()

## La frase entera cabe en el bocadillo: la letra baja de 21 a 15 puntos si hace falta.
func _ajustar_dicho(frase: String) -> void:
	dicho.text = frase
	for puntos in range(21, 14, -1):
		dicho.add_theme_font_size_override("font_size", puntos)
		if dicho.get_line_count() * dicho.get_line_height() <= dicho.size.y:
			break

func _datos_carta(opcion: Dictionary) -> Dictionary:
	var datos := opcion.duplicate()
	datos.valor_efectivo = maxi(1, int(datos.valor) - 1) if datos.palo == Palos.RELOJES else datos.valor
	return datos

## Las cartas entran boca abajo y se voltean de izquierda a derecha.
func _revelar() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if movimiento_reducido or cartas.is_empty():
		return
	_tween = create_tween()
	for i in range(cartas.size()):
		cartas[i].animar_entrada(0.08 * i)
		_tween.tween_interval(0.32 if i == 0 else 0.16)
		_tween.tween_callback(_voltear.bind(i))

## Termina la animación de entrada en el acto (para pruebas y capturas).
func revelar_ya() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	for i in range(cartas.size()):
		_voltear(i)

func _voltear(indice: int) -> void:
	cartas[indice].presentar(_datos_carta(_opciones[indice]))
	_rotular(cartas[indice], indice)

## La carta escribe su propia ayuda al presentarse; aquí se sustituye por la de la recompensa.
func _rotular(carta: Button, indice: int) -> void:
	carta.set_meta("ayuda", _resumen(_opciones[indice]))
	carta.tooltip_text = _resumen(_opciones[indice])
	carta.accessibility_name = carta.tooltip_text

func _resumen(opcion: Dictionary) -> String:
	var texto := "Añadir %s de %s a la baraja" % [opcion.valor, Palos.NOMBRES[opcion.palo]]
	if opcion.get("rasgo", "") == CartaEnPartida.RASGO_RACHA_DOBLE:
		texto += ". Cuenta como dos cartas para Racha; para el umbral vale %s" % opcion.valor
	return texto

func _pulsar(indice: int) -> void:
	if indice == elegida:
		_confirmar()
		return
	elegida = indice
	_actualizar_seleccion()
	_mostrar(indice)

func _confirmar() -> void:
	if elegida >= 0:
		resuelta.emit(elegida)

func _actualizar_seleccion() -> void:
	for i in range(cartas.size()):
		cartas[i].establecer_seleccionada(i == elegida)
		cartas[i].modulate = Color.WHITE if elegida < 0 or i == elegida else Color(0.72, 0.72, 0.72)
	boton_confirmar.disabled = elegida < 0
	_marca_elegida.visible = elegida >= 0
	if elegida >= 0:
		var carta := cartas[elegida]
		_marca_elegida.position = carta.position + Vector2((ANCHO_CARTA - _marca_elegida.size.x) * 0.5, ALTO_CARTA + 10)

## Muestra el efecto de la carta y cómo cambiaría la baraja; con -1, el reparto actual.
func _mostrar(indice: int) -> void:
	var palo := ""
	if indice >= 0 and indice < _opciones.size():
		var opcion := _opciones[indice]
		palo = opcion.palo
		var nombre := "%s de %s" % [opcion.valor, Palos.NOMBRES[palo]]
		if opcion.get("rasgo", "") == CartaEnPartida.RASGO_RACHA_DOBLE:
			nombre += "  ·  Racha ×2"
		titulo_detalle.text = nombre
		var texto := str(EFECTOS[palo])
		if palo == Palos.RELOJES:
			texto += " Este suma %s." % maxi(1, int(opcion.valor) - 1)
		if opcion.get("rasgo", "") == CartaEnPartida.RASGO_RACHA_DOBLE:
			texto = "Cuenta como dos cartas para Racha. " + texto
		texto_detalle.text = texto
	else:
		titulo_detalle.text = "Elige una carta"
		texto_detalle.text = "Señala una carta para ver su efecto y cómo cambia tu baraja. Una carta más también diluye las que ya tienes."
	var total := _total + (1 if not palo.is_empty() else 0)
	_cifra_total.text = "%s cartas" % _total if palo.is_empty() else "%s → %s cartas" % [_total, total]
	var mayor := 1
	for p in Palos.TODOS:
		mayor = maxi(mayor, int(_baraja[p]) + (1 if p == palo else 0))
	for p in Palos.TODOS:
		var actual := int(_baraja[p])
		var nuevo := actual + (1 if p == palo else 0)
		var barra: ProgressBar = _barras[p]
		barra.value = float(nuevo) / mayor
		var relleno: StyleBoxFlat = barra.get_theme_stylebox("fill")
		relleno.bg_color = Libro.ORO if p == palo else Color("6f7564")
		var cifra: Label = _cifras[p]
		cifra.text = str(actual) if p != palo else "%s→%s" % [actual, nuevo]
		cifra.add_theme_color_override("font_color", Libro.ORO if p == palo else Libro.PAPEL)

func _unhandled_input(evento: InputEvent) -> void:
	if not visible or not Acciones.es_pulsacion(evento):
		return
	var puerto := get_viewport()
	if evento.is_action_pressed(Acciones.VOLVER):
		resuelta.emit(-1)
	elif evento is InputEventKey and evento.keycode in [KEY_1, KEY_2, KEY_3] and evento.keycode - KEY_1 < cartas.size():
		cartas[evento.keycode - KEY_1].grab_focus()
		_pulsar(evento.keycode - KEY_1)
	else:
		return
	puerto.set_input_as_handled()
