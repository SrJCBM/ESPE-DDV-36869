extends VBoxContainer
## Opciones del menú (I4-07, ampliadas en I5-10). Dos columnas: el volumen por canal y la
## lectura de las conversaciones con sus ajustes de accesibilidad (velocidad del texto, espera
## del modo automático, tamaño del texto, opacidad del cuadro y movimiento reducido). Todo se
## guarda en AjustesJuego y se conserva entre sesiones.

signal movimiento_cambiado(reducido: bool)
signal lectura_cambiada

const Libro := preload("res://casino/interfaz/libro.gd")
const FILAS := [
	["velocidad", "Velocidad del texto"],
	["espera_auto", "Espera en modo Auto"],
	["tamano_texto", "Tamaño del texto"],
	["opacidad", "Opacidad del cuadro"],
]

var movimiento: CheckButton
## Deslizadores de lectura por clave de AjustesJuego.LECTURA.
var lectura := {}

func construir(audio: AudioCasino) -> void:
	add_theme_constant_override("separation", 16)
	var columnas := HBoxContainer.new()
	columnas.add_theme_constant_override("separation", 48)
	add_child(columnas)
	var izquierda := _columna(columnas, "Sonido")
	if audio != null:
		var sonido := ControlesSonido.new()
		izquierda.add_child(sonido)
		sonido.construir(audio)
	var derecha := _columna(columnas, "Lectura y accesibilidad")
	for fila: Array in FILAS:
		derecha.add_child(_fila_lectura(fila[0], fila[1]))
	movimiento = CheckButton.new()
	movimiento.text = "Movimiento reducido"
	movimiento.button_pressed = AjustesJuego.movimiento_reducido()
	movimiento.add_theme_font_override("font", Libro.SANS)
	movimiento.add_theme_font_size_override("font_size", 18)
	movimiento.add_theme_color_override("font_color", Libro.PAPEL)
	movimiento.toggled.connect(_cambiar)
	derecha.add_child(movimiento)

func _columna(padre: Container, titulo: String) -> VBoxContainer:
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 9)
	columna.custom_minimum_size.x = 420
	columna.add_child(Libro.rotulo(titulo, 22, Libro.ORO, true))
	padre.add_child(columna)
	return columna

func _fila_lectura(clave: String, etiqueta: String) -> HBoxContainer:
	var limites: Dictionary = AjustesJuego.LECTURA[clave]
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 14)
	var nombre := Label.new()
	nombre.text = etiqueta
	nombre.custom_minimum_size.x = 170
	fila.add_child(nombre)
	var barra := HSlider.new()
	barra.min_value = limites.minimo
	barra.max_value = limites.maximo
	barra.step = 5
	barra.value = AjustesJuego.lectura(clave)
	barra.accessibility_name = etiqueta
	barra.custom_minimum_size.y = 29
	barra.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(barra)
	var valor := Label.new()
	valor.custom_minimum_size.x = 92
	valor.text = _leer(clave, barra.value)
	fila.add_child(valor)
	barra.value_changed.connect(_cambiar_lectura.bind(clave, valor))
	lectura[clave] = barra
	return fila

static func _leer(clave: String, valor: float) -> String:
	match clave:
		"velocidad":
			return "Instantáneo" if valor >= AjustesJuego.LECTURA.velocidad.maximo else "%d c/s" % valor
		"espera_auto":
			return "%.1f s" % (valor / 10.0)
	return "%d %%" % valor

func _cambiar_lectura(valor: float, clave: String, lectura_valor: Label) -> void:
	lectura_valor.text = _leer(clave, valor)
	AjustesJuego.guardar_lectura(clave, roundi(valor))
	lectura_cambiada.emit()

func _cambiar(reducido: bool) -> void:
	AjustesJuego.guardar_movimiento_reducido(reducido)
	movimiento_cambiado.emit(reducido)
