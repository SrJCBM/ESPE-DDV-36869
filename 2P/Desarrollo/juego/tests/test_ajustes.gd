extends GutTest
## Ajustes que se conservan entre sesiones (I3-05). Usa un archivo propio para no tocar las preferencias reales.

var _ruta_original := ""

func before_each() -> void:
	_ruta_original = AjustesJuego.ruta
	AjustesJuego.ruta = "user://ajustes_prueba.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(AjustesJuego.ruta))

func after_each() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(AjustesJuego.ruta))
	AjustesJuego.ruta = _ruta_original
	await get_tree().process_frame

func test_sin_archivo_el_movimiento_es_normal() -> void:
	assert_false(AjustesJuego.movimiento_reducido())

func test_guardar_y_leer_movimiento_reducido() -> void:
	AjustesJuego.guardar_movimiento_reducido(true)
	assert_true(AjustesJuego.movimiento_reducido())
	AjustesJuego.guardar_movimiento_reducido(false)
	assert_false(AjustesJuego.movimiento_reducido())

func test_la_mesa_principal_aplica_el_ajuste_guardado() -> void:
	AjustesJuego.guardar_movimiento_reducido(true)
	var principal = load("res://principal/principal.tscn").instantiate()
	add_child_autofree(principal)
	assert_true(principal.get_node("Mesa").movimiento_reducido)

func test_una_mesa_suelta_no_lee_el_archivo() -> void:
	AjustesJuego.guardar_movimiento_reducido(true)
	var mesa = load("res://mesa/mesa.tscn").instantiate()
	add_child_autofree(mesa)
	assert_false(mesa.movimiento_reducido, "Solo los puntos de entrada aplican el ajuste")
