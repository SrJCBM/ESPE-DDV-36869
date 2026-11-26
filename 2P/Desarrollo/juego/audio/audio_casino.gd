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
	&"porcelana": preload("res://audio/recursos/porcelana.wav"),
	&"paso": preload("res://audio/recursos/paso.wav"),
	&"puerta": preload("res://audio/recursos/puerta.wav"),
	&"interfaz": preload("res://audio/recursos/interfaz.wav"),
}
const MUSICA := preload("res://audio/recursos/salon_sin_ventanas.wav")
const AMBIENTE := preload("res://audio/recursos/aire_del_casino.wav")
const RUTA_AMBIENTES := "res://audio/recursos/ambientes_i5/"
const FUNDIDO := 0.7
const SILENCIO_DB := -60.0

class Bucle:
	var vigente: AudioStreamPlayer
	var saliente: AudioStreamPlayer
	var transicion: Tween
	var origen: AudioStreamWAV

var _emisores := {}
var _azar := RandomNumberGenerator.new()
var _musica: Bucle
var _ambiente: Bucle

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		return
	for canal: StringName in CANALES:
		_aplicar(canal, volumen(canal))
	for id: StringName in SONIDOS:
		var emisor := _crear(&"Interfaz" if id == &"interfaz" else &"Efectos", SONIDOS[id])
		emisor.max_polyphony = 2
		_emisores[id] = emisor
	_musica = _crear_bucle(&"Musica", MUSICA)
	_ambiente = _crear_bucle(&"Ambiente", AMBIENTE)

## Al cerrar el juego, un sonido que aún suena deja su reproducción retenida por el servidor
## de audio y Godot la informa como fuga («resources still in use at exit»). Se detienen y
## sueltan todos los emisores antes de salir.
func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_CLOSE_REQUEST or que == NOTIFICATION_EXIT_TREE:
		detener_todo()

func detener_todo() -> void:
	for bucle in [_musica, _ambiente]:
		if bucle != null and bucle.transicion != null:
			bucle.transicion.kill()
	for hijo in get_children():
		if hijo is AudioStreamPlayer:
			hijo.stop()
			hijo.stream = null
	_emisores.clear()

func _crear(canal: StringName, sonido: AudioStream) -> AudioStreamPlayer:
	var emisor := AudioStreamPlayer.new()
	emisor.bus = canal
	emisor.stream = sonido
	add_child(emisor)
	return emisor

func _crear_bucle(canal: StringName, origen: AudioStreamWAV) -> Bucle:
	var bucle := Bucle.new()
	bucle.vigente = _crear(canal, _en_bucle(origen))
	bucle.saliente = _crear(canal, null)
	bucle.origen = origen
	bucle.vigente.play()
	return bucle

func _en_bucle(origen: AudioStreamWAV) -> AudioStreamWAV:
	var sonido := origen.duplicate() as AudioStreamWAV
	sonido.loop_mode = AudioStreamWAV.LOOP_FORWARD
	sonido.loop_end = roundi(sonido.get_length() * sonido.mix_rate)
	return sonido

## El pasillo y su sala comparten ambiente. Sentarse añade el tema de esa mesa.
func seleccionar_espacio(espacio: String, en_mesa := false) -> void:
	if _musica == null or _ambiente == null:
		return
	var jefe := espacio.trim_prefix("pasillo_")
	var tiene_tema := CampanaCasino.MESAS.has(jefe)
	var ambiente: AudioStreamWAV = AMBIENTE
	var musica: AudioStreamWAV = MUSICA
	if tiene_tema:
		ambiente = load(RUTA_AMBIENTES + "pasillo_%s.wav" % jefe)
		if en_mesa:
			musica = load(RUTA_AMBIENTES + "mesa_%s.wav" % jefe)
	_cambiar_bucle(_ambiente, ambiente)
	_cambiar_bucle(_musica, musica)

func _cambiar_bucle(bucle: Bucle, origen: AudioStreamWAV) -> void:
	if bucle.origen == origen:
		return
	if bucle.transicion != null:
		bucle.transicion.kill()
	# Si se cruza otra puerta durante el fundido, conserva la pista que se oye más.
	var anterior := bucle.vigente
	var entrante := bucle.saliente
	if entrante.playing and entrante.volume_db > anterior.volume_db:
		anterior = bucle.saliente
		entrante = bucle.vigente
	entrante.stop()
	entrante.stream = _en_bucle(origen)
	entrante.volume_db = SILENCIO_DB
	entrante.play()
	bucle.vigente = entrante
	bucle.saliente = anterior
	bucle.origen = origen
	var ganancia_anterior := db_to_linear(anterior.volume_db)
	bucle.transicion = create_tween()
	bucle.transicion.tween_method(_mezclar.bind(entrante, anterior, ganancia_anterior), 0.0, 1.0, FUNDIDO)
	bucle.transicion.tween_callback(_soltar.bind(anterior))

func _mezclar(progreso: float, entrante: AudioStreamPlayer, anterior: AudioStreamPlayer, ganancia_anterior: float) -> void:
	var angulo := progreso * PI / 2.0
	entrante.volume_db = linear_to_db(maxf(0.001, sin(angulo)))
	anterior.volume_db = linear_to_db(maxf(0.001, ganancia_anterior * cos(angulo)))

func _soltar(emisor: AudioStreamPlayer) -> void:
	emisor.stop()
	emisor.stream = null

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
