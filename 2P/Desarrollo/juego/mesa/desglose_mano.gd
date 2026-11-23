extends RefCounted
## Contenido de la ventana «Desglose»: la cuenta de la mano resuelta y el boleto con su aporte.
## Solo lee la vista pública ya resuelta.

const Piezas = preload("res://mesa/piezas_mesa.gd")

static func construir(contenido: Control, vista: Dictionary) -> void:
	var resultado: Dictionary = vista.get("ultima_mano", {})
	var partes := PackedStringArray()
	for valor in resultado.get("valores", []):
		partes.append(str(valor))
	var texto := RichTextLabel.new()
	texto.name = "DesgloseResultado"
	texto.position = Vector2(32, 95)
	texto.size = Vector2(536, 498)
	texto.bbcode_enabled = true
	texto.focus_mode = Control.FOCUS_ALL
	texto.add_theme_font_size_override("normal_font_size", 19)
	texto.add_theme_color_override("default_color", Piezas.MARFIL)
	texto.text = "[b]VALORES EFECTIVOS · ORDEN DE ROBO[/b]\n%s = %s\nUmbral: %s\n\n" % [" + ".join(partes), resultado.get("total", 0), vista.get("umbral", 17)]
	if resultado.get("quiebra", false):
		texto.text += "[b]QUIEBRA[/b]\nEl total %s supera el umbral %s.\n\nBase del multiplicador: 1, sin aplicar.\nLas Velas y los patrones no producen bonificaciones en Quiebra.\nMultiplicador final: %s.\n\n[b]RESULTADO: 0 PUNTOS[/b]" % [resultado.get("total", 0), vista.get("umbral", 17), resultado.get("multiplicador", 0)]
	else:
		texto.text += "[b]MULTIPLICADOR[/b]\nBase: 1\nVelas conservadas: %s × +1\n" % resultado.get("velas", 0)
		var bonos: Dictionary = resultado.get("bonos", {})
		var patrones: Array = resultado.get("patrones", [])
		var formula := "1 + %s" % resultado.get("velas", 0)
		if patrones.is_empty():
			texto.text += "Sin patrones activados.\n"
		for patron in patrones:
			var bono: String = str(bonos.get(patron, "—"))
			texto.text += "%s: +%s\n" % [patron, bono]
			formula += " + " + bono
		if resultado.get("corona", 0) > 0:
			texto.text += "Corona del riesgo: +2\n"
			formula += " + 2"
		texto.text += "\nMultiplicador final: %s = %s\n\n[b]%s × %s = %s PUNTOS[/b]" % [formula, resultado.get("multiplicador", 1), resultado.get("total", 0), resultado.get("multiplicador", 1), resultado.get("puntos", 0)]
	contenido.add_child(texto)
	Piezas.imagen(contenido, "res://mesa/arte/boleto.svg", Rect2(595, 108, 310, 460))
	Piezas.etiqueta(contenido, "APORTE DE ESTA MANO", Rect2(617, 135, 266, 26), 13, Piezas.TINTA)
	var aporte := Piezas.etiqueta(contenido, str(resultado.get("puntos", 0)), Rect2(615, 175, 270, 120), 80, Piezas.TINTA, true)
	aporte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var concepto := Piezas.etiqueta(contenido, "QUIEBRA" if resultado.get("quiebra", false) else "PUNTOS", Rect2(615, 306, 270, 30), 18, Piezas.TINTA)
	concepto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Piezas.etiqueta(contenido, "ACUMULADO / META", Rect2(617, 387, 266, 28), 13, Piezas.TINTA)
	Piezas.etiqueta(contenido, "%s / %s" % [vista.get("puntos", 0), vista.get("meta", 200)], Rect2(617, 421, 266, 62), 36, Piezas.TINTA, true)
	Piezas.etiqueta(contenido, "SELLO CONSEGUIDO" if vista.get("victoria", false) else "LA CUENTA CONTINÚA", Rect2(617, 511, 266, 30), 12, Piezas.TINTA)
