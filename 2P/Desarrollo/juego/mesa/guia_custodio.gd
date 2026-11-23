extends Control
## Libro de consulta: ejemplos fijos y reglas públicas de la mesa activa, sin valores ocultos.

signal movimiento_cambiado(reducido: bool)

const ORO := Color("d5b578")
const PAPEL := Color("eee0c2")
const TINTA := Color("263a2b")
const SECUNDARIO := Color("4e5a42")
const Carta = preload("res://cartas/carta.tscn")
const CartaVisual := preload("res://cartas/carta_ui.gd")
var pagina_actual := 0
var navegacion: Array[Button] = []
var movimiento: CheckButton
var _pagina: Control
var _folio: Label
var _patron_ejemplo := "Punto exacto"
## Reglas de la mesa que se consulta. Sin datos, el libro describe al Custodio de I1.
var reglas: Dictionary = {}
var en_campana := false
const CUSTODIO := {"mesa": "custodio", "nombre": "El Custodio", "umbral": 17, "meta": 200, "presupuesto": 10, "ficha_por_pedir": 0, "umbral_minimo": 17}

func regla(clave: String) -> Variant:
	return reglas.get(clave, CUSTODIO[clave])

func coste_pedir() -> String:
	var fichas := int(regla("ficha_por_pedir"))
	if fichas <= 0: return "Gratis"
	return "−%s ficha" % fichas if fichas == 1 else "−%s fichas" % fichas

func resumen_mesa() -> String:
	return "%s · UMBRAL %s · META %s · %s CAMPANADAS" % [str(regla("nombre")).to_upper(), regla("umbral"), regla("meta"), regla("presupuesto")]

func nota_mesa() -> String:
	var meta := int(regla("meta"))
	match str(regla("mesa")):
		"recaudador":
			return "Comisión del Recaudador: el reparto inicial es cortesía; cada carta que pidas después cuesta una ficha. Sin fichas no puedes pedir, pero sí plantarte."
		"coleccionista":
			return "La Coleccionista retiene la carta más alta de cada mano, incluso en Quiebra. Plantarte resuelve: primero se comprueba la meta de %s, después si quedan manos." % meta
		"dueno":
			return "El Dueño empieza en 25 y, tras cada mano cerrada sin Quiebra, baja el umbral un punto hasta %s. Una Quiebra lo mantiene. Cada mano puntúa con el umbral vigente al jugarla." % regla("umbral_minimo")
	return "Con cero campanadas puedes seguir pidiendo en la última mano. Solo plantarte revela y resuelve: primero se comprueba si llegaste a %s, después si quedan manos." % meta

func mostrar_patron(nombre: String) -> void:
	_patron_ejemplo = nombre
	ir_a_pagina(2)

func _ready() -> void:
	size = Vector2(1056, 520)
	var grupo := ButtonGroup.new()
	var nombres := ["La apuesta", "Los cuatro palos", "Patrones y puntos", "A tu ritmo"]
	for indice in range(nombres.size()):
		var boton := Button.new()
		boton.text = nombres[indice]
		boton.position = Vector2(0, indice * 52)
		boton.size = Vector2(220, 44)
		boton.toggle_mode = true
		boton.button_group = grupo
		boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
		boton.add_theme_font_size_override("font_size", 18)
		var seleccionado := StyleBoxFlat.new()
		seleccionado.bg_color = Color("29402e")
		seleccionado.content_margin_left = 14
		boton.add_theme_stylebox_override("pressed", seleccionado)
		boton.pressed.connect(ir_a_pagina.bind(indice))
		add_child(boton)
		navegacion.append(boton)
	var retrato := TextureRect.new()
	retrato.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	retrato.texture = preload("res://recursos/arte/custodio-grabado.png")
	retrato.position = Vector2(0, 226)
	retrato.size = Vector2(205, 224)
	retrato.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	retrato.modulate.a = 0.7
	retrato.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(retrato)
	var pie := _texto(self, "La casa cuenta tus actos,\nno los segundos.", Rect2(0, 460, 220, 54), 18, ORO, true)
	pie.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var hoja := Panel.new()
	hoja.position = Vector2(246, -8)
	hoja.size = Vector2(810, 528)
	var papel := StyleBoxFlat.new()
	papel.bg_color = PAPEL
	papel.border_color = ORO
	papel.set_border_width_all(1)
	hoja.add_theme_stylebox_override("panel", papel)
	add_child(hoja)
	_pagina = Control.new()
	_pagina.position = Vector2(272, 10)
	_pagina.size = Vector2(758, 480)
	add_child(_pagina)
	_folio = _texto(self, "", Rect2(940, 488, 90, 22), 13, SECUNDARIO)
	_folio.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	movimiento = CheckButton.new()
	movimiento.name = "MovimientoReducido"
	movimiento.text = "Movimiento reducido"
	movimiento.position = Vector2(272, 438)
	movimiento.size = Vector2(400, 48)
	movimiento.add_theme_color_override("font_color", TINTA)
	movimiento.add_theme_color_override("font_hover_color", TINTA)
	movimiento.tooltip_text = "Mostrar directamente el estado final de las cartas, sin transiciones."
	# El control conserva un foco oscuro sobre papel, distinto del foco claro de la mesa.
	var foco := StyleBoxFlat.new()
	foco.bg_color = Color.TRANSPARENT
	foco.border_color = TINTA
	foco.set_border_width_all(3)
	movimiento.add_theme_stylebox_override("focus", foco)
	movimiento.toggled.connect(func(valor: bool) -> void: movimiento_cambiado.emit(valor))
	add_child(movimiento)
	ir_a_pagina(0)

func ir_a_pagina(indice: int) -> void:
	if indice < 0 or indice >= navegacion.size():
		return
	pagina_actual = indice
	for nodo in _pagina.get_children():
		_pagina.remove_child(nodo)
		nodo.queue_free()
	navegacion[indice].set_pressed_no_signal(true)
	movimiento.visible = indice == 3
	_folio.text = "%s / 4" % (indice + 1)
	match indice:
		0: _apuesta()
		1: _palos()
		2: _puntos()
		3: _controles()

func _texto(padre: Node, contenido: String, rect: Rect2, tamano := 19, color := TINTA, display := false) -> Label:
	var etiqueta := Label.new()
	etiqueta.clip_text = true
	etiqueta.text = contenido
	etiqueta.position = rect.position
	etiqueta.size = rect.size
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if display: etiqueta.theme_type_variation = &"DisplayLabel"
	padre.add_child(etiqueta)
	return etiqueta

func _linea(y: float) -> void:
	var linea := ColorRect.new()
	linea.color = Color("b8aa89")
	linea.position = Vector2(0, y)
	linea.size = Vector2(758, 1)
	linea.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pagina.add_child(linea)

func _apuesta() -> void:
	_texto(_pagina, "Cada decisión tiene un coste.", Rect2(0, 0, 758, 85), 39, TINTA, true)
	var resumen := _texto(_pagina, resumen_mesa(), Rect2(0, 78, 758, 24), 14, SECUNDARIO)
	resumen.name = "ResumenMesa"
	var umbral_texto := "el umbral vigente es %s" % regla("umbral") if str(regla("mesa")) == "dueno" else "si una mano supera %s, quiebra y aporta cero" % regla("umbral")
	var pedir := "Pedir es gratis." if int(regla("ficha_por_pedir")) <= 0 else "Pedir: una ficha."
	var intro := _texto(_pagina, "Acumula %s puntos; %s.\nTienes %s manos: cada inicio consume una campanada. %s" % [regla("meta"), umbral_texto, regla("presupuesto"), pedir], Rect2(0, 108, 758, 68), 20)
	intro.name = "CondicionesMesa"
	_linea(190)
	var filas := [
		["INICIAR MANO", "Recibes dos cartas.", "−1 campanada"],
		["PEDIR OTRA", "Arriesgas la mano actual.", coste_pedir()],
		["PLANTARSE", "Revelas y puntúas tu mano.", "Gratis"],
	]
	for indice in range(filas.size()):
		var y: int = 209 + indice * 59
		_texto(_pagina, filas[indice][0], Rect2(0, y, 205, 28), 17)
		_texto(_pagina, filas[indice][1], Rect2(205, y, 345, 30), 18)
		var coste := _texto(_pagina, filas[indice][2], Rect2(558, y, 200, 30), 18)
		coste.name = "Coste%s" % indice
		coste.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var nota := _texto(_pagina, nota_mesa(), Rect2(0, 399, 758, 76), 18, SECUNDARIO)
	nota.name = "NotaMesa"

func _palos() -> void:
	_texto(_pagina, "Cuatro palos. Cuatro ventajas.", Rect2(0, 0, 758, 48), 34, TINTA, true)
	var filas := [
		[Palos.VELAS, "Velas", "+1 al multiplicador por cada Vela conservada en una mano válida."],
		[Palos.LLAVES, "Llaves", "Devuelve una inicial antes de actuar, o la recién pedida. Un reemplazo gratis por mano; llega al final y no se puede volver a devolver."],
		[Palos.RELOJES, "Relojes", "Valen uno menos que lo impreso, con mínimo 1. Un 6 vale 5. " + ("Pedirlos es gratis y no recuperan campanadas." if int(regla("ficha_por_pedir")) <= 0 else "Pedirlos cuesta la misma ficha que otra carta; no recuperan campanadas.")],
		[Palos.MASCARAS, "Máscaras", "Ocultas hasta plantarte. Si conoces 9 y tienes una Máscara, puedes sumar entre 10 y 19. Todavía puedes quebrar."],
	]
	for indice in range(filas.size()):
		var y: int = 61 + indice * 103
		var arte := TextureRect.new()
		arte.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		arte.texture = CartaVisual.ARTE[filas[indice][0]]
		arte.position = Vector2(0, y)
		arte.size = Vector2(95, 91)
		arte.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		arte.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_pagina.add_child(arte)
		_texto(_pagina, filas[indice][1], Rect2(116, y - 3, 642, 35), 27, TINTA, true)
		_texto(_pagina, filas[indice][2], Rect2(116, y + 33, 642, 65), 18)
		if indice < 3: _linea(y + 98)

func _puntos() -> void:
	_texto(_pagina, "La cuenta de la casa", Rect2(0, 0, 758, 47), 36, TINTA, true)
	_texto(_pagina, "TOTAL EFECTIVO × (1 + VELAS + BONOS)", Rect2(0, 48, 758, 30), 18)
	var patrones := [
		["Punto exacto", "Total igual al umbral", "+3"],
		["Al filo", "Uno por debajo del umbral", "+2"],
		["Ascenso", "3 o más; toda la mano crece estrictamente", "+2"],
		["Mano larga", "5 cartas conservadas o más", "+2"],
		["Racha", "Las 3 últimas conservadas del mismo palo", "+2"],
	]
	for indice in range(patrones.size()):
		var y: int = 89 + indice * 34
		_texto(_pagina, patrones[indice][0], Rect2(0, y, 177, 29), 18)
		_texto(_pagina, patrones[indice][1], Rect2(177, y, 530, 29), 17)
		_texto(_pagina, patrones[indice][2], Rect2(712, y, 46, 29), 20)
	_linea(265)
	_texto(_pagina, "Cada patrón cuenta una vez. Exacto y Al filo se excluyen.\nAscenso sigue el orden de robo; no requiere números consecutivos.", Rect2(0, 274, 758, 54), 17, SECUNDARIO)
	var ejemplos := {
		"Punto exacto": {"palos": [Palos.LLAVES, Palos.RELOJES, Palos.MASCARAS], "valores": [4,6,8], "efectivos": [4,5,8], "suma": "4 + 5 + 8 = 17", "cuenta": "Exacto +3 · Ascenso +2\n17 × (1 + 3 + 2) = 102 puntos"},
		"Al filo": {"palos": [Palos.LLAVES, Palos.RELOJES, Palos.MASCARAS], "valores": [4,6,7], "efectivos": [4,5,7], "suma": "4 + 5 + 7 = 16", "cuenta": "Al filo +2 · Ascenso +2\n16 × (1 + 2 + 2) = 80 puntos"},
		"Ascenso": {"palos": [Palos.LLAVES, Palos.RELOJES, Palos.MASCARAS], "valores": [2,6,8], "efectivos": [2,5,8], "suma": "2 < 5 < 8", "cuenta": "Ascenso +2 · Total 15\n15 × (1 + 2) = 45 puntos"},
		"Mano larga": {"palos": [Palos.VELAS, Palos.LLAVES, Palos.RELOJES, Palos.MASCARAS, Palos.VELAS], "valores": [1,1,1,1,2], "efectivos": [1,1,1,1,2], "suma": "1 + 1 + 1 + 1 + 2 = 6", "cuenta": "Mano larga +2 · 2 Velas\n6 × (1 + 2 + 2) = 30 puntos"},
		"Racha": {"palos": [Palos.VELAS, Palos.VELAS, Palos.VELAS], "valores": [2,4,1], "efectivos": [2,4,1], "suma": "2 + 4 + 1 = 7", "cuenta": "Racha +2 · 3 Velas\n7 × (1 + 3 + 2) = 42 puntos"},
	}
	var ejemplo: Dictionary = ejemplos.get(_patron_ejemplo, ejemplos["Punto exacto"])
	var cantidad: int = ejemplo.palos.size()
	var paso := 54 if cantidad > 3 else 91
	for indice in range(cantidad):
		var carta = Carta.instantiate()
		carta.custom_minimum_size = Vector2(paso - 11, 130)
		carta.position = Vector2(indice * paso, 332)
		carta.size = carta.custom_minimum_size
		carta.focus_mode = Control.FOCUS_NONE
		carta.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_pagina.add_child(carta)
		carta.establecer_movimiento_reducido(true)
		carta.presentar({"palo": ejemplo.palos[indice], "valor": ejemplo.valores[indice], "valor_efectivo": ejemplo.efectivos[indice], "oculta": false})
	var etiqueta := "EJEMPLO · " if int(regla("umbral")) == 17 else "EJEMPLO CON UMBRAL 17 · "
	_texto(_pagina, etiqueta + _patron_ejemplo.to_upper(), Rect2(294, 330, 460, 25), 14, SECUNDARIO)
	_texto(_pagina, ejemplo.suma, Rect2(294, 356, 460, 39), 31, TINTA, true)
	var cuenta := _texto(_pagina, ejemplo.cuenta, Rect2(294, 401, 460, 63), 19)
	cuenta.name = "EjemploPuntos"

func _controles() -> void:
	_texto(_pagina, "Decide a tu ritmo", Rect2(0, 0, 758, 51), 36, TINTA, true)
	_texto(_pagina, "Elige una Llave en la mano y confirma junto a la carta. Las demás cartas se amplían. Consultar este libro es gratis.", Rect2(0, 56, 758, 58), 20)
	var teclas := [["P", "Iniciar / pedir"], ["S", "Plantarse"], ["L", "Elegir / cambiar Llave; confirmar en mesa"], ["H", "Abrir este libro"], ["V", "Ajustar el sonido" if en_campana else "Ajustar el sonido · R reinicia la mesa"]]
	for indice in range(teclas.size()):
		var y: int = 128 + indice * 35
		_texto(_pagina, teclas[indice][0], Rect2(0, y, 52, 30), 21)
		_texto(_pagina, teclas[indice][1], Rect2(62, y, 670, 30), 19)
	_linea(311)
	_texto(_pagina, "Tab / Mayús+Tab: recorrer · Enter / Espacio: activar · Esc: cancelar / volver.\nEl foco claro indica qué control estás usando.", Rect2(0, 320, 758, 55), 17)
	var reciclaje := "Al agotarse el mazo, se mezcla el descarte sin la mano actual."
	var recompensa := "\nTras los tres primeros sellos puedes añadir una carta a tu baraja." if en_campana else ""
	_texto(_pagina, reciclaje + recompensa, Rect2(0, 380, 758, 54), 17, SECUNDARIO)
