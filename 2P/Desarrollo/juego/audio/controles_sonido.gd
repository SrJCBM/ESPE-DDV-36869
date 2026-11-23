class_name ControlesSonido
extends VBoxContainer
## Vista compartida entre el vestíbulo y la mesa; se navega mediante Tab y flechas.

func construir(audio: AudioCasino) -> void:
	add_theme_constant_override("separation", 9)
	for canal: StringName in AudioCasino.CANALES:
		var fila := HBoxContainer.new()
		fila.add_theme_constant_override("separation", 18)
		var nombre := Label.new()
		nombre.text = AudioCasino.CANALES[canal]
		nombre.custom_minimum_size.x = 115
		fila.add_child(nombre)
		var barra := HSlider.new()
		barra.max_value = 100
		barra.step = 5
		barra.value = AudioCasino.volumen(canal)
		barra.accessibility_name = nombre.text
		barra.custom_minimum_size.y = 29
		barra.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(barra)
		var lectura := Label.new()
		lectura.custom_minimum_size.x = 56
		lectura.text = "%d %%" % barra.value
		fila.add_child(lectura)
		barra.value_changed.connect(_actualizar.bind(audio, canal, lectura))
		add_child(fila)

func _actualizar(valor: float, audio: AudioCasino, canal: StringName, lectura: Label) -> void:
	lectura.text = "%d %%" % valor
	audio.cambiar_volumen(canal, valor)
