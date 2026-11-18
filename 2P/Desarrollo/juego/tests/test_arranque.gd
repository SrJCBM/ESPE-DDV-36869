extends GutTest
## El punto de entrada debe cargar una mesa jugable conectada al controlador.

func _escena_principal() -> String:
	return ProjectSettings.get_setting("application/run/main_scene")


func test_la_escena_principal_esta_configurada() -> void:
	assert_ne(_escena_principal(), "", "project.godot debe definir run/main_scene")


func test_la_escena_principal_existe() -> void:
	assert_true(ResourceLoader.exists(_escena_principal()), "La escena principal debe existir")


func test_la_escena_principal_carga() -> void:
	var escena := load(_escena_principal())
	assert_not_null(escena, "La escena principal debe cargar")
	assert_is(escena, PackedScene)


func test_el_acceso_directo_i1_abre_la_mesa_jugable() -> void:
	var escena: PackedScene = load("res://principal/principal.tscn")
	var instancia: Control = escena.instantiate()
	add_child_autofree(instancia)
	assert_not_null(instancia)
	var mesa := instancia.get_node_or_null("Mesa")
	assert_not_null(mesa, "El arranque debe mostrar el Custodio, no solo la etiqueta de la base")
	if mesa == null: return
	assert_not_null(mesa.controlador)
	assert_eq(mesa.controlador.obtener_vista().meta, 200)
	assert_false(mesa.boton_iniciar_pedir.disabled)
