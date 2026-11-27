class_name PilaPantallas
extends RefCounted
## Qué pantalla del casino está encima de las demás. Cada pantalla se registra una vez, de la
## más alta a la más baja, con la pregunta que dice si está abierta; el resto del código solo
## pregunta `superior()` o `alguna()`, en lugar de repetir cadenas de «a.visible or b.visible».
## Solo la pantalla de arriba recibe la entrada. `cambiada` avisa cuando algo se abre o se cierra.

signal cambiada

var _pantallas: Array[Dictionary] = []

## `abierta` devuelve si la pantalla está abierta. Si se da `control`, sus cambios de
## visibilidad avisan solos; si no, quien la abre o la cierra llama a `avisar()`.
func registrar(id: StringName, abierta: Callable, control: CanvasItem = null) -> void:
	_pantallas.append({"id": id, "abierta": abierta})
	if control != null:
		control.visibility_changed.connect(avisar)

## La pantalla abierta más alta, o &"" si solo se ve el casino.
func superior() -> StringName:
	for pantalla in _pantallas:
		if pantalla.abierta.call():
			return pantalla.id
	return &""

func abierta(id: StringName) -> bool:
	for pantalla in _pantallas:
		if pantalla.id == id:
			return pantalla.abierta.call()
	return false

## Si hay alguna pantalla abierta además de las de `excepto`.
func alguna(excepto: Array[StringName] = []) -> bool:
	for pantalla in _pantallas:
		if not excepto.has(pantalla.id) and pantalla.abierta.call():
			return true
	return false

func avisar() -> void:
	cambiada.emit()
