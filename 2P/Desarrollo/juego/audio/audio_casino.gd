class_name AudioCasino
extends Node
## Traduce eventos del juego a sonidos. La campaña y la puntuación viven fuera de este nodo.

const CANALES := {&"Musica": "Música", &"Ambiente": "Ambiente", &"Efectos": "Efectos", &"Interfaz": "Interfaz"}
const NIVELES := {&"Musica": 40, &"Ambiente": 35, &"Efectos": 65, &"Interfaz": 50}
const SONIDOS := {
	&"campana": preload("res://audio/recursos/campana.wav"),
	&"naipe": preload("res://audio/recursos/naipe.wav"),
	&"sello": preload("res://audio/recursos/sello.wav"),
	&"quiebra": preload("res://audio/recursos/quiebra.wav"),
	&"paso": preload("res://audio/recursos/paso.wav"),
	&"puerta": preload("res://audio/recursos/puerta.wav"),
	&"interfaz": preload("res://audio/recursos/interfaz.wav"),
}
const MUSICA := preload("res://audio/recursos/salon_sin_ventanas.wav")
const AMBIENTE := preload("res://audio/recursos/aire_del_casino.wav")
var _emisores := {}
var _azar := RandomNumberGenerator.new()

func _ready() -> void:
	if process_mode == Node.PROCESS_MODE_DISABLED or DisplayServer.get_name() == "headless":
		return
	for canal: StringName in CANALES:
		_aplicar(canal, volumen(canal))
	for id: StringName in SONIDOS:
		var emisor := _crear(&"Interfaz" if id == &"interfaz" else &"Efectos", SONIDOS[id])
		emisor.max_polyphony = 2
		_emisores[id] = emisor
	_bucle(&"Musica", MUSICA)
	_bucle(&"Ambiente", AMBIENTE)

func _crear(canal: StringName, sonido: AudioStream) -> AudioStreamPlayer:
	var emisor := AudioStreamPlayer.new()
	emisor.bus = canal
	emisor.stream = sonido
	add_child(emisor)
	return emisor

func _bucle(canal: StringName, origen: AudioStreamWAV) -> void:
	var sonido := origen.duplicate() as AudioStreamWAV
	sonido.loop_mode = AudioStreamWAV.LOOP_FORWARD
	sonido.loop_end = roundi(sonido.get_length() * sonido.mix_rate)
	_crear(canal, sonido).play()

func reproducir(id: StringName) -> void:
	var emisor: AudioStreamPlayer = _emisores.get(id)
	if emisor == null:
		return
	emisor.pitch_scale = _azar.randf_range(0.91, 1.09) if id in [&"paso", &"naipe"] else 1.0
	emisor.play()

static func volumen(canal: StringName) -> int:
	return AjustesJuego.volumen(canal, NIVELES[canal])

func cambiar_volumen(canal: StringName, nivel: float) -> void:
	var entero := clampi(roundi(nivel), 0, 100)
	_aplicar(canal, entero)
	AjustesJuego.guardar_volumen(canal, entero)
	if canal == &"Interfaz":
		reproducir(&"interfaz")

static func _aplicar(canal: StringName, nivel: int) -> void:
	var indice := AudioServer.get_bus_index(canal)
	if indice < 0:
		return
	AudioServer.set_bus_mute(indice, nivel == 0)
	AudioServer.set_bus_volume_db(indice, linear_to_db(maxf(0.001, nivel / 100.0)))
