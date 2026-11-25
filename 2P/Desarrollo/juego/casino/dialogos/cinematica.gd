extends Control
## Escena de cinemática (I5-10): el prólogo, la llegada al vestíbulo y los eventos de la
## historia. A diferencia de las conversaciones normales (anfitriona, tienda, crupieres), que
## se abren sobre la sala, una cinemática ocupa toda la pantalla con su propio fondo: entra con
## un fundido, se lee como una novela visual y al terminar se desvanece para devolver la
## exploración. Con movimiento reducido no hay fundidos.

## La escena terminó: `completa` es false si se saltó.
signal terminada(completa: bool)
signal solicitud(id: String)
signal sonido(id: String)

const DialogoNovela := preload("res://casino/dialogos/dialogo_novela.gd")
const BASE := Vector2(1440, 810)
const FUNDIDO := 0.45 ## Segundos de cada fundido.

var dialogo := DialogoNovela.new()
## true desde que empieza hasta que termina (el fundido de salida ya no cuenta).
var activa := false
var _negro := ColorRect.new()
var _fundido: Tween

func _ready() -> void:
	name = "Cinematica"
	size = BASE
	mouse_filter = Control.MOUSE_FILTER_STOP
	_negro.color = Color("040a08")
	_negro.size = BASE
	_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_negro)
	dialogo.permitir_saltar = true
	add_child(dialogo)
	dialogo.solicitud.connect(solicitud.emit)
	dialogo.sonido.connect(sonido.emit)
	dialogo.cerrado.connect(_terminar.bind(true))
	dialogo.saltado.connect(_terminar.bind(false))
	hide()

## Abre la escena con un fundido desde la exploración. false si la conversación no tiene inicio.
func reproducir(conversacion: Conversacion, evaluar: Callable, reducido := false) -> bool:
	_parar_fundido()
	if not dialogo.abrir(conversacion, evaluar, reducido):
		return false
	activa = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	show()
	if reducido or not is_inside_tree():
		modulate.a = 1.0
	else:
		modulate.a = 0.0
		_fundido = create_tween()
		_fundido.tween_property(self, "modulate:a", 1.0, FUNDIDO)
	return true

func _terminar(completa: bool) -> void:
	if not activa:
		return
	activa = false
	terminada.emit(completa)
	# El jugador ya tiene el control: la escena solo se desvanece encima de la sala.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_parar_fundido()
	if dialogo.reducido or not is_inside_tree():
		hide()
		return
	_fundido = create_tween()
	_fundido.tween_property(self, "modulate:a", 0.0, FUNDIDO)
	_fundido.tween_callback(hide)

func _parar_fundido() -> void:
	if _fundido != null and _fundido.is_valid():
		_fundido.kill()
