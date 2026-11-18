extends CharacterBody2D
## El origen del visitante está a la altura de sus pies.
const FIGURA := preload("res://casino/arte/figura_visitante.webp")
var bloqueado := false
var rumbo := Vector2.DOWN
var paso := 0.0

func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING
	var circulo := CircleShape2D.new()
	circulo.radius = 10
	var colision := CollisionShape2D.new()
	colision.shape = circulo
	add_child(colision)

func _physics_process(delta: float) -> void:
	var direccion := Input.get_vector("oeste", "este", "norte", "sur")
	velocity = Vector2.ZERO if bloqueado else direccion * 245.0 * global_scale.x
	if not velocity.is_zero_approx():
		rumbo = direccion
		paso += delta * 12.0
	else: paso = 0
	move_and_slide()
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2(1,-2),0,Vector2(1,0.28))
	draw_circle(Vector2.ZERO,19,Color(0.02,0.04,0.03,0.63))
	draw_set_transform(Vector2(0,-absf(sin(paso))*1.8),sin(paso)*0.019,Vector2(-1 if rumbo.x < -0.1 else 1,1))
	var alto := 66.0
	var ancho := alto * FIGURA.get_width() / FIGURA.get_height()
	draw_texture_rect(FIGURA,Rect2(-ancho/2,-alto,ancho,alto),false)
