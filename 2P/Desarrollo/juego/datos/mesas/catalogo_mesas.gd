class_name CatalogoMesas
extends Resource
## Las cuatro mesas de la campaña, en orden de progresión.

@export var mesas: Array[ReglaMesa] = []

func de(id: String) -> ReglaMesa:
	for mesa in mesas:
		if mesa.id == id: return mesa
	return null
