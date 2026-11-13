extends GutTest
## Pruebas de arranque de la base I1-00: la escena principal existe,
## carga y se puede instanciar.

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


func test_la_escena_principal_se_instancia_e_identifica_la_base() -> void:
	var escena: PackedScene = load(_escena_principal())
	var instancia: Control = escena.instantiate()
	add_child_autofree(instancia)
	assert_not_null(instancia)
	assert_eq(instancia.get_node("Contenedor/Titulo").text, "La Última Mesa")
	assert_string_contains(instancia.get_node("Contenedor/Subtitulo").text, "I1-00")
