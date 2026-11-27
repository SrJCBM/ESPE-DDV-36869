extends Control
## Presentación compartida de las conversaciones (I4-06, ampliada en I5-10).
##
## - ADV: retrato, cuadro inferior con nombre e intervención y respuestas encima del cuadro.
## - NVL: narración sin placa en la franja inferior, un párrafo por clic, con la ilustración
##   a la vista (como en Fate).
## - Tarjeta: un título centrado (capítulos del prólogo).
## Cada intervención puede cambiar el fondo; un fondo sin archivo se dibuja como ilustración
## pendiente con su id y su descripción, hasta que se guarde el archivo.
## Escenario: los personajes entran y salen en tres posiciones ("escena" en la intervención);
## el que habla queda iluminado, los demás atenuados, y su cara aparece en el cuadro.
## Efectos de cinemática: fundido cruzado entre fondos, movimiento lento sobre una CG
## ("movimiento": "acercar" o "desplazar" en el fondo), "efecto": "temblor", "temblor_fuerte"
## o "destello" en una intervención, y viñeta en los bordes. Con movimiento reducido, nada se
## mueve ni destella. Clic, Enter, Espacio o E avanzan; si la línea se está
## escribiendo, la primera pulsación la completa. Esc cierra sin aplicar nada, salvo en una
## historia (`permitir_saltar`), que solo se deja con «Saltar». Con movimiento reducido el
## texto aparece completo.
## La barra del cuadro ofrece Historial (también con la rueda hacia arriba), Auto y Saltar,
## que adelanta líneas hasta la próxima elección (también manteniendo Ctrl).
## Los ajustes de lectura (velocidad, espera del modo automático, tamaño del texto y opacidad
## del cuadro) llegan con `configurar`.
## No conoce el juego: las condiciones las evalúa `evaluar`, las solicitudes se emiten,
## `describir` (opcional) completa una opción con {"icono", "detalle"} y `formatear`
## (opcional) sustituye marcas como {nombre} en textos y opciones.

signal solicitud(id: String)
signal sonido(id: String)
signal cerrado
## «Saltar» en una historia: quien la abrió decide qué valores toman sus elecciones.
signal saltado

const Libro := preload("res://casino/interfaz/libro.gd")
const BASE := Vector2(1440, 810)
const VELOCIDAD := 55.0 ## Caracteres por segundo, por defecto.
const HISTORIAL_MAXIMO := 150
const PASO_SALTO := 0.06 ## Segundos entre líneas al saltar.
const CAJA := Rect2(140, 600, 1160, 180)
## Cara pequeña en el cuadro: termina 18 px por encima de la barra de Historial, Auto y Saltar.
const CARA := 88.0
const CARA_ARRIBA := 34.0
const RETRATO := Rect2(150, 112, 376, 488)
## Narración NVL: franja inferior, sobre la ilustración.
const PAGINA := Rect2(210, 612, 1020, 150)
const FUNDIDO_FONDO := 0.6
const LADOS := {"izquierda": 330.0, "centro": 720.0, "derecha": 1110.0}
const ALTO_FIGURA := 510.0
const ATENUADO := Color(0.48, 0.48, 0.48)
const MUTED := Color("b9ad91")

var conversacion: Conversacion
var evaluar: Callable
var describir: Callable
var formatear: Callable
var reducido := false
## Historia (prólogo): Esc no cierra y aparece «Saltar».
var permitir_saltar := false
var actual := ""
var modo := "adv"
## Ajustes de lectura (ver `configurar`).
var velocidad := VELOCIDAD
var espera_auto := 1.5
var escala_texto := 1.0
var opacidad := 0.96
## Modo automático: avanza solo al terminar cada línea sin respuestas.
var auto := false
## Adelanta líneas hasta la próxima elección.
var saltando := false
## [{"nombre", "texto"}] de las líneas mostradas, la más reciente al final.
var historial: Array[Dictionary] = []
var barra: HBoxContainer
var boton_historial: Button
var boton_auto: Button
var boton_adelantar: Button
var panel_historial: Panel
var _lista_historial: VBoxContainer
var _desplazamiento: ScrollContainer
var _espera := 0.0
var retrato: TextureRect
var nombre: Label
var texto: Label
var texto_nvl: Label
var indicacion: Label
var respuestas: VBoxContainer
var botones: Array[Button] = []
var fondo: TextureRect
var fondo_previo: TextureRect
var pendiente: Panel
## Capa que se sacude con los efectos: fondos, ilustración pendiente y viñeta.
var escena: Control
var vineta: TextureRect
var destello: ColorRect
var franja: TextureRect
## Personajes en escena: id → TextureRect.
var presentes := {}
var escenario: Control
var cara: TextureRect
var _movimiento: Tween
var _sacudida: Tween
var boton_saltar: Button
## Id del fondo visible, o vacío.
var fondo_actual := ""
var _sombra: ColorRect
var _marco_nvl: Panel
var _caja: Panel
var _placa: Panel
var _anexo: Control
var _opciones: Array = []
var _escritos := 0.0
var _desde := 0
var _texto_pendiente: Label

func _ready() -> void:
	name = "DialogoNovela"
	size = BASE
	mouse_filter = Control.MOUSE_FILTER_STOP
	escena = Control.new()
	escena.size = BASE
	escena.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(escena)
	fondo_previo = _capa_fondo()
	fondo = _capa_fondo()
	pendiente = Panel.new()
	pendiente.size = BASE
	pendiente.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pendiente.add_theme_stylebox_override("panel", _estilo_pendiente())
	pendiente.hide()
	escena.add_child(pendiente)
	_texto_pendiente = Libro.rotulo("", 16, MUTED)
	_texto_pendiente.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_texto_pendiente.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_texto_pendiente.position = Vector2(220, 40)
	_texto_pendiente.size = Vector2(1000, 60)
	pendiente.add_child(_texto_pendiente)
	vineta = TextureRect.new()
	vineta.texture = _textura_vineta()
	vineta.size = BASE
	vineta.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vineta.stretch_mode = TextureRect.STRETCH_SCALE
	vineta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vineta.hide()
	escena.add_child(vineta)
	destello = ColorRect.new()
	destello.color = Color(1, 0.97, 0.9, 0)
	destello.size = BASE
	destello.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(destello)
	_sombra = ColorRect.new()
	_sombra.color = Color(0.01, 0.03, 0.02, 0.45)
	_sombra.size = BASE
	_sombra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sombra)
	franja = TextureRect.new()
	franja.texture = _textura_franja()
	franja.position = Vector2(0, BASE.y - 300)
	franja.size = Vector2(BASE.x, 300)
	franja.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	franja.stretch_mode = TextureRect.STRETCH_SCALE
	franja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	franja.hide()
	add_child(franja)
	_marco_nvl = Panel.new()
	_marco_nvl.position = Vector2(20, 20)
	_marco_nvl.size = BASE - Vector2(40, 40)
	_marco_nvl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var borde := StyleBoxFlat.new()
	borde.draw_center = false
	borde.border_color = Color(0.83, 0.71, 0.47, 0.45)
	borde.set_border_width_all(1)
	_marco_nvl.add_theme_stylebox_override("panel", borde)
	_marco_nvl.hide()
	add_child(_marco_nvl)
	escenario = Control.new()
	escenario.size = BASE
	escenario.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(escenario)
	retrato = TextureRect.new()
	retrato.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	retrato.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	retrato.position = RETRATO.position
	retrato.size = RETRATO.size
	retrato.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(retrato)
	_caja = Panel.new()
	_caja.position = CAJA.position
	_caja.size = CAJA.size
	_caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caja.add_theme_stylebox_override("panel", Libro.caja(Color(0.025, 0.065, 0.052, opacidad), Color("92754c")))
	add_child(_caja)
	_placa = Panel.new()
	_placa.position = CAJA.position + Vector2(30, -24)
	_placa.size = Vector2(280, 46)
	_placa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_placa.add_theme_stylebox_override("panel", Libro.caja(Color("13251e"), Color("a88b5d")))
	add_child(_placa)
	var campana := TextureRect.new()
	campana.texture = preload("res://casino/dialogos/arte/campana_adv.webp")
	campana.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	campana.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	campana.position = Vector2(13, 11)
	campana.size = Vector2(24, 24)
	campana.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_placa.add_child(campana)
	nombre = Libro.rotulo("", 27, Libro.PAPEL, true)
	nombre.position = _placa.position + Vector2(48, 4)
	nombre.size = Vector2(219, 38)
	add_child(nombre)
	cara = TextureRect.new()
	cara.position = CAJA.position + Vector2(30, CARA_ARRIBA)
	cara.size = Vector2(CARA, CARA)
	cara.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cara.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cara.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cara.hide()
	add_child(cara)
	texto = Libro.rotulo("", 22, Libro.PAPEL)
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	texto.position = CAJA.position + Vector2(36, 38)
	texto.size = Vector2(CAJA.size.x - 72, 104)
	add_child(texto)
	texto_nvl = Libro.rotulo("", 24, Libro.PAPEL)
	texto_nvl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto_nvl.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	texto_nvl.position = PAGINA.position
	texto_nvl.size = PAGINA.size
	texto_nvl.add_theme_constant_override("line_spacing", 6)
	texto_nvl.hide()
	add_child(texto_nvl)
	indicacion = Libro.rotulo("%s · continuar" % Acciones.tecla(Acciones.INTERACTUAR), 16, MUTED)
	indicacion.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	indicacion.position = CAJA.end - Vector2(236, 34)
	indicacion.size = Vector2(210, 22)
	add_child(indicacion)
	respuestas = VBoxContainer.new()
	respuestas.add_theme_constant_override("separation", 8)
	respuestas.position = Vector2(CAJA.end.x - 520, CAJA.position.y - 20)
	respuestas.size = Vector2(520, 0)
	add_child(respuestas)
	boton_saltar = Button.new()
	boton_saltar.text = "Saltar ▸"
	boton_saltar.focus_mode = Control.FOCUS_NONE
	boton_saltar.position = Vector2(BASE.x - 170, 24)
	boton_saltar.size = Vector2(130, 40)
	boton_saltar.add_theme_font_override("font", Libro.SANS)
	boton_saltar.add_theme_font_size_override("font_size", 16)
	boton_saltar.add_theme_color_override("font_color", MUTED)
	boton_saltar.add_theme_stylebox_override("normal", Libro.caja(Color(0.04, 0.11, 0.09, 0.8), Color("645c44")))
	boton_saltar.add_theme_stylebox_override("hover", Libro.caja(Color("2c493b"), Libro.ORO))
	boton_saltar.pressed.connect(saltar)
	boton_saltar.hide()
	add_child(boton_saltar)
	barra = HBoxContainer.new()
	barra.add_theme_constant_override("separation", 6)
	add_child(barra)
	boton_historial = _boton_barra("Historial", abrir_historial)
	boton_auto = _boton_barra("Auto", alternar_auto)
	boton_auto.toggle_mode = true
	boton_adelantar = _boton_barra("Saltar", alternar_salto)
	boton_adelantar.toggle_mode = true
	_crear_historial()
	_aplicar_modo()
	hide()

func _capa_fondo() -> TextureRect:
	var capa := TextureRect.new()
	capa.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	capa.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	capa.size = BASE
	capa.pivot_offset = BASE * 0.5
	capa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.hide()
	escena.add_child(capa)
	return capa

## Bordes oscuros de las cinemáticas.
static func _textura_vineta() -> GradientTexture2D:
	var gradiente := Gradient.new()
	gradiente.set_color(0, Color(0, 0, 0, 0))
	gradiente.set_color(1, Color(0.0, 0.01, 0.005, 0.78))
	gradiente.add_point(0.55, Color(0, 0, 0, 0))
	var textura := GradientTexture2D.new()
	textura.gradient = gradiente
	textura.fill = GradientTexture2D.FILL_RADIAL
	textura.fill_from = Vector2(0.5, 0.5)
	textura.fill_to = Vector2(1.05, 1.05)
	textura.width = 256
	textura.height = 144
	return textura

## Degradado bajo la narración, para leer sobre cualquier ilustración.
static func _textura_franja() -> GradientTexture2D:
	var gradiente := Gradient.new()
	gradiente.set_color(0, Color(0.01, 0.03, 0.02, 0))
	gradiente.set_color(1, Color(0.01, 0.03, 0.02, 0.92))
	gradiente.add_point(0.45, Color(0.01, 0.03, 0.02, 0.7))
	var textura := GradientTexture2D.new()
	textura.gradient = gradiente
	textura.fill_from = Vector2(0, 0)
	textura.fill_to = Vector2(0, 1)
	textura.width = 4
	textura.height = 128
	return textura

func _boton_barra(texto_boton: String, accion: Callable) -> Button:
	var boton := Button.new()
	boton.text = texto_boton
	boton.focus_mode = Control.FOCUS_NONE
	boton.flat = true
	boton.add_theme_font_override("font", Libro.SANS)
	boton.add_theme_font_size_override("font_size", Tipografia.MINIMA)
	boton.add_theme_color_override("font_color", MUTED)
	boton.add_theme_color_override("font_hover_color", Libro.PAPEL)
	boton.add_theme_color_override("font_pressed_color", Libro.ORO)
	boton.add_theme_color_override("font_hover_pressed_color", Libro.ORO)
	boton.pressed.connect(accion)
	barra.add_child(boton)
	return boton

func _crear_historial() -> void:
	panel_historial = Panel.new()
	panel_historial.position = Vector2(200, 70)
	panel_historial.size = Vector2(BASE.x - 400, BASE.y - 140)
	panel_historial.add_theme_stylebox_override("panel", Libro.caja(Color(0.03, 0.08, 0.065, 0.98), Libro.ORO))
	panel_historial.hide()
	add_child(panel_historial)
	var titulo := Libro.rotulo("Historial", 30, Libro.PAPEL, true)
	titulo.position = Vector2(36, 18)
	panel_historial.add_child(titulo)
	var cerrar_boton := Button.new()
	cerrar_boton.text = "Cerrar"
	cerrar_boton.position = Vector2(panel_historial.size.x - 150, 22)
	cerrar_boton.size = Vector2(114, 38)
	cerrar_boton.add_theme_font_override("font", Libro.SANS)
	cerrar_boton.add_theme_stylebox_override("normal", Libro.caja(Color("19392f"), Color("645c44")))
	cerrar_boton.add_theme_stylebox_override("hover", Libro.caja(Color("2c493b"), Libro.ORO))
	cerrar_boton.pressed.connect(cerrar_historial)
	panel_historial.add_child(cerrar_boton)
	_desplazamiento = ScrollContainer.new()
	_desplazamiento.position = Vector2(36, 76)
	_desplazamiento.size = panel_historial.size - Vector2(72, 104)
	_desplazamiento.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel_historial.add_child(_desplazamiento)
	_lista_historial = VBoxContainer.new()
	_lista_historial.add_theme_constant_override("separation", 14)
	_lista_historial.custom_minimum_size.x = _desplazamiento.size.x - 20
	_desplazamiento.add_child(_lista_historial)

## Velocidad del texto (caracteres por segundo; 0 o menos, instantáneo), espera del modo
## automático en segundos, escala del texto (1.0 = normal) y opacidad del cuadro (0 a 1).
func configurar(ajustes: Dictionary) -> void:
	velocidad = float(ajustes.get("velocidad", VELOCIDAD))
	espera_auto = float(ajustes.get("espera_auto", 1.5))
	escala_texto = float(ajustes.get("escala_texto", 1.0))
	opacidad = clampf(float(ajustes.get("opacidad", 0.96)), 0.2, 1.0)
	if texto == null:
		return
	texto.add_theme_font_size_override("font_size", roundi(22 * escala_texto))
	_caja.add_theme_stylebox_override("panel", Libro.caja(Color(0.025, 0.065, 0.052, opacidad), Color("92754c")))
	_aplicar_modo()
	if visible:
		_ajustar_texto()
		if not botones.is_empty():
			_colocar_respuestas()

## Abre la conversación en la entrada que corresponda al progreso. false si no hay ninguna.
func abrir(datos: Conversacion, condicion: Callable, movimiento_reducido := false, descripcion := Callable(), barra_lectura := true) -> bool:
	conversacion = datos
	evaluar = condicion
	describir = descripcion
	reducido = movimiento_reducido
	var inicio := conversacion.inicio(evaluar)
	if inicio.is_empty():
		return false
	fondo_actual = ""
	fondo.hide()
	fondo_previo.hide()
	pendiente.hide()
	vineta.visible = permitir_saltar
	_vaciar_escenario()
	destello.color.a = 0.0
	escena.position = Vector2.ZERO
	texto_nvl.text = ""
	boton_saltar.visible = permitir_saltar
	barra.visible = barra_lectura
	auto = false
	saltando = false
	boton_auto.set_pressed_no_signal(false)
	boton_adelantar.set_pressed_no_signal(false)
	panel_historial.hide()
	show()
	_mostrar(inicio)
	return true

## Un control propio de quien abre el diálogo (por ejemplo, las cifras de una mesa), encima
## del cuadro y a la derecha de la placa. null lo quita.
func poner_anexo(control: Control) -> void:
	if is_instance_valid(_anexo):
		remove_child(_anexo)
		_anexo.queue_free()
	_anexo = control
	if control == null:
		return
	control.position = _caja.position + Vector2(340, -78)
	add_child(control)
	move_child(control, _caja.get_index())
	control.visible = modo == "adv"

func escribiendo() -> bool:
	return visible and _activa().visible_characters >= 0

func _activa() -> Label:
	return texto if modo == "adv" else texto_nvl

func _formato(cadena: String) -> String:
	return str(formatear.call(cadena)) if formatear.is_valid() else cadena

func _mostrar(id: String) -> void:
	actual = id
	var linea := conversacion.intervencion(id)
	var nuevo_modo := str(linea.get("modo", "adv"))
	_poner_fondo(str(linea.get("fondo", fondo_actual)))
	for cambio: Dictionary in linea.get("escena", []):
		_cambiar_escenario(cambio)
	modo = nuevo_modo
	_aplicar_modo()
	var frase := _formato(str(linea.get("texto", "")))
	if modo == "adv":
		var ruta := conversacion.retrato(id)
		var quien := str(linea.get("personaje", ""))
		if presentes.is_empty():
			retrato.texture = load(ruta) if not ruta.is_empty() and ResourceLoader.exists(ruta) else null
		else:
			# Con personajes en escena, el retrato grande cede su sitio a la cara en el cuadro.
			retrato.texture = null
		_encuadrar_retrato()
		# I6-08: si quien habla ya está de cuerpo entero en escena, su figura y la placa con su
		# nombre lo identifican; la cara pequeña solo aparece para quien habla fuera de escena.
		_mostrar_cara(ruta if not presentes.is_empty() and not presentes.has(quien) else "")
		if presentes.has(quien) and linea.has("expresion"):
			var nueva := conversacion.imagen(quien, str(linea.expresion))
			if ResourceLoader.exists(nueva):
				presentes[quien].texture = load(nueva)
		nombre.text = _formato(conversacion.nombre(id))
		_placa.visible = not nombre.text.is_empty()
		texto.text = frase
		_desde = 0
	else:
		retrato.texture = null
		_mostrar_cara("")
		texto_nvl.text = frase
		_desde = 0
	_ajustar_texto()
	_resaltar(str(linea.get("personaje", "")) if modo == "adv" else "")
	_opciones = conversacion.opciones(id, evaluar)
	_quitar_respuestas()
	indicacion.hide()
	_escritos = float(_desde)
	_espera = 0.0
	_activa().visible_characters = _desde
	_anotar(nombre.text if modo == "adv" else "", frase)
	if not str(linea.get("sonido", "")).is_empty():
		sonido.emit(str(linea.sonido))
	var efectos = linea.get("efecto", [])
	for efecto in (efectos if efectos is Array else [efectos]):
		aplicar_efecto(str(efecto))
	if not str(linea.get("solicitud", "")).is_empty():
		solicitud.emit(str(linea.solicitud))
	if reducido or velocidad <= 0.0:
		completar()

func _anotar(quien: String, frase: String) -> void:
	if frase.strip_edges().is_empty():
		return
	historial.append({"nombre": quien, "texto": frase})
	while historial.size() > HISTORIAL_MAXIMO:
		historial.pop_front()

## Muestra u oculta las piezas del cuadro según el modo de la intervención.
func _aplicar_modo() -> void:
	var adv := modo == "adv"
	_caja.visible = adv
	_placa.visible = adv
	nombre.visible = adv
	texto.visible = adv
	texto_nvl.visible = not adv
	if is_instance_valid(_anexo):
		_anexo.visible = adv
	franja.visible = modo == "nvl"
	_marco_nvl.visible = franja.visible
	# La narración y las tarjetas dejan ver la ilustración entera.
	if escenario != null:
		escenario.visible = adv
	_sombra.color = Color(0.01, 0.03, 0.02, 0.45 if adv else (0.12 if modo == "nvl" else 0.6))
	if modo == "tarjeta":
		texto_nvl.position = Vector2(220, 200)
		texto_nvl.size = Vector2(1000, 400)
		texto_nvl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		texto_nvl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		texto_nvl.add_theme_font_override("font", Libro.SERIF)
		texto_nvl.add_theme_font_size_override("font_size", 44)
		texto_nvl.add_theme_color_override("font_color", Libro.ORO)
	else:
		texto_nvl.position = PAGINA.position
		texto_nvl.size = PAGINA.size
		texto_nvl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		texto_nvl.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		# La narración usa la letra de época; el cuadro ADV conserva la de lectura rápida.
		texto_nvl.add_theme_font_override("font", Libro.SERIF)
		texto_nvl.add_theme_font_size_override("font_size", 28)
		texto_nvl.add_theme_color_override("font_color", Libro.PAPEL)
	indicacion.position = CAJA.end - Vector2(236, 34)
	if modo != "tarjeta":
		texto_nvl.add_theme_font_size_override("font_size", roundi(28 * escala_texto))
	if barra != null:
		barra.reset_size()
		barra.position = Vector2(CAJA.position.x + 30, CAJA.end.y - 40)

## Reserva el pie para los controles y conserva el tamaño elegido en Opciones.
func _ajustar_texto() -> void:
	if modo == "tarjeta":
		return
	var adv := modo == "adv"
	var etiqueta := _activa()
	var origen := CAJA.position.y + 38 if adv else PAGINA.position.y
	var limite := barra.position.y - 8
	var visibles := etiqueta.visible_characters
	etiqueta.visible_characters = -1
	var alto := float(etiqueta.get_line_count() * etiqueta.get_line_height())
	etiqueta.visible_characters = visibles
	var extra := maxf(0.0, alto - (limite - origen))
	etiqueta.position.y = origen - extra
	etiqueta.size.y = limite - etiqueta.position.y
	if adv:
		_caja.position.y = CAJA.position.y - extra
		_caja.size.y = CAJA.size.y + extra
		_placa.position.y = _caja.position.y - 24
		nombre.position.y = _placa.position.y + 4
		cara.position.y = _caja.position.y + CARA_ARRIBA
		retrato.position.y = _caja.position.y - retrato.size.y
		if is_instance_valid(_anexo):
			_anexo.position.y = _caja.position.y - 78
	else:
		franja.position.y = BASE.y - 300 - extra
		franja.size.y = 300 + extra

## Cambia el fondo si la intervención trae otro. Sin archivo, dibuja la ilustración pendiente.
func _poner_fondo(id: String) -> void:
	if id == fondo_actual:
		return
	fondo_actual = id
	var datos := conversacion.fondo(id) if not id.is_empty() else {}
	var ruta := str(datos.get("ruta", ""))
	var imagen: Texture2D = datos.get("textura")
	if imagen == null and not ruta.is_empty() and ResourceLoader.exists(ruta):
		imagen = load(ruta)
	var con_imagen := imagen != null
	# Fundido cruzado: la imagen anterior queda debajo mientras aparece la nueva.
	var fundir := permitir_saltar and not reducido and is_inside_tree() and (fondo.visible or pendiente.visible)
	fondo_previo.texture = fondo.texture
	fondo_previo.visible = fundir and fondo.visible
	fondo_previo.scale = fondo.scale
	fondo_previo.position = fondo.position
	_parar(_movimiento)
	fondo.scale = Vector2.ONE
	fondo.position = Vector2.ZERO
	fondo.texture = imagen
	fondo.visible = con_imagen
	pendiente.visible = not con_imagen and not id.is_empty()
	_texto_pendiente.text = "Ilustración pendiente · %s\n%s" % [id, str(datos.get("descripcion", ""))]
	if fundir:
		for capa: CanvasItem in [fondo, pendiente]:
			capa.modulate.a = 0.0
			create_tween().tween_property(capa, "modulate:a", 1.0, FUNDIDO_FONDO)
		var ocultar := create_tween()
		ocultar.tween_interval(FUNDIDO_FONDO)
		ocultar.tween_callback(fondo_previo.hide)
	else:
		fondo.modulate.a = 1.0
		pendiente.modulate.a = 1.0
	_mover_fondo(str(datos.get("movimiento", "")))

## Movimiento lento sobre una ilustración: "acercar" (zoom) o "desplazar" (paneo).
func _mover_fondo(tipo: String) -> void:
	if tipo.is_empty() or reducido or not fondo.visible or not is_inside_tree():
		return
	_movimiento = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	match tipo:
		"acercar":
			_movimiento.tween_property(fondo, "scale", Vector2.ONE * 1.1, 16.0)
		"desplazar":
			fondo.scale = Vector2.ONE * 1.08
			fondo.position.x = 50
			_movimiento.tween_property(fondo, "position:x", -50.0, 18.0)

## Efecto de una intervención: "temblor", "temblor_fuerte" o "destello".
func aplicar_efecto(efecto: String) -> void:
	if reducido or not is_inside_tree():
		return
	match efecto:
		"temblor", "temblor_fuerte":
			var fuerza := 16.0 if efecto == "temblor_fuerte" else 8.0
			_parar(_sacudida)
			_sacudida = create_tween()
			for i in range(8):
				var desvio := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * fuerza * (1.0 - i / 8.0)
				_sacudida.tween_property(escena, "position", desvio, 0.04)
			_sacudida.tween_property(escena, "position", Vector2.ZERO, 0.05)
		"destello":
			destello.color.a = 0.85
			create_tween().tween_property(destello, "color:a", 0.0, 0.55)

## Un personaje entra en una posición o sale ("todos" vacía el escenario).
func _cambiar_escenario(cambio: Dictionary) -> void:
	if cambio.has("sale"):
		var quien := str(cambio.sale)
		for id: String in (presentes.keys() if quien == "todos" else [quien]):
			_retirar(id)
		return
	var quien := str(cambio.get("entra", ""))
	var ruta := conversacion.imagen(quien, str(cambio.get("expresion", "")))
	if quien.is_empty() or not ResourceLoader.exists(ruta):
		return
	var figura: TextureRect = presentes.get(quien)
	var nueva := figura == null
	if nueva:
		figura = TextureRect.new()
		figura.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		figura.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		figura.mouse_filter = Control.MOUSE_FILTER_IGNORE
		escenario.add_child(figura)
		presentes[quien] = figura
	figura.texture = load(ruta)
	var medida := figura.texture.get_size() * (ALTO_FIGURA / figura.texture.get_height())
	figura.size = medida
	var destino := Vector2(float(LADOS.get(str(cambio.get("lado", "centro")), 720.0)) - medida.x * 0.5, CAJA.position.y + 10 - medida.y)
	if nueva and not reducido and is_inside_tree():
		figura.position = destino + Vector2(0, 24)
		figura.modulate.a = 0.0
		var entrada := create_tween().set_parallel()
		entrada.tween_property(figura, "position", destino, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		entrada.tween_property(figura, "modulate:a", 1.0, 0.35)
	else:
		figura.position = destino

func _retirar(id: String) -> void:
	var figura: TextureRect = presentes.get(id)
	if figura == null:
		return
	presentes.erase(id)
	if reducido or not is_inside_tree():
		figura.queue_free()
		return
	var salida := create_tween()
	salida.tween_property(figura, "modulate:a", 0.0, 0.3)
	salida.tween_callback(figura.queue_free)

func _vaciar_escenario() -> void:
	for figura in presentes.values():
		figura.queue_free()
	presentes.clear()

## Ilumina al que habla y atenúa al resto; con narración, todos quedan a media luz.
func _resaltar(quien: String) -> void:
	for id: String in presentes:
		var color := Color.WHITE if id == quien else (Color(0.75, 0.75, 0.75) if quien.is_empty() else ATENUADO)
		presentes[id].self_modulate = color

## Cara del que habla en el cuadro (la parte alta de su imagen), o nada.
func _mostrar_cara(ruta: String) -> void:
	var visible_cara := not ruta.is_empty() and ResourceLoader.exists(ruta)
	cara.visible = visible_cara and modo == "adv"
	texto.position.x = CAJA.position.x + (150 if cara.visible else 36)
	texto.size.x = CAJA.size.x - (186 if cara.visible else 72)
	if not visible_cara:
		return
	var imagen: Texture2D = load(ruta)
	var recorte := AtlasTexture.new()
	recorte.atlas = imagen
	var lado := imagen.get_width() * 0.5
	recorte.region = Rect2((imagen.get_width() - lado) * 0.5, imagen.get_height() * 0.06, lado, lado)
	cara.texture = recorte

static func _parar(animacion: Tween) -> void:
	if animacion != null and animacion.is_valid():
		animacion.kill()

static func _estilo_pendiente() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("06100d")
	estilo.border_color = Color(0.83, 0.71, 0.47, 0.35)
	estilo.set_border_width_all(2)
	estilo.set_expand_margin_all(-18)
	return estilo

## El retrato recortado conserva su proporción y se apoya sobre el cuadro de texto.
func _encuadrar_retrato() -> void:
	if retrato.texture == null:
		return
	var proporcion := retrato.texture.get_size()
	var escala := minf(RETRATO.size.x / proporcion.x, RETRATO.size.y / proporcion.y)
	var medida := proporcion * escala
	retrato.size = medida
	retrato.position = Vector2(RETRATO.get_center().x - medida.x * 0.5, RETRATO.end.y - medida.y)

## Muestra la línea entera y, después, sus respuestas o la indicación para seguir.
func completar() -> void:
	_activa().visible_characters = -1
	# Con movimiento reducido la línea ya se completó al mostrarse: no se repiten las respuestas.
	_quitar_respuestas()
	if _opciones.is_empty():
		var tecla := Acciones.tecla(Acciones.INTERACTUAR)
		indicacion.text = "%s · %s" % [tecla, "continuar" if not conversacion.siguiente(actual, evaluar).is_empty() else "cerrar"]
		indicacion.show()
		return
	var junto_a_personajes := not presentes.is_empty()
	var ancho := 420.0 if junto_a_personajes else 520.0
	for indice in _opciones.size():
		var boton := Button.new()
		boton.text = _formato(str(_opciones[indice].get("texto", "")))
		boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
		boton.custom_minimum_size = Vector2(ancho, 44)
		boton.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var extra: Dictionary = describir.call(_opciones[indice]) if describir.is_valid() else {}
		if not str(extra.get("detalle", "")).is_empty():
			# Nombre y efecto en una línea cada uno, con el icono del objeto a la izquierda.
			boton.text += "\n" + str(extra.detalle)
			boton.custom_minimum_size.y = 66
		if ResourceLoader.exists(str(extra.get("icono", ""))):
			boton.icon = load(str(extra.icono))
			boton.expand_icon = true
			boton.add_theme_constant_override("icon_max_width", 50)
			boton.add_theme_constant_override("h_separation", 12)
		boton.add_theme_font_override("font", Libro.SANS)
		boton.add_theme_font_size_override("font_size", 18)
		boton.add_theme_color_override("font_color", Libro.PAPEL)
		boton.add_theme_stylebox_override("normal", Libro.caja(Color("19392f"), Color("645c44")))
		boton.add_theme_stylebox_override("hover", Libro.caja(Color("2c493b"), Libro.ORO))
		boton.add_theme_stylebox_override("focus", Libro.caja(Color("2c493b"), Libro.PAPEL))
		boton.pressed.connect(elegir.bind(indice))
		respuestas.add_child(boton)
		botones.append(boton)
	respuestas.reset_size()
	_colocar_respuestas()
	respuestas.position.x = (BASE.x - ancho) * 0.5 if junto_a_personajes else CAJA.end.x - ancho
	botones[0].grab_focus()

func _colocar_respuestas() -> void:
	var tope := _caja.position.y - 34 if modo == "adv" else texto_nvl.position.y - 30
	respuestas.position.y = tope - respuestas.size.y

func _quitar_respuestas() -> void:
	for boton in botones:
		respuestas.remove_child(boton)
		boton.queue_free()
	botones.clear()

func _process(delta: float) -> void:
	if not visible or panel_historial.visible:
		return
	var adelantar := saltando or Input.is_key_pressed(KEY_CTRL)
	if adelantar:
		_espera += delta
		if not _opciones.is_empty():
			# En una elección el salto se detiene ya, con la línea completa: nunca a medias.
			if escribiendo(): completar()
			_detener_salto()
		elif _espera >= PASO_SALTO:
			_espera = 0.0
			if escribiendo(): completar()
			if _opciones.is_empty(): avanzar()
		return
	if not escribiendo():
		if auto and _opciones.is_empty():
			_espera += delta
			if _espera >= espera_auto + _activa().text.length() * 0.012:
				avanzar()
		return
	if velocidad <= 0.0:
		completar()
		return
	var etiqueta := _activa()
	_escritos += delta * velocidad
	etiqueta.visible_characters = int(_escritos)
	if etiqueta.visible_characters >= etiqueta.get_total_character_count():
		completar()

## Clic, Enter o E: completa la línea, pasa a la siguiente o cierra. Con respuestas, espera.
func avanzar() -> void:
	if escribiendo():
		completar()
	elif not _opciones.is_empty():
		return
	else:
		var destino := conversacion.siguiente(actual, evaluar)
		if destino.is_empty():
			cerrar()
		else:
			_mostrar(destino)

func elegir(indice: int) -> void:
	if indice < 0 or indice >= _opciones.size() or escribiendo():
		return
	var opcion: Dictionary = _opciones[indice]
	if not str(opcion.get("solicitud", "")).is_empty():
		solicitud.emit(str(opcion.solicitud))
	var destino := str(opcion.get("ir", ""))
	if destino.is_empty():
		cerrar()
	else:
		_mostrar(destino)

func alternar_auto() -> void:
	auto = not auto
	boton_auto.set_pressed_no_signal(auto)
	_espera = 0.0

func alternar_salto() -> void:
	saltando = not saltando
	boton_adelantar.set_pressed_no_signal(saltando)
	_espera = 0.0

func _detener_salto() -> void:
	saltando = false
	boton_adelantar.set_pressed_no_signal(false)

func abrir_historial() -> void:
	for hijo in _lista_historial.get_children():
		_lista_historial.remove_child(hijo)
		hijo.queue_free()
	for linea in historial:
		var entrada := Libro.rotulo(("%s\n%s" % [linea.nombre, linea.texto]) if not str(linea.nombre).is_empty() else str(linea.texto), roundi(18 * escala_texto), Libro.PAPEL)
		entrada.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		entrada.custom_minimum_size.x = _lista_historial.custom_minimum_size.x
		_lista_historial.add_child(entrada)
	panel_historial.show()
	_desplazar_al_final.call_deferred()

func _desplazar_al_final() -> void:
	_desplazamiento.scroll_vertical = int(_desplazamiento.get_v_scroll_bar().max_value)

func cerrar_historial() -> void:
	panel_historial.hide()

func cerrar() -> void:
	if not visible:
		return
	panel_historial.hide()
	hide()
	poner_anexo(null)
	cerrado.emit()

## Deja la historia sin terminarla. Solo con `permitir_saltar`.
func saltar() -> void:
	if not visible or not permitir_saltar:
		return
	hide()
	saltado.emit()

func _gui_input(evento: InputEvent) -> void:
	if not evento is InputEventMouseButton or not evento.pressed:
		return
	if evento.button_index == MOUSE_BUTTON_WHEEL_UP and barra.visible and not panel_historial.visible:
		abrir_historial()
		accept_event()
	elif evento.button_index == MOUSE_BUTTON_LEFT and not panel_historial.visible:
		avanzar()
		accept_event()

func _unhandled_input(evento: InputEvent) -> void:
	if not visible or not Acciones.es_pulsacion(evento):
		return
	if panel_historial.visible:
		if evento.is_action_pressed(Acciones.VOLVER) or evento.is_action_pressed(Acciones.ACEPTAR) or evento.is_action_pressed(Acciones.INTERACTUAR):
			cerrar_historial()
	elif evento.is_action_pressed(Acciones.VOLVER):
		if not permitir_saltar:
			cerrar()
	elif evento.is_action_pressed(Acciones.INTERACTUAR) or evento.is_action_pressed(Acciones.ACEPTAR):
		var foco := get_viewport().gui_get_focus_owner()
		if foco in botones and not escribiendo():
			elegir(botones.find(foco))
		else:
			avanzar()
	get_viewport().set_input_as_handled()
