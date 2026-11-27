extends PanelContainer
## Tarjeta de un objeto del inventario (revisión de pantallas, 26 nov 2026): ilustración, nombre,
## efecto y una barra de marcas con los usos o cargas que le quedan. La usan el inventario de la
## mesa y las pertenencias del casino, para que un objeto se lea igual en los dos sitios.

const Libro := preload("res://casino/interfaz/libro.gd")
const APAGADO := Color("2c3b33")

var id := ""
var arte: TextureRect
var nombre: Label
var efecto: Label
var rotulo_usos: Label
var cifra_usos: Label
var marcas: Array[Panel] = []

## datos: id, nombre, descripcion; usos y maximo (maximo 0 = objeto pasivo, sin marcas);
## rotulo: texto sobre las marcas; nota: estado breve a la derecha (p. ej. «Pasiva»).
func configurar(datos: Dictionary, ancho := 412.0) -> void:
	id = str(datos.get("id", ""))
	name = "Objeto_%s" % id
	custom_minimum_size = Vector2(ancho, 112)
	focus_mode = Control.FOCUS_ALL
	var normal := Libro.caja(Color("12291f"), Color("4a5443"))
	normal.set_content_margin_all(10)
	var foco := normal.duplicate()
	foco.border_color = Libro.ORO
	foco.set_border_width_all(2)
	add_theme_stylebox_override("panel", normal)
	focus_entered.connect(func() -> void: add_theme_stylebox_override("panel", foco))
	focus_exited.connect(func() -> void: add_theme_stylebox_override("panel", normal))
	var maximo := int(datos.get("maximo", 0))
	var usos := clampi(int(datos.get("usos", maximo)), 0, maxi(maximo, 0))
	var agotado := maximo > 0 and usos == 0
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 14)
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fila)
	var lamina := Panel.new()
	lamina.custom_minimum_size = Vector2(92, 92)
	lamina.add_theme_stylebox_override("panel", Libro.caja(Color("08150f"), Color("645c44")))
	lamina.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_child(lamina)
	arte = TextureRect.new()
	arte.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	arte.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	arte.position = Vector2(4, 4)
	arte.size = Vector2(84, 84)
	arte.texture = load("res://casino/arte/objeto_%s.webp" % id)
	arte.modulate.a = 0.4 if agotado else 1.0
	arte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lamina.add_child(arte)
	var columna := VBoxContainer.new()
	columna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columna.add_theme_constant_override("separation", 2)
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_child(columna)
	var cabeza := HBoxContainer.new()
	cabeza.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_child(cabeza)
	nombre = Libro.rotulo(str(datos.get("nombre", "")), 21, Libro.PAPEL, true)
	nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cabeza.add_child(nombre)
	var nota := str(datos.get("nota", "Agotado" if agotado else ""))
	if not nota.is_empty():
		var placa := Libro.rotulo(nota.to_upper(), 11, Color("1a120b") if not agotado else Libro.PAPEL)
		var fondo := StyleBoxFlat.new()
		fondo.bg_color = Libro.ORO if not agotado else Color("5a3a32")
		fondo.set_corner_radius_all(3)
		fondo.set_content_margin_all(4)
		fondo.content_margin_left = 8
		fondo.content_margin_right = 8
		placa.add_theme_stylebox_override("normal", fondo)
		placa.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		cabeza.add_child(placa)
	efecto = Libro.rotulo(str(datos.get("descripcion", "")), 14, Color("cfc6ad"))
	efecto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	efecto.custom_minimum_size = Vector2(ancho - 150, 0)
	columna.add_child(efecto)
	var espacio := Control.new()
	espacio.size_flags_vertical = Control.SIZE_EXPAND_FILL
	espacio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_child(espacio)
	if maximo > 0:
		var pie := HBoxContainer.new()
		pie.add_theme_constant_override("separation", 5)
		pie.mouse_filter = Control.MOUSE_FILTER_IGNORE
		columna.add_child(pie)
		rotulo_usos = Libro.rotulo(str(datos.get("rotulo", "USOS")), 11, Libro.ORO)
		rotulo_usos.custom_minimum_size.x = 84
		pie.add_child(rotulo_usos)
		for i in range(maximo):
			var marca := Panel.new()
			marca.custom_minimum_size = Vector2(minf(28.0, 84.0 / maximo), 8)
			marca.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			var estilo := StyleBoxFlat.new()
			estilo.bg_color = Libro.ORO if i < usos else APAGADO
			estilo.set_corner_radius_all(3)
			marca.add_theme_stylebox_override("panel", estilo)
			marca.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pie.add_child(marca)
			marcas.append(marca)
		cifra_usos = Libro.rotulo("%s / %s" % [usos, maximo], 13, Libro.PAPEL)
		pie.add_child(cifra_usos)
	tooltip_text = "%s · %s" % [nombre.text, efecto.text]
	accessibility_name = tooltip_text + ("" if maximo == 0 else ". %s: %s de %s" % [str(datos.get("rotulo", "Usos")).capitalize(), usos, maximo])

## Marcas encendidas (para pruebas).
func usos_encendidos() -> int:
	return marcas.filter(func(m: Panel) -> bool: return (m.get_theme_stylebox("panel") as StyleBoxFlat).bg_color == Libro.ORO).size()

## Datos de las tarjetas del inventario. En la mesa, usos_mesa trae lo que queda de cada objeto
## en este encuentro; fuera de ella se muestra lo que cada objeto da por mesa.
static func inventario(campana: CampanaCasino, usos_mesa = null) -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	var en_mesa: bool = usos_mesa is Dictionary
	var maximos := {"moneda": 3, "prudente": CampanaCasino.USOS_PRUDENTE}
	for id in campana.amuletos:
		var producto := CampanaCasino.TIENDA.buscar(id)
		if producto == null:
			continue
		var datos := {"id": id, "nombre": producto.nombre, "descripcion": producto.descripcion}
		if maximos.has(id):
			datos.maximo = maximos[id]
			datos.usos = int(usos_mesa.get(id, maximos[id])) if en_mesa else maximos[id]
			datos.rotulo = "EN ESTA MESA" if en_mesa else "POR MESA"
		else:
			datos.nota = "Pasiva"
		lista.append(datos)
	# Solo si se lleva alguna: una Lente que no se compró no debe aparecer como «Agotada».
	if campana.lentes > 0:
		var lente := CampanaCasino.TIENDA.buscar("lente")
		lista.append({"id": "lente", "nombre": lente.nombre, "descripcion": lente.descripcion,
			"maximo": 2, "usos": campana.lentes, "rotulo": "CARGAS"})
	return lista
