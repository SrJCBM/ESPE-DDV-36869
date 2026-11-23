class_name CartaDef
extends Resource
## Datos editables del catálogo; cada intento utiliza su propia copia.

@export var id: String = ""
@export var palo: String = ""
@export var valor_impreso: int = 1
## Rasgo especial opcional. «racha_doble»: cuenta como dos cartas para Racha (variante de I5).
@export var rasgo: String = ""

func _init(identificador: String = "", tipo: String = "", valor: int = 1, especial: String = "") -> void:
	id = identificador
	palo = tipo
	valor_impreso = valor
	rasgo = especial
