class_name CartaDef
extends Resource
## Datos editables del catálogo; cada intento utiliza su propia copia.

@export var id: String = ""
@export var palo: String = ""
@export var valor_impreso: int = 1

func _init(identificador: String = "", tipo: String = "", valor: int = 1) -> void:
	id = identificador
	palo = tipo
	valor_impreso = valor
