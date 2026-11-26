extends Control
## Inicio y pausa (I4-07). Muestra pantallas y emite lo que elige el jugador; el casino decide
## qué congelar y cómo volver. Esc retrocede una pantalla: desde la pausa reanuda y desde el
## inicio no hace nada. Se navega con ratón, flechas, Tab y Enter.

signal entrar
signal continuar
signal reanudar
signal volver_al_inicio
signal salir
signal movimiento_cambiado(reducido: bool)
## Cambió un ajuste de lectura de las conversaciones (I5-10).
signal lectura_cambiada
signal ver_baraja

const Libro := preload("res://casino/interfaz/libro.gd")
const PanelOpciones := preload("res://casino/interfaz/menus/panel_opciones.gd")
const PORTADAS := [
	preload("res://casino/interfaz/menus/arte/portada_invitacion.webp"),
	preload("res://casino/interfaz/menus/arte/portada_corvera.webp"),
]
const INTERVALO_PORTADA := 14.0
const FUNDIDO_PORTADA := 1.4
const BASE := Vector2(1440, 810)
const MUTED := Color("b9ad91")
## Créditos (I5-10): el equipo y su parte, como en la exposición.
const CREDITOS := [
	["Julio", "Concepto, diseño visual y balance"],
	["Ariel", "Cartas, mecánicas, objetos y personajes"],
	["Kenned", "Programación, navegación, experiencia de usuario y narrativa"],
]
const GUIA_RAPIDA := [
	["Moverte", "WASD o flechas para caminar. E para hablar, entrar o examinar."],
	["Jugar una mano", "Iniciar cuesta una campanada. Pide cartas sin pasar el umbral. Plántate para revelar las Máscaras y puntuar."],
	["Salir del casino", "Gana tres sellos y derrota al Dueño. Abre el plano con M. La tienda está junto al Recaudador."],
]

var audio: AudioCasino
## Devuelve [título, texto] de las pertenencias del intento.
var texto_inventario: Callable
## Devuelve si hay algo que se perdería al volver al inicio.
var intento_activo: Callable
## Devuelve el aviso de lo que se pierde al volver al inicio (opcional).
var texto_confirmar: Callable
## Devuelve si hay una partida guardada que se pueda continuar (opcional).
var hay_partida: Callable
var pantalla := ""
var botones: Array[Button] = []
var _raiz := "inicio"
var _lienzo := Control.new()
var _fondo: TextureRect
var _fondo_siguiente: TextureRect
var _sombra_portada: TextureRect
var _tempo_portada: Timer
var _fundido_portada: Tween
var _indice_portada := 0
var _velo := ColorRect.new()
var _panel := Panel.new()
var _contenido := VBoxContainer.new()

func _ready() -> void:
	name = "MenuCasino"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_lienzo)
	_lienzo.size = BASE
	_lienzo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var negro := ColorRect.new()
	negro.color = Color("0a1915")
	negro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(negro)
	move_child(negro, 0)
	_fondo = _capa_portada()
	_fondo.texture = PORTADAS[0]
	_fondo_siguiente = _capa_portada()
	_fondo_siguiente.hide()
	_sombra_portada = _capa_portada()
	_sombra_portada.stretch_mode = TextureRect.STRETCH_SCALE
	var degradado := Gradient.new()
	degradado.offsets = PackedFloat32Array([0.0, 0.34, 0.57, 1.0])
	degradado.colors = PackedColorArray([Color(0.01, 0.02, 0.018, 0.78), Color(0.01, 0.02, 0.018, 0.57), Color(0.01, 0.02, 0.018, 0.08), Color.TRANSPARENT])
	var sombra := GradientTexture2D.new()
	sombra.gradient = degradado
	sombra.width = 256
	sombra.height = 1
	_sombra_portada.texture = sombra
	_tempo_portada = Timer.new()
	_tempo_portada.wait_time = INTERVALO_PORTADA
	_tempo_portada.timeout.connect(_rotar_portada)
	add_child(_tempo_portada)
	_velo.size = BASE
	_velo.color = Color(0.015, 0.035, 0.026, 0.72)
	_velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lienzo.add_child(_velo)
	_panel.add_theme_stylebox_override("panel", Libro.caja(Color(0.06, 0.145, 0.12, 0.97), Libro.ORO))
	_lienzo.add_child(_panel)
	_contenido.add_theme_constant_override("separation", 10)
	_panel.add_child(_contenido)
	# Si una etiqueta o un botón cambia de tamaño después de abrir, el marco vuelve a medirse.
	_contenido.minimum_size_changed.connect(_ajustar_marco)
	resized.connect(_adaptar)
	_adaptar()
	hide()

func _adaptar() -> void:
	var escala := minf(size.x / BASE.x, size.y / BASE.y)
	_lienzo.scale = Vector2.ONE * escala
	_lienzo.position = (size - BASE * escala) * 0.5

## Abre una pantalla: "inicio" o "pausa" son raíces; las demás vuelven a la raíz con Esc.
func abrir(nombre: String) -> void:
	if nombre in ["inicio", "pausa"]:
		_raiz = nombre
	pantalla = nombre
	show()
	var en_inicio := _raiz == "inicio"
	var portada := nombre == "inicio"
	_detener_portada()
	_fondo.visible = en_inicio
	_sombra_portada.visible = portada
	_velo.visible = not portada
	if portada and not AjustesJuego.movimiento_reducido():
		_tempo_portada.start()
	_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new() if portada else Libro.caja(Color(0.06, 0.145, 0.12, 0.97), Libro.ORO))
	negro_visible(en_inicio)
	for hijo in _contenido.get_children():
		_contenido.remove_child(hijo)
		hijo.queue_free()
	botones.clear()
	match nombre:
		"inicio":
			_marco(Rect2(70, 92, 540, 612))
			var titulo := Libro.rotulo("La Última\nMesa", 80, Libro.PAPEL, true)
			titulo.add_theme_constant_override("line_spacing", -12)
			_contenido.add_child(titulo)
			var filete := ColorRect.new()
			filete.color = Libro.ORO.darkened(0.2)
			filete.custom_minimum_size = Vector2(94, 1)
			filete.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			filete.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_contenido.add_child(filete)
			_separador()
			if hay_partida.is_valid() and hay_partida.call():
				_boton("Continuar", continuar.emit)
				_boton("Nueva partida", abrir.bind("confirmar_nueva"))
			else:
				_boton("Entrar al casino", entrar.emit)
			_boton("Cómo jugar", abrir.bind("como_jugar"))
			_boton("Opciones", abrir.bind("opciones"))
			_boton("Créditos", abrir.bind("creditos"))
			_boton("Salir", salir.emit)
		"pausa":
			_marco(Rect2(470, 200, 500, 410))
			_titulo("Pausa", 44)
			_separador()
			_boton("Reanudar", reanudar.emit)
			_boton("Inventario", abrir.bind("inventario"))
			_boton("Cómo jugar", abrir.bind("como_jugar"))
			_boton("Opciones", abrir.bind("opciones"))
			_boton("Volver al inicio", _pedir_inicio)
		"opciones":
			_marco(Rect2(200, 150, 1040, 500))
			_titulo("Opciones", 40)
			var opciones := PanelOpciones.new()
			_contenido.add_child(opciones)
			opciones.construir(audio)
			opciones.movimiento_cambiado.connect(movimiento_cambiado.emit)
			opciones.lectura_cambiada.connect(lectura_cambiada.emit)
			_separador()
			_boton("Volver", abrir.bind(_raiz))
			opciones.movimiento.grab_focus()
		"creditos":
			_marco(Rect2(370, 150, 700, 500))
			_titulo("Créditos", 40)
			_nota("La Última Mesa · Desarrollo de Videojuegos · ESPE")
			_separador()
			for persona: Array in CREDITOS:
				_contenido.add_child(Libro.rotulo(persona[0], 30, Libro.PAPEL, true))
				_contenido.add_child(Libro.rotulo(persona[1], 17, MUTED))
			_separador()
			_nota("Hecho con Godot 4.7 y GUT. Letras: Cormorant Garamond y DM Sans.")
			_boton("Volver", abrir.bind(_raiz))
		"como_jugar":
			_marco(Rect2(300, 144, 840, 510))
			_titulo("Cómo jugar", 40)
			for fila: Array in GUIA_RAPIDA:
				_contenido.add_child(Libro.rotulo(fila[0], 22, Libro.ORO, true))
				_texto(fila[1], false)
			_separador()
			_nota("I · Pertenencias     H · Reglas de la mesa     V · Sonido     Esc · Pausa")
			_boton("Volver", abrir.bind(_raiz))
		"inventario":
			var datos: Array = texto_inventario.call() if texto_inventario.is_valid() else ["Tus pertenencias", ""]
			_marco(Rect2(370, 180, 700, 450))
			_titulo(str(datos[0]), 40)
			_texto(str(datos[1]))
			if intento_activo.is_valid() and intento_activo.call():
				_boton("Ver baraja", ver_baraja.emit)
			_boton("Volver", abrir.bind(_raiz))
		"confirmar":
			_marco(Rect2(420, 240, 600, 330))
			_titulo("¿Volver al inicio?", 38)
			_texto(str(texto_confirmar.call()) if texto_confirmar.is_valid() else "Se perderá el intento actual: la baraja, las fichas y los sellos.")
			_boton("Seguir jugando", abrir.bind("pausa"))
			_boton("Volver al inicio", volver_al_inicio.emit)
		"confirmar_nueva":
			_marco(Rect2(420, 240, 600, 330))
			_titulo("¿Empezar de nuevo?", 38)
			_texto("Se borrará la partida guardada: la baraja, las fichas y los sellos.")
			_boton("Cancelar", abrir.bind("inicio"))
			_boton("Empezar de nuevo", entrar.emit)
	_ajustar_marco()

func _capa_portada() -> TextureRect:
	var capa := TextureRect.new()
	capa.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	capa.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	capa.size = BASE
	capa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lienzo.add_child(capa)
	return capa

func _rotar_portada() -> void:
	if _tempo_portada.is_stopped() or not visible:
		return
	var siguiente := (_indice_portada + 1) % PORTADAS.size()
	_fondo_siguiente.texture = PORTADAS[siguiente]
	_fondo_siguiente.modulate.a = 0.0
	_fondo_siguiente.show()
	_fundido_portada = create_tween()
	_fundido_portada.tween_property(_fondo_siguiente, "modulate:a", 1.0, FUNDIDO_PORTADA)
	_fundido_portada.tween_callback(func() -> void:
		_indice_portada = siguiente
		_fondo.texture = _fondo_siguiente.texture
		_fondo_siguiente.hide())

func _detener_portada() -> void:
	_tempo_portada.stop()
	if _fundido_portada != null and _fundido_portada.is_valid():
		_fundido_portada.kill()
	_fondo_siguiente.hide()

func negro_visible(visible_negro: bool) -> void:
	get_child(0).visible = visible_negro

func cerrar() -> void:
	_detener_portada()
	pantalla = ""
	hide()

func _pedir_inicio() -> void:
	if intento_activo.is_valid() and intento_activo.call():
		abrir("confirmar")
	else:
		volver_al_inicio.emit()

func _marco(rect: Rect2) -> void:
	_panel.position = rect.position
	_panel.size = rect.size
	_contenido.position = Vector2(40, 32)
	_contenido.size = Vector2(rect.size.x - 80, rect.size.y - 64)

## El marco crece hacia arriba si el contenido no cabe (p. ej. el inicio con «Continuar» y
## «Nueva partida» suma un botón), sin cambiar su borde inferior ni salirse de la pantalla.
func _ajustar_marco() -> void:
	var necesario := _contenido.get_combined_minimum_size().y + 64
	if necesario <= _panel.size.y:
		return
	var inferior := _panel.position.y + _panel.size.y
	_panel.size.y = minf(necesario, BASE.y - 40)
	_panel.position.y = maxf(20, inferior - _panel.size.y)
	_contenido.size.y = _panel.size.y - 64

func _titulo(texto: String, puntos: int) -> void:
	_contenido.add_child(Libro.rotulo(texto, puntos, Libro.PAPEL, true))

func _nota(texto: String) -> void:
	_contenido.add_child(Libro.rotulo(texto, 17, MUTED))

func _texto(texto: String, expandir := true) -> void:
	var etiqueta := Libro.rotulo(texto, 18, Libro.PAPEL)
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta.custom_minimum_size.x = _contenido.size.x
	if expandir:
		etiqueta.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_contenido.add_child(etiqueta)

func _separador() -> void:
	var espacio := Control.new()
	espacio.custom_minimum_size.y = 8
	_contenido.add_child(espacio)

func _boton(texto: String, accion: Callable) -> void:
	var boton := Button.new()
	boton.text = texto
	boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
	boton.custom_minimum_size.y = 46
	boton.add_theme_font_override("font", Libro.SANS)
	boton.add_theme_font_size_override("font_size", 19)
	boton.add_theme_color_override("font_color", Libro.PAPEL)
	boton.add_theme_stylebox_override("normal", Libro.caja(Color("19392f"), Color("645c44")))
	boton.add_theme_stylebox_override("hover", Libro.caja(Color("2c493b"), Libro.ORO))
	boton.add_theme_stylebox_override("focus", Libro.caja(Color("2c493b"), Libro.PAPEL))
	if pantalla == "inicio":
		boton.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		boton.custom_minimum_size = Vector2(304, 42)
		boton.add_theme_stylebox_override("normal", Libro.caja(Color(0.05, 0.085, 0.07, 0.78), Color(0.62, 0.52, 0.36, 0.55)))
		if botones.is_empty():
			boton.add_theme_color_override("font_color", Color("17211a"))
			boton.add_theme_color_override("font_focus_color", Color("17211a"))
			boton.add_theme_color_override("font_hover_color", Color("17211a"))
			boton.add_theme_stylebox_override("normal", Libro.caja(Color("dcc391"), Libro.ORO))
			boton.add_theme_stylebox_override("hover", Libro.caja(Libro.PAPEL, Libro.ORO))
			boton.add_theme_stylebox_override("focus", Libro.caja(Color("edd8ad"), Libro.PAPEL))
	boton.pressed.connect(accion)
	_contenido.add_child(boton)
	botones.append(boton)
	if botones.size() == 1 and pantalla != "opciones":
		boton.grab_focus()

## Esc: desde una subpantalla vuelve a la raíz; desde la pausa reanuda; en el inicio, nada.
func _unhandled_key_input(evento: InputEvent) -> void:
	if not visible or not evento is InputEventKey or not evento.pressed or evento.echo:
		return
	if evento.keycode == KEY_ESCAPE:
		if pantalla == "pausa":
			reanudar.emit()
		elif pantalla == "confirmar":
			abrir("pausa")
		elif pantalla != "inicio":
			abrir(_raiz)
	get_viewport().set_input_as_handled()
