extends GutTest

func test_canales_y_volumen_silenciado_persisten() -> void:
	var ruta_original := AjustesJuego.ruta
	AjustesJuego.ruta = "user://test_i3_audio.cfg"
	var audio := AudioCasino.new()
	add_child_autofree(audio)
	AjustesJuego.guardar_movimiento_reducido(true)
	for canal: StringName in AudioCasino.CANALES:
		var indice := AudioServer.get_bus_index(canal)
		assert_gt(indice, 0, str(canal))
		var anterior := AudioServer.get_bus_volume_db(indice)
		var mudo := AudioServer.is_bus_mute(indice)
		audio.cambiar_volumen(canal, 0)
		assert_true(AudioServer.is_bus_mute(indice))
		assert_eq(AudioCasino.volumen(canal), 0)
		audio.cambiar_volumen(canal, 50)
		assert_false(AudioServer.is_bus_mute(indice))
		assert_almost_eq(AudioServer.get_bus_volume_db(indice), linear_to_db(0.5), 0.01)
		AudioServer.set_bus_mute(indice, mudo)
		AudioServer.set_bus_volume_db(indice, anterior)
	assert_true(AjustesJuego.movimiento_reducido())
	assert_eq(AudioCasino.volumen(&"Musica"), 50)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(AjustesJuego.ruta))
	AjustesJuego.ruta = ruta_original
