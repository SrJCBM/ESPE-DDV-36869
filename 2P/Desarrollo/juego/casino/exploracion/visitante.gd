extends CharacterBody2D
signal pisada
## El origen del visitante está a la altura de sus pies.
const FIGURA := preload("res://casino/arte/klein_movimiento.webp")
## Filas en orden horario desde el este. Columna 0 en reposo y 1–4 para caminar.
const CELDA := Vector2(175, 224)
const FOTOGRAMAS_CAMINATA := 4
const DISTANCIA_PISADA := 82.0
## Altura en píxeles del mundo (1280 × 720). La sombra crece en proporción.
const ALTO := 104.0
var bloqueado := false
var rumbo := Vector2.DOWN
var _fotograma := 0
var _distancia_ciclo := 0.0
var _distancia_paso := 0.0

func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING
	var circulo := CircleShape2D.new()
	circulo.radius = 10
	var colision := CollisionShape2D.new()
	colision.shape = circulo
	add_child(colision)

func _physics_process(_delta: float) -> void:
	var direccion := Input.get_vector("oeste", "este", "norte", "sur")
	velocity = Vector2.ZERO if bloqueado else direccion * 245.0 * global_scale.x
	move_and_slide()
	var desplazamiento := get_position_delta()
	var distancia := desplazamiento.length() / maxf(global_scale.x, 0.001)
	if not bloqueado and distancia > 0.1:
		rumbo = desplazamiento.normalized()
		_distancia_ciclo = fposmod(_distancia_ciclo + distancia, DISTANCIA_PISADA * 2.0)
		_fotograma = 1 + int(_distancia_ciclo * FOTOGRAMAS_CAMINATA / (DISTANCIA_PISADA * 2.0))
		_distancia_paso += distancia
		if _distancia_paso >= DISTANCIA_PISADA:
			_distancia_paso -= DISTANCIA_PISADA
			pisada.emit()
	else:
		_fotograma = 0
		_distancia_ciclo = 0.0
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2(1,-2),0,Vector2(1,0.28))
	draw_circle(Vector2.ZERO,19.0*ALTO/66.0,Color(0.02,0.04,0.03,0.63))
	draw_set_transform(Vector2.ZERO)
	var fila := posmod(roundi(rumbo.angle() / (TAU / 8.0)), 8)
	var marco := Rect2(Vector2(_fotograma, fila) * CELDA, CELDA)
	var ancho := ALTO * CELDA.x / CELDA.y
	draw_texture_rect_region(FIGURA, Rect2(-ancho / 2, -ALTO, ancho, ALTO), marco)
