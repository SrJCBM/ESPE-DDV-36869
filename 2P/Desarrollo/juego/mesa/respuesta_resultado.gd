extends RefCounted
## Respuesta visual al resolver una mano (I3-01) y aviso del cambio de umbral (I3-03).
## Solo recorre textos que el controlador ya calculó y siempre termina en ellos. Nunca altera la vista.

const DURACION_CUENTA := 0.45

var tween: Tween
var _aviso_umbral: Tween
var _textos_finales: Dictionary = {}
var _duenio: Control
var _lectura: Label
var _puntos: Label
var _umbral: Label

func _init(duenio: Control, lectura: Label, puntos: Label, umbral: Label) -> void:
	_duenio = duenio
	_lectura = lectura
	_puntos = puntos
	_umbral = umbral

## La cuenta sube desde cero hasta el aporte; las cartas saltan con Punto exacto o tiemblan con Quiebra.
func celebrar(vista: Dictionary, cartas: Array, puntos_previos: int) -> void:
	var mano: Dictionary = vista.get("ultima_mano", {})
	_textos_finales = {_lectura: _lectura.text, _puntos: _puntos.text}
	_lectura.pivot_offset = _lectura.size * 0.5
	tween = _duenio.create_tween()
	if mano.get("quiebra", false):
		for carta in cartas:
			carta.sacudir(0.8)
		tween.tween_property(_lectura, "modulate", Color(1.0, 0.62, 0.55), 0.08)
		tween.tween_property(_lectura, "modulate", Color.WHITE, 0.4)
		tween.tween_callback(detener)
		return
	var total: int = int(mano.get("total", 0))
	var multiplicador: int = int(mano.get("multiplicador", 1))
	var aporte: int = int(mano.get("puntos", 0))
	var meta: int = int(vista.get("meta", 200))
	var cuenta := func(valor: float) -> void:
		_lectura.text = "%s × %s = %s" % [total, multiplicador, roundi(valor)]
		_puntos.text = "%s / %s" % [puntos_previos + roundi(valor), meta]
	cuenta.call(0.0)
	tween.tween_method(cuenta, 0.0, float(aporte), DURACION_CUENTA).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_lectura, "scale", Vector2.ONE * 1.12, 0.07)
	tween.tween_property(_lectura, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_callback(detener)
	if mano.get("patrones", []).has("Punto exacto"):
		for i in range(cartas.size()):
			cartas[i].celebrar(DURACION_CUENTA * 0.6 + i * 0.05)

## Interrumpe la cuenta y deja los textos finales exactos.
func detener() -> void:
	if tween != null and tween.is_valid():
		tween.kill()
	tween = null
	for etiqueta in _textos_finales:
		etiqueta.text = _textos_finales[etiqueta]
	_textos_finales.clear()
	_lectura.scale = Vector2.ONE
	_lectura.modulate = Color.WHITE

## El número del umbral late en oro al cambiar; la placa explica el cambio con texto.
func avisar_cambio_umbral(reducido: bool) -> void:
	detener_aviso()
	if reducido: return
	_umbral.pivot_offset = _umbral.size * 0.5
	_umbral.scale = Vector2.ONE * 1.3
	_umbral.modulate = Color(1.25, 1.12, 0.8)
	_aviso_umbral = _duenio.create_tween().set_parallel(true)
	_aviso_umbral.tween_property(_umbral, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_aviso_umbral.tween_property(_umbral, "modulate", Color.WHITE, 0.9)

func detener_aviso() -> void:
	if _aviso_umbral != null and _aviso_umbral.is_valid(): _aviso_umbral.kill()
	_umbral.scale = Vector2.ONE
	_umbral.modulate = Color.WHITE
