extends Control
## Dial de campanadas (I4-05): base fija, aro que gira al gastar una campanada y la cifra
## en un control aparte, siempre horizontal y siempre con el valor real.
## Solo un gasto en la misma partida hace girar el aro; una devolución lleva su propio aviso.

const BASE := preload("res://mesa/arte/dial_campanadas_base.png")
const ARO := preload("res://mesa/arte/dial_campanadas_aro.png")
const Piezas := preload("res://mesa/piezas_mesa.gd")
const DURACION_GIRO := 0.25
## Cada campanada gastada avanza el aro una de sus doce muescas grabadas.
const PASO := TAU / 12.0

var base := TextureRect.new()
var aro := TextureRect.new()
var cifra: Label
var presupuesto: Label
var aviso: Label
var giro: Tween
var _aviso_tween: Tween
var _anteriores := -1
var _mano_anterior := -1
var _destino := 0.0

func _init(lado := 170.0) -> void:
	name = "DialCampanadas"
	size = Vector2(lado, lado)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for capa: TextureRect in [base, aro]:
		capa.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		capa.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		capa.mouse_filter = Control.MOUSE_FILTER_IGNORE
		capa.size = size
		# El pivote coincide con el centro común de ambas capas (192, 192 en el lienzo original).
		capa.pivot_offset = size * 0.5
		add_child(capa)
	base.texture = BASE
	aro.texture = ARO
	aro.name = "Aro"
	cifra = Piezas.etiqueta(self, "", Rect2(0, lado * 0.27, lado, lado * 0.38), 58, Piezas.ORO, true)
	cifra.name = "Cifra"
	cifra.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cifra.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cifra.add_theme_constant_override("outline_size", 6)
	cifra.add_theme_color_override("font_outline_color", Color("10251f"))
	presupuesto = Piezas.etiqueta(self, "", Rect2(0, lado + 4, lado, 20), 13, Piezas.MUTED)
	presupuesto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aviso = Piezas.etiqueta(self, "", Rect2(0, lado * 0.66, lado, 22), 15, Piezas.MARFIL)
	aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

## numero_mano distingue un gasto de la misma partida de un reinicio, que no gira el aro.
func presentar(campanadas: int, total: int, numero_mano: int, texto_presupuesto: String, reducido: bool) -> void:
	cifra.text = str(campanadas)
	presupuesto.text = texto_presupuesto
	if numero_mano != _mano_anterior:
		aviso.text = ""
	tooltip_text = "%s de %s campanadas" % [campanadas, total]
	var misma_partida := _anteriores >= 0 and numero_mano >= _mano_anterior and numero_mano > 0
	if misma_partida and campanadas < _anteriores and numero_mano > _mano_anterior:
		_girar(reducido)
	elif misma_partida and campanadas > _anteriores:
		_avisar_devolucion(campanadas - _anteriores, reducido)
	_anteriores = campanadas
	_mano_anterior = numero_mano

## Giro corto hacia la siguiente muesca; termina exactamente en su posición aunque se interrumpa.
func _girar(reducido: bool) -> void:
	detener()
	_destino = aro.rotation + PASO
	if reducido:
		aro.rotation = _destino
		return
	giro = create_tween()
	giro.tween_property(aro, "rotation", _destino, DURACION_GIRO).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _avisar_devolucion(cantidad: int, reducido: bool) -> void:
	aviso.text = "+%s %s" % [cantidad, "campanada" if cantidad == 1 else "campanadas"]
	aviso.modulate.a = 1.0
	if _aviso_tween != null and _aviso_tween.is_valid():
		_aviso_tween.kill()
	if reducido:
		return
	_aviso_tween = create_tween()
	_aviso_tween.tween_interval(1.2)
	_aviso_tween.tween_property(aviso, "modulate:a", 0.0, 0.4)

## Cambiar de pantalla o abrir un menú deja el aro quieto en su posición final.
func detener() -> void:
	if giro != null and giro.is_valid():
		giro.kill()
		aro.rotation = _destino
