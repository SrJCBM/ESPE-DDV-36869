extends HBoxContainer
## Umbral, meta y campanadas de una mesa en tres cifras con su etiqueta (I4-03),
## junto a «Tomar asiento». La regla especial se consulta en el libro o en la placa de la mesa.

const Libro := preload("res://casino/interfaz/libro.gd")

func _init(regla: ReglaMesa = null) -> void:
	name = "CifrasMesa"
	add_theme_constant_override("separation", 34)
	if regla == null:
		return
	_cifra(regla.umbral, "UMBRAL")
	_cifra(regla.meta, "META")
	_cifra(regla.campanadas, "CAMPANADAS")

func _cifra(valor: int, etiqueta: String) -> void:
	var bloque := VBoxContainer.new()
	bloque.add_theme_constant_override("separation", 0)
	var numero := Libro.rotulo(str(valor), 36, Libro.PAPEL, true)
	numero.name = etiqueta.capitalize()
	bloque.add_child(numero)
	bloque.add_child(Libro.rotulo(etiqueta, 12, Libro.ORO))
	add_child(bloque)
