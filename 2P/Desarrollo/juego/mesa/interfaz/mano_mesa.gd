extends Control
## Conserva las cartas visuales por identidad y administra el desplazamiento de la mano.

const Carta := preload("res://cartas/carta.tscn")
const Piezas := preload("res://mesa/piezas_mesa.gd")

signal carta_activada(datos: Dictionary, id: String)
signal carta_creada(carta: Control)

var scroll := ScrollContainer.new()
var fila := HBoxContainer.new()
var _vacio := Control.new()
## Objetivo de la mesa dentro del tapete vacío (I6-04): meta, umbral y campanadas.
var objetivo: Label
var _ultima_carta := ""
var _revision := 0
var _dialogo_abierto: Callable
## Alto máximo de las cartas; la mesa lo fija para que la mano quepa dentro del tapete.
var alto_carta := 286.0
## Proporción de la carta (ancho / alto) y número de cartas que siempre se ven a la vez.
const PROPORCION := 0.7
const VISIBLES := 5
## Mano resuelta: ya no hay decisiones, así que todas las cartas se ven a la vez (auditoría F3).
var _completa := false

func configurar(dialogo_abierto: Callable) -> void:
	_dialogo_abierto = dialogo_abierto

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll.name = "CartasScroll"
	scroll.position = Vector2(405, 235)
	scroll.size = Vector2(718, 325)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	_estilizar_barra(scroll.get_h_scroll_bar())
	var centro := CenterContainer.new()
	centro.custom_minimum_size = Vector2(718, 311)
	centro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(centro)
	fila.name = "Mano"
	fila.add_theme_constant_override("separation", 16)
	centro.add_child(fila)
	_vacio.position = Vector2(432, 310)
	_vacio.size = Vector2(665, 150)
	add_child(_vacio)
	var titulo := Piezas.etiqueta(_vacio, "La mesa te espera", Rect2(0, 0, 665, 50), 34, Piezas.ORO, true)
	titulo.name = "Titulo"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objetivo = Piezas.etiqueta(_vacio, "", Rect2(0, 58, 665, 64), 19, Piezas.MARFIL)
	objetivo.name = "Objetivo"
	objetivo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objetivo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func presentar(cartas: Array, llaves: Array, movimiento_reducido: bool, completa := false) -> void:
	_revision += 1
	_completa = completa
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED if completa else ScrollContainer.SCROLL_MODE_AUTO
	if completa:
		scroll.scroll_horizontal = 0
	var hay_dialogo: bool = _dialogo_abierto.call()
	var existentes: Dictionary = {}
	for nodo in fila.get_children():
		existentes[str(nodo.get_meta("carta_id", ""))] = nodo
	_vacio.visible = cartas.is_empty()
	var medida := medida_carta(cartas.size())
	for indice in range(cartas.size()):
		var datos: Dictionary = cartas[indice]
		var id := str(datos.get("id", "posicion-%s" % indice))
		var nueva := not existentes.has(id)
		var carta = Carta.instantiate() if nueva else existentes[id]
		existentes.erase(id)
		if nueva:
			carta.name = "Carta_%s" % indice
			carta.set_meta("carta_id", id)
			fila.add_child(carta)
			carta.ampliacion_solicitada.connect(carta_activada.emit.bind(id))
		carta.custom_minimum_size = medida
		fila.move_child(carta, indice)
		carta.establecer_movimiento_reducido(movimiento_reducido)
		carta.presentar(datos)
		carta.establecer_devolucion_disponible(llaves.has(id))
		if nueva:
			if not hay_dialogo:
				carta.animar_entrada(minf(indice * 0.045, 0.09))
			carta_creada.emit(carta)
	for nodo in existentes.values():
		fila.remove_child(nodo)
		nodo.queue_free()
	var ultima := str(cartas.back().get("id", "")) if not cartas.is_empty() else ""
	if cartas.size() >= 6 and ultima != _ultima_carta and not hay_dialogo and not completa:
		_desplazar_al_final(_revision)
	_ultima_carta = ultima

func _desplazar_al_final(revision: int) -> void:
	# Los Containers necesitan ordenar sus hijos antes de conocer el rango final.
	await get_tree().process_frame
	await get_tree().process_frame
	if revision == _revision and not _dialogo_abierto.call():
		scroll.scroll_horizontal = ceili(scroll.get_h_scroll_bar().max_value)

## Encaja la mano dentro de un rectángulo del lienzo, conservando el desplazamiento horizontal.
func colocar(zona: Rect2, alto: float) -> void:
	alto_carta = alto
	scroll.position = zona.position
	scroll.size = zona.size
	scroll.get_child(0).custom_minimum_size = Vector2(zona.size.x, alto + 10)
	_vacio.position = zona.position + Vector2(20, zona.size.y * 0.5 - 62)
	_vacio.size = Vector2(zona.size.x - 40, 124)
	var medida := medida_carta(fila.get_child_count())
	for carta in fila.get_children():
		carta.custom_minimum_size = medida

## Tamaño de cada carta para una mano de `cantidad` cartas, con su proporción. Hasta tres van a
## tamaño completo; con cuatro o cinco se reducen para que toda la mano se vea sin desplazarse
## (Mano larga se decide mirando las cinco). Desde la sexta conservan el tamaño de cinco y la
## mano se desplaza en horizontal hasta la última carta robada. Una mano resuelta se encoge
## hasta que caben todas: es el resultado que se acaba de puntuar.
func medida_carta(cantidad: int) -> Vector2:
	var completo := floorf(alto_carta * PROPORCION)
	var separacion := float(fila.get_theme_constant("separation"))
	var ajuste := maxi(cantidad, 1) if _completa else clampi(cantidad, 1, VISIBLES)
	var ancho := minf(completo, floorf((scroll.size.x - separacion * (ajuste - 1)) / ajuste))
	return Vector2(ancho, minf(alto_carta, floorf(ancho / PROPORCION)))

## Barra fina de latón en lugar del gris por defecto de Godot.
func _estilizar_barra(barra: HScrollBar) -> void:
	var carril := StyleBoxFlat.new()
	carril.bg_color = Color(0.03, 0.08, 0.06, 0.55)
	carril.set_corner_radius_all(3)
	carril.content_margin_top = 3
	carril.content_margin_bottom = 3
	var asa := StyleBoxFlat.new()
	asa.bg_color = Color(Piezas.ORO, 0.75)
	asa.set_corner_radius_all(3)
	var asa_activa := asa.duplicate()
	asa_activa.bg_color = Piezas.ORO
	barra.add_theme_stylebox_override("scroll", carril)
	barra.add_theme_stylebox_override("scroll_focus", carril)
	barra.add_theme_stylebox_override("grabber", asa)
	barra.add_theme_stylebox_override("grabber_highlight", asa_activa)
	barra.add_theme_stylebox_override("grabber_pressed", asa_activa)

func revelar(indice: int, datos: Dictionary) -> Dictionary:
	fila.get_child(indice).presentar(datos)
	var suma := 0
	var ocultas := 0
	for carta in fila.get_children():
		if carta._vista.get("oculta", false):
			ocultas += 1
		else:
			suma += int(carta._vista.get("valor_efectivo", 0))
	return {"suma": suma, "ocultas": ocultas}

func establecer_movimiento_reducido(reducido: bool) -> void:
	for carta in fila.get_children():
		carta.establecer_movimiento_reducido(reducido)
