class_name CatalogoTienda
extends Resource
## Catálogo fijo de la tienda, en el orden en que se ofrece.

@export var objetos: Array[ObjetoTienda] = []

func buscar(id: String) -> ObjetoTienda:
	for objeto in objetos:
		if objeto.id == id: return objeto
	return null
