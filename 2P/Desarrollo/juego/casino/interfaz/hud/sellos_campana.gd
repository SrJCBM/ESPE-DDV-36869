extends HBoxContainer
## Tres recuadros contiguos que forman el tríptico de sellos (I4-04).
## Un sello pendiente conserva su silueta en relieve tenue; uno ganado se ve completo.
## El estado no depende del color: cambia la opacidad, el marco y el texto al enfocarlo.

const SELLOS := [
	{"id": "custodio", "nombre": "Sello del Custodio", "arte": preload("res://recursos/hud/sello_custodio.png")},
	{"id": "recaudador", "nombre": "Sello del Recaudador", "arte": preload("res://recursos/hud/sello_recaudador.png")},
	{"id": "coleccionista", "nombre": "Sello de la Coleccionista", "arte": preload("res://recursos/hud/sello_coleccionista.png")},
]
const LADO := 38.0

var recuadros: Array[TextureRect] = []
## Sellos mostrados; −1 hasta la primera presentación, que nunca anima.
var _mostrados := -1
var _estampa: Tween

func _init() -> void:
	name = "Sellos"
	add_theme_constant_override("separation", 2)
	for sello: Dictionary in SELLOS:
		var recuadro := TextureRect.new()
		recuadro.name = sello.id
		recuadro.texture = sello.arte
		recuadro.custom_minimum_size = Vector2(LADO, LADO)
		recuadro.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		recuadro.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		recuadro.focus_mode = Control.FOCUS_ALL
		recuadro.pivot_offset = Vector2(LADO, LADO) * 0.5
		add_child(recuadro)
		recuadros.append(recuadro)

## superadas: mesas ganadas en el intento (solo cuentan las tres primeras).
func presentar(superadas: int, reducido := false) -> void:
	var ganados := clampi(superadas, 0, SELLOS.size())
	for i in range(SELLOS.size()):
		var obtenido := i < ganados
		var recuadro := recuadros[i]
		recuadro.modulate = Color.WHITE if obtenido else Color(0.6, 0.6, 0.6, 0.45)
		recuadro.tooltip_text = "%s · %s" % [SELLOS[i].nombre, "conseguido" if obtenido else "pendiente"]
		recuadro.set_meta("obtenido", obtenido)
	if _mostrados >= 0 and ganados > _mostrados and ganados > 0:
		_estampar(recuadros[ganados - 1], reducido)
	_mostrados = ganados

## El sello recién ganado se estampa una sola vez: cae algo más grande y se asienta.
func _estampar(recuadro: TextureRect, reducido: bool) -> void:
	if _estampa != null and _estampa.is_valid():
		_estampa.kill()
	for otro in recuadros:
		otro.scale = Vector2.ONE
	if reducido:
		return
	recuadro.scale = Vector2.ONE * 1.7
	_estampa = create_tween()
	_estampa.tween_property(recuadro, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func cantidad_mostrada() -> int:
	return _mostrados
