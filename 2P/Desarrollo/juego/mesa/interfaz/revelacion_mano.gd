extends Node
## Entrega las Máscaras en orden y publica la vista final al terminar o saltar.

signal iniciada
signal carta_revelada(indice: int, datos: Dictionary)
signal terminada(vista_final: Dictionary)

var activa: bool:
	get: return not _final.is_empty()

var _final: Dictionary = {}
var _indices: Array[int] = []
var _siguiente := 0
var _pausa := 0.0
var _reloj := Timer.new()

func _ready() -> void:
	_reloj.one_shot = true
	_reloj.timeout.connect(_avanzar)
	add_child(_reloj)

func presentar(actual: Dictionary, nueva: Dictionary, movimiento_reducido: bool) -> void:
	descartar()
	if not movimiento_reducido and actual.get("fase") == "decision" and nueva.get("fase") != "decision" and not nueva.get("ultima_mano", {}).is_empty():
		var cartas: Array = actual.get("cartas", [])
		for i in range(cartas.size()):
			if cartas[i].get("oculta", false):
				_indices.append(i)
	if _indices.is_empty():
		terminada.emit(nueva)
		return
	_final = nueva.duplicate(true)
	_pausa = minf(0.18, 0.66 / _indices.size())
	_reloj.start(_pausa)
	iniciada.emit()

func descartar() -> void:
	_reloj.stop()
	_final = {}
	_indices.clear()
	_siguiente = 0

func terminar() -> void:
	if not activa:
		return
	var vista_final := _final
	descartar()
	terminada.emit(vista_final)

func _avanzar() -> void:
	if _siguiente == _indices.size():
		terminar()
		return
	var indice := _indices[_siguiente]
	_siguiente += 1
	_reloj.start(0.22 if _siguiente == _indices.size() else _pausa)
	carta_revelada.emit(indice, _final.cartas[indice])
