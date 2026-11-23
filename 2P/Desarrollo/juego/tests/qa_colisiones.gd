extends SceneTree
## Capturas de cada sala con sus obstáculos pintados encima (I3-08); excluido de la exportación.
## --script res://tests/qa_colisiones.gd -- --sala=vestibulo
## Con --bordes=1 añade una cuadrícula en coordenadas del mundo y guarda solo los dos laterales ampliados.

func _init() -> void:
	call_deferred("_revisar")

func _revisar() -> void:
	var opciones: Dictionary = {}
	for argumento in OS.get_cmdline_user_args():
		var partes := argumento.trim_prefix("--").split("=", true, 1)
		if partes.size() == 2: opciones[partes[0]] = partes[1]
	root.size = Vector2i(1440, 810)
	var juego: Control = load("res://casino/casino.tscn").instantiate()
	root.add_child(juego)
	await process_frame
	juego.campana.recibir_invitacion()
	juego.campana.superadas = 4
	var sala: String = opciones.get("sala", "vestibulo")
	juego.entrar(sala, "vestibulo")
	juego.visitante.hide()
	for cuerpo in juego.decorado.get_children():
		if cuerpo is StaticBody2D:
			var forma: Node = cuerpo.get_child(0)
			if forma is CollisionShape2D:
				var marca := ColorRect.new()
				marca.color = Color(1, 0.1, 0.1, 0.38)
				marca.position = -forma.shape.size * 0.5
				marca.size = forma.shape.size
				cuerpo.add_child(marca)
			elif forma is CollisionPolygon2D:
				var poligono := Polygon2D.new()
				poligono.polygon = forma.polygon
				poligono.color = Color(1, 0.1, 0.1, 0.38)
				cuerpo.add_child(poligono)
	var bordes: bool = opciones.get("bordes", "") == "1"
	if bordes:
		for x in range(0, 1281, 25):
			_linea(juego.capa_superior, Vector2(x, 0), Vector2(x, 720), x % 50 == 0)
			if x % 100 == 0: _rotulo(juego.capa_superior, str(x), Vector2(x + 2, 150))
		for y in range(100, 721, 25):
			_linea(juego.capa_superior, Vector2(0, y), Vector2(1280, y), y % 50 == 0)
			if y % 50 == 0:
				_rotulo(juego.capa_superior, str(y), Vector2(2, y - 14))
				_rotulo(juego.capa_superior, str(y), Vector2(1240, y - 14))
	for i in range(4): await process_frame
	await RenderingServer.frame_post_draw
	var imagen := root.get_texture().get_image()
	var destino := "res://exportaciones/qa/colisiones_%s.png" % sala
	if bordes:
		# Laterales de la página (sala de 80 a 1360) ampliados uno junto al otro.
		var izquierda := imagen.get_region(Rect2i(80, 120, 360, 640))
		var derecha := imagen.get_region(Rect2i(1000, 120, 360, 640))
		var hoja := Image.create(720, 640, false, imagen.get_format())
		hoja.blit_rect(izquierda, Rect2i(0, 0, 360, 640), Vector2i(0, 0))
		hoja.blit_rect(derecha, Rect2i(0, 0, 360, 640), Vector2i(360, 0))
		hoja.resize(1080, 960)
		imagen = hoja
		destino = "res://exportaciones/qa/bordes_%s.png" % sala
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://exportaciones/qa"))
	quit(imagen.save_png(destino))

func _linea(capa: Node, a: Vector2, b: Vector2, fuerte: bool) -> void:
	var linea := Line2D.new()
	linea.points = PackedVector2Array([a, b])
	linea.width = 1.0
	linea.default_color = Color(0.3, 1, 1, 0.8 if fuerte else 0.35)
	capa.add_child(linea)

func _rotulo(capa: Node, texto: String, posicion: Vector2) -> void:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.position = posicion
	etiqueta.add_theme_font_size_override("font_size", 12)
	etiqueta.add_theme_color_override("font_color", Color(0.4, 1, 1))
	etiqueta.add_theme_constant_override("outline_size", 4)
	etiqueta.add_theme_color_override("font_outline_color", Color.BLACK)
	capa.add_child(etiqueta)
