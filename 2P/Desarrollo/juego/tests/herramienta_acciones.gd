extends SceneTree
## Herramienta (no es prueba): escribe en project.godot las acciones de entrada del juego, con
## su tecla y su botón de mando. Ejecutar: godot --headless -s res://tests/herramienta_acciones.gd

const ACCIONES := {
	# acción: [teclas (keycode), botones de mando]
	"pedir": [[KEY_P], [JOY_BUTTON_X]],
	"plantarse": [[KEY_S], [JOY_BUTTON_Y]],
	"devolver_llave": [[KEY_L], [JOY_BUTTON_LEFT_SHOULDER]],
	"patrones": [[KEY_T], [JOY_BUTTON_RIGHT_SHOULDER]],
	"ayuda": [[KEY_H], [JOY_BUTTON_RIGHT_STICK]],
	"inventario": [[KEY_I], [JOY_BUTTON_BACK]],
	"mapa": [[KEY_M], [JOY_BUTTON_LEFT_STICK]],
	"sonido": [[KEY_V], []],
	"reiniciar": [[KEY_R], []],
	"pausa": [[KEY_ESCAPE], [JOY_BUTTON_START]],
}
## Movimiento: se conservan las teclas y se añaden la cruceta y el stick izquierdo.
const MOVIMIENTO := {
	"oeste": [JOY_BUTTON_DPAD_LEFT, JOY_AXIS_LEFT_X, -1.0],
	"este": [JOY_BUTTON_DPAD_RIGHT, JOY_AXIS_LEFT_X, 1.0],
	"norte": [JOY_BUTTON_DPAD_UP, JOY_AXIS_LEFT_Y, -1.0],
	"sur": [JOY_BUTTON_DPAD_DOWN, JOY_AXIS_LEFT_Y, 1.0],
}

func _init() -> void:
	for accion in ACCIONES:
		var eventos := []
		for tecla in ACCIONES[accion][0]:
			var e := InputEventKey.new()
			e.keycode = tecla
			e.device = -1
			eventos.append(e)
		for boton in ACCIONES[accion][1]:
			var b := InputEventJoypadButton.new()
			b.button_index = boton
			b.device = -1
			eventos.append(b)
		ProjectSettings.set_setting("input/" + accion, {"deadzone": 0.5, "events": eventos})
	for accion in MOVIMIENTO:
		var actual: Dictionary = ProjectSettings.get_setting("input/" + accion)
		var eventos: Array = actual.events.filter(func(e) -> bool: return e is InputEventKey)
		var b := InputEventJoypadButton.new()
		b.button_index = MOVIMIENTO[accion][0]
		b.device = -1
		eventos.append(b)
		var eje := InputEventJoypadMotion.new()
		eje.axis = MOVIMIENTO[accion][1]
		eje.device = -1
		eje.axis_value = MOVIMIENTO[accion][2]
		eventos.append(eje)
		ProjectSettings.set_setting("input/" + accion, {"deadzone": 0.2, "events": eventos})
	var interactuar: Dictionary = ProjectSettings.get_setting("input/interactuar")
	var eventos_i: Array = interactuar.events.filter(func(e) -> bool: return e is InputEventKey)
	var a := InputEventJoypadButton.new()
	a.button_index = JOY_BUTTON_A
	a.device = -1
	eventos_i.append(a)
	ProjectSettings.set_setting("input/interactuar", {"deadzone": 0.5, "events": eventos_i})
	print(ProjectSettings.save())
	quit()
