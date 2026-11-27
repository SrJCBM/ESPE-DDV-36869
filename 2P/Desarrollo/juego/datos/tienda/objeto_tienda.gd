class_name ObjetoTienda
extends Resource
## Producto o servicio del gabinete de la anfitriona. Dato de catálogo: no se modifica durante el juego.
## Los límites de cada objeto viven aquí y solo aquí: la campaña, la mesa y el inventario los leen.

@export var id: String = ""
@export var nombre: String = ""
@export var precio: int = 0
@export_multiline var descripcion: String = ""
## Veces que el efecto se aplica en cada mesa (0 = sin límite o pasivo).
@export var usos_por_mesa: int = 0
## Cuántos se pueden llevar a la vez; solo los consumibles (0 = es un amuleto, uno por intento).
@export var maximo_llevado: int = 0
## Fichas que entrega cada uso, si entrega alguna.
@export var fichas_por_uso: int = 0
