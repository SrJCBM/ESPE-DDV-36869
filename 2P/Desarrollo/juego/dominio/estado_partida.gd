class_name EstadoPartida
extends RefCounted
## Zonas y recursos de un intento. Los comandos deciden costes y puntuación.

var mazo: Array[CartaEnPartida] = []
var mano: Array[CartaEnPartida] = []
var descarte: Array[CartaEnPartida] = []
var campanadas: int = 10
var puntos: int = 0
var umbral: int = 17
var meta: int = 200
var llave_usada: bool = false
var _rng := RandomNumberGenerator.new()

func _init(semilla: int = -1) -> void:
	reiniciar(semilla)


func robar() -> CartaEnPartida:
	if mazo.is_empty() and not descarte.is_empty():
		mazo.append_array(descarte)
		descarte.clear()
		_barajar()
	if mazo.is_empty():
		return null
	return mazo.pop_front()


func disponibles() -> int:
	return mazo.size() + descarte.size()


func cerrar_mano() -> void:
	descarte.append_array(mano)
	mano.clear()


func reiniciar(semilla: int = -1) -> void:
	if semilla >= 0:
		_rng.seed = semilla
	else:
		_rng.randomize()
	mazo = FabricaCartas.crear_baraja()
	mano.clear()
	descarte.clear()
	campanadas = 10
	puntos = 0
	umbral = 17
	meta = 200
	llave_usada = false
	_barajar()


func _barajar() -> void:
	# Fisher-Yates usa el generador del intento, sin tocar la semilla global.
	for i in range(mazo.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var temporal := mazo[i]
		mazo[i] = mazo[j]
		mazo[j] = temporal
