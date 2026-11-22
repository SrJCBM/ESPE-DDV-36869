extends Control

const Visitante := preload("res://casino/visitante.gd")
const Galeria := preload("res://casino/galeria.gd")
const Libro := preload("res://casino/libro.gd")
const Mesa := preload("res://mesa/mesa.tscn")
const BASE := Vector2(1440,810)
const DIALOGOS := {
	"custodio": "He guardado la primera silla para ti. Escucha lo que calla la Máscara antes de pedir otra carta.",
	"recaudador": "Quince fichas de cortesía. Cada carta que pidas después del reparto cuesta una. Hasta el azar lleva cuentas.",
	"coleccionista": "Quédate con los puntos. Yo conservaré la carta más alta de cada mano, incluso si te pasas.",
	"dueno": "¿Ya distingues el alba tras la verja? Empiezas en veinticinco. Cada mano que cierres sin pasarte me devuelve un paso, hasta diecisiete."
}
const NOTAS := {
	"vestibulo": ["El reloj detenido", "Todas las agujas señalan la hora a la que llegaste. Bajo el cristal alguien grabó tres ranuras del tamaño de un sello."],
	"tienda": ["La vitrina de humo", "La lámpara atraviesa la lente y dibuja dos rostros en el terciopelo. Uno desaparece cuando la luz toca el cristal."],
	"custodio": ["El péndulo", "Hay diez muescas en la caja. El péndulo solo avanza cuando alguien empieza una mano."],
	"recaudador": ["El libro mayor", "Las primeras dos cartas de cada mano figuran como cortesía. Junto a cada petición posterior aparece una ficha de tinta roja."],
	"coleccionista": ["El expositor", "Las piezas más valiosas ocupan el estante superior. En caso de empate, la etiqueta lleva la fecha de la última adquisición."],
	"dueno": ["La inscripción", "El sol está tallado en el suelo, pero la luz que pasa bajo el portón es real."]
}

var campana := CampanaCasino.new()
var sala := ""
var pagina := Control.new()
var mundo := Node2D.new()
var decorado := Node2D.new()
## Rombos y placas: sobre el mundo y el visitante, pero debajo de diálogos y velo.
var capa_superior := Node2D.new()
var visitante := Visitante.new()
var libro := Libro.new()
var velo := ColorRect.new()
var titulo: Label
var cuenta: Label
var pista: Label
var puntos: Array[Dictionary] = []
var mesa: Control
var indicador_objetivo := PanelContainer.new()
var texto_objetivo: Label
var cambios_objetivo := 0
var _tween_objetivo: Tween

func _ready() -> void:
	get_window().min_size = Vector2i(1024,576)
	var fondo := ColorRect.new()
	fondo.color = Color("0a1915")
	add_child(fondo)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(pagina)
	pagina.size = BASE
	pagina.add_child(mundo)
	mundo.position = Vector2(80,52)
	# Orden por la altura de los pies: el visitante queda detrás de quien está más abajo.
	mundo.y_sort_enabled = true
	decorado.y_sort_enabled = true
	mundo.add_child(decorado)
	mundo.add_child(visitante)
	pagina.add_child(capa_superior)
	capa_superior.position = mundo.position
	var marca := Libro.rotulo("LA ÚLTIMA MESA",24,Libro.ORO,true)
	marca.position = Vector2(80,6)
	pagina.add_child(marca)
	titulo = Libro.rotulo("",26,Libro.PAPEL,true)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(435,5)
	titulo.size.x = 570
	pagina.add_child(titulo)
	cuenta = Libro.rotulo("",16,Libro.ORO)
	cuenta.position = Vector2(982,15)
	cuenta.size.x = 376
	cuenta.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pagina.add_child(cuenta)
	pista = Libro.rotulo("",17,Libro.PAPEL)
	pista.position = Vector2(80,777)
	pagina.add_child(pista)
	var controles := Libro.rotulo("WASD / flechas · caminar     E · interactuar     I · inventario",16,Libro.ORO)
	controles.position = Vector2(918,779)
	pagina.add_child(controles)
	_crear_objetivo()
	velo.size = BASE
	velo.color = Color(0.015,0.035,0.026,0.66)
	pagina.add_child(velo)
	pagina.add_child(libro)
	velo.hide()
	libro.hide()
	resized.connect(_adaptar)
	_adaptar()
	entrar("vestibulo")

## Objetivo discreto bajo el encabezado: no recibe clics ni compite con el aviso de E.
func _crear_objetivo() -> void:
	var franja := StyleBoxFlat.new()
	franja.bg_color = Color(0.02,0.055,0.043,0.62)
	franja.set_corner_radius_all(3)
	franja.content_margin_left = 10
	franja.content_margin_right = 14
	franja.content_margin_top = 5
	franja.content_margin_bottom = 6
	indicador_objetivo.name = "IndicadorObjetivo"
	indicador_objetivo.add_theme_stylebox_override("panel",franja)
	indicador_objetivo.position = Vector2(96,64)
	indicador_objetivo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation",9)
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	indicador_objetivo.add_child(fila)
	var rombo := Libro.rotulo("◆",12,Libro.ORO)
	rombo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fila.add_child(rombo)
	texto_objetivo = Libro.rotulo("",18,Libro.PAPEL)
	texto_objetivo.name = "TextoObjetivo"
	texto_objetivo.add_theme_constant_override("shadow_offset_x",1)
	texto_objetivo.add_theme_constant_override("shadow_offset_y",1)
	texto_objetivo.add_theme_color_override("font_shadow_color",Color(0,0,0,0.75))
	fila.add_child(texto_objetivo)
	pagina.add_child(indicador_objetivo)

func objetivo_visible() -> bool:
	return not libro.visible and not velo.visible and not is_instance_valid(mesa)

func _actualizar_objetivo() -> void:
	var texto := campana.objetivo()
	if texto != texto_objetivo.text:
		var habia_texto := not texto_objetivo.text.is_empty()
		texto_objetivo.text = texto
		indicador_objetivo.reset_size()
		if habia_texto:
			cambios_objetivo += 1
			if _tween_objetivo != null: _tween_objetivo.kill()
			indicador_objetivo.modulate.a = 0.0
			_tween_objetivo = indicador_objetivo.create_tween()
			_tween_objetivo.tween_property(indicador_objetivo,"modulate:a",1.0,0.4)
	indicador_objetivo.visible = objetivo_visible()

func _adaptar() -> void:
	var escala := minf(size.x/BASE.x, size.y/BASE.y)
	pagina.scale = Vector2.ONE*escala
	pagina.position = (size-BASE*escala)*0.5

func entrar(destino: String, origen := "") -> void:
	if not CampanaCasino.NOMBRES.has(destino) or not campana.puerta_abierta(destino): return
	sala = destino
	for capa in [decorado, capa_superior]:
		for hijo in capa.get_children():
			capa.remove_child(hijo)
			hijo.queue_free()
	puntos.clear()
	if sala == "corredor":
		var galeria := Galeria.new()
		galeria.campana = campana
		galeria.capa_placas = capa_superior
		decorado.add_child(galeria)
		for i in range(Galeria.DESTINOS.size()):
			var puerta: String = Galeria.DESTINOS[i]
			_punto("puerta",Vector2(Galeria.eje(i),302),CampanaCasino.NOMBRES[puerta],puerta)
		visitante.position = Vector2(Galeria.eje(maxi(0,Galeria.DESTINOS.find(origen))),375)
		_limites(Rect2(48,288,1184,310))
	else:
		var arte := Sprite2D.new()
		arte.texture = load("res://casino/arte/%s.webp" % sala)
		arte.centered = false
		arte.scale = Vector2(1280,720) / arte.texture.get_size()
		decorado.add_child(arte)
		_agregar_sala()
		visitante.position = Vector2(640,550 if sala == "vestibulo" else 593)
	_refrescar()

func _agregar_sala() -> void:
	_limites(Rect2(87,178,1106,475))
	_punto("puerta",Vector2(640,651),"Volver a la galería","corredor")
	match sala:
		"vestibulo":
			_figura("anfitriona",Vector2(990,231),84)
			_obstaculo(Rect2(846,165,265,102))
			_obstaculo(Rect2(80,463,50,154))
			_obstaculo(Rect2(1152,463,55,154))
			_punto("anfitriona",Vector2(985,279),"Hablar con la anfitriona")
			_punto("nota",Vector2(640,190),"Examinar el reloj")
		"tienda":
			_figura("anfitriona",Vector2(650,174),84)
			_obstaculo(Rect2(287,165,695,114))
			_obstaculo(Rect2(82,237,77,265))
			_obstaculo(Rect2(1120,237,78,265))
			_obstaculo(Rect2(85,563,218,61))
			_obstaculo(Rect2(971,563,218,61))
			_punto("tienda",Vector2(645,290),"Abrir el mostrador")
			_punto("nota",Vector2(168,385),"Examinar la vitrina")
		_:
			_figura(sala,Vector2(640,310),95)
			_obstaculo(Rect2(456,305,369,146))
			# Solo la silla del jefe: no se puede pasar entre él y su silla, pero sí rodearlo por detrás.
			_obstaculo(Rect2(600,240,84,70))
			if sala == "coleccionista":
				_obstaculo(Rect2(196,187,93,306))
				_obstaculo(Rect2(994,187,93,306))
				_obstaculo(Rect2(216,541,198,61))
				_obstaculo(Rect2(869,541,198,61))
			if sala == "recaudador":
				_obstaculo(Rect2(152,299,87,182))
				_obstaculo(Rect2(1048,299,87,182))
			_obstaculo(Rect2(592,440,96,62))
			_punto("mesa",Vector2(640,521),"Acercarse a la mesa")
			_punto("nota",Vector2(235,262),"Examinar " + str(NOTAS[sala][0]).to_lower())
			if sala == "dueno": _punto("salida",Vector2(640,188),"Examinar el portón")

func _figura(id: String, pies: Vector2, alto: float) -> void:
	var npc := Sprite2D.new()
	npc.texture = load("res://casino/arte/figura_%s.webp" % id)
	npc.scale = Vector2.ONE * alto / npc.texture.get_height()
	npc.offset = Vector2(0,-npc.texture.get_height()*0.5)
	npc.position = pies
	decorado.add_child(npc)

func _limites(area: Rect2) -> void:
	var a := area.position
	var b := area.end
	_obstaculo(Rect2(a-Vector2(30,30),Vector2(area.size.x+60,30)))
	_obstaculo(Rect2(a.x-30,b.y,area.size.x+60,30))
	_obstaculo(Rect2(a.x-30,a.y,30,area.size.y))
	_obstaculo(Rect2(b.x,a.y,30,area.size.y))

func _obstaculo(rect: Rect2) -> void:
	var fijo := StaticBody2D.new()
	fijo.position = rect.get_center()
	var forma := RectangleShape2D.new()
	forma.size = rect.size
	var col := CollisionShape2D.new()
	col.shape = forma
	fijo.add_child(col)
	decorado.add_child(fijo)

func _punto(tipo: String, pos: Vector2, accion: String, destino := "") -> void:
	var marca := Libro.rotulo("◇",24,Libro.ORO)
	marca.add_theme_constant_override("outline_size",5)
	marca.add_theme_color_override("font_outline_color",Color("15231e"))
	marca.position = pos-Vector2(10,25)
	capa_superior.add_child(marca)
	puntos.append({"tipo":tipo,"pos":pos,"accion":accion,"destino":destino,"marca":marca})

func cercano() -> Dictionary:
	var distancia := 90.0
	var elegido := {}
	for punto in puntos:
		var d := visitante.position.distance_to(punto.pos)
		if d <= distancia:
			distancia = d
			elegido = punto
	return elegido

func _process(_delta: float) -> void:
	_actualizar_objetivo()
	if libro.visible or is_instance_valid(mesa): return
	var elegido := cercano()
	for punto in puntos:
		punto.marca.text = "◆" if punto == elegido else "◇"
	if not elegido.is_empty(): pista.text = "E   /   " + str(elegido.accion)
	elif not campana.recibida: pista.text = "La anfitriona te espera en el mostrador iluminado."
	elif sala == "corredor": pista.text = "Acércate a una puerta para leer su placa."
	else: pista.text = "El umbral del sur conduce a la galería."

func _unhandled_key_input(evento: InputEvent) -> void:
	if is_instance_valid(mesa) or not evento is InputEventKey or not evento.pressed or evento.echo: return
	if libro.visible:
		if evento.keycode == KEY_ESCAPE or (evento.keycode == KEY_I and libro.cierre == _cerrar):
			if libro.cierre.is_valid(): libro.cierre.call()
		elif evento.is_action_pressed("interactuar") and libro.lista.get_child_count() == 1:
			libro.primero.pressed.emit()
		else: return
	elif evento.is_action_pressed("interactuar"):
		var p := cercano()
		if not p.is_empty(): interactuar(p)
	elif evento.keycode == KEY_I: inventario()
	else: return
	get_viewport().set_input_as_handled()

func interactuar(p: Dictionary) -> void:
	match p.tipo:
		"anfitriona": _recepcion()
		"tienda": tienda()
		"nota": _aviso(NOTAS[sala][0],NOTAS[sala][1])
		"mesa": _presentar_jefe()
		"salida":
			if campana.superadas == 4:
				_abrir("El primer amanecer","El cerrojo cede. Por primera vez oyes pájaros en lugar de campanas. Has salido de la casa.","",Callable())
				libro.opcion("Comenzar otro viaje",_nuevo_intento)
			else: _aviso("La verja del alba","Falta vencer al Dueño de la Casa.")
		"puerta":
			if campana.puerta_abierta(p.destino): entrar(p.destino,sala)
			else:
				var nivel := CampanaCasino.MESAS.find(p.destino)
				var requisito := "Habla con la anfitriona del vestíbulo." if nivel == 0 else "Necesitas %s de los tres sellos." % nivel
				_aviso(p.accion,requisito)

func _recepcion() -> void:
	var retrato := "res://casino/arte/personaje_anfitriona.webp"
	if not campana.recibida:
		_abrir("La anfitriona","«Llegas a la hora exacta. Aquí todos los relojes se detuvieron esperando a alguien. ¿Me dejas ver tu invitación?»",retrato,_cerrar)
		libro.opcion("Entregar la invitación",_entregar)
	else:
		var frases := ["«El reloj verde pertenece al Custodio. Cruza la puerta del sur y busca el primer sello en la galería.»","«El Recaudador adelanta quince fichas. Te cobrará una por cada carta que pidas tras el reparto.»","«Ella colecciona lo que más vale. Vigila qué carta se queda después de cada mano.»","«Tres sellos. El Dueño ya sabe que has llegado. Mira la luz tras su mesa.»","«Oigo el pestillo. Vuelve al portón detrás de la última mesa.»"]
		_aviso("La anfitriona",frases[campana.superadas],retrato)

func _entregar() -> void:
	campana.recibir_invitacion()
	_refrescar()
	_aviso("La anfitriona","«Veinticuatro cartas y diez fichas. Son tuyas. La tienda abre al otro lado de la galería. Cuando estés listo, toma asiento ante el Custodio.»","res://casino/arte/personaje_anfitriona.webp")

func _presentar_jefe() -> void:
	var nivel := CampanaCasino.MESAS.find(sala)
	var foto := "res://recursos/arte/custodio-grabado.png" if nivel == 0 else "res://casino/arte/personaje_%s.webp" % sala
	if nivel < campana.superadas:
		_aviso(CampanaCasino.NOMBRES[sala],"La mesa se ha cerrado. La casa recuerda tu victoria.",foto)
		return
	var regla := CampanaCasino.MESAS_CAMPANA.de(sala)
	_abrir(CampanaCasino.NOMBRES[sala],"«%s»\nUmbral %s   ·   Meta %s   ·   %s campanadas" % [DIALOGOS[sala],regla.umbral,regla.meta,regla.campanadas],foto,_cerrar)
	libro.opcion("Tomar asiento",_jugar)
	libro.opcion("Volver a la sala",_cerrar)

func _jugar() -> void:
	if not campana.iniciar(sala): return
	_cerrar()
	visitante.bloqueado = true
	pagina.hide()
	mesa = Mesa.instantiate()
	mesa.set("campana",campana)
	mesa.connect("salir_de_mesa",_levantarse,CONNECT_ONE_SHOT)
	add_child(mesa)
	mesa.establecer_movimiento_reducido(AjustesJuego.movimiento_reducido())

func _levantarse(victoria: bool, exactos: int) -> void:
	var premio := campana.cerrar(victoria,exactos)
	remove_child(mesa)
	mesa.queue_free()
	mesa = null
	pagina.show()
	visitante.bloqueado = false
	_refrescar()
	if victoria:
		var ruta := "Dirígete al portón del norte." if campana.superadas == 4 else "La siguiente sala está abierta."
		_aviso("Mesa superada","La casa entrega %s fichas. %s" % [premio,ruta])
	else:
		_abrir("La casa gana","La última campanada se apaga. Tu siguiente invitación abrirá un intento nuevo.","",Callable())
		libro.opcion("Volver al vestíbulo",_nuevo_intento)

func _nuevo_intento() -> void:
	campana = CampanaCasino.new()
	_cerrar()
	entrar("vestibulo")

func _abrir(t: String, mensaje: String, foto: String, volver: Callable) -> void:
	visitante.bloqueado = true
	velo.show()
	libro.presentar(t,mensaje,foto,volver)
	_actualizar_objetivo()

func _aviso(t: String, mensaje: String, foto := "") -> void:
	_abrir(t,mensaje,foto,_cerrar)
	libro.opcion("Continuar",_cerrar)

func _cerrar() -> void:
	libro.hide()
	velo.hide()
	visitante.bloqueado = false
	_refrescar()

func _refrescar() -> void:
	titulo.text = CampanaCasino.NOMBRES.get(sala,"")
	cuenta.text = "%s fichas     ·     %s / 3 sellos" % [campana.saldo,mini(3,campana.superadas)] if campana.recibida else "La invitación"
	_actualizar_objetivo()

func inventario() -> void:
	var objetos := PackedStringArray()
	for id in campana.amuletos: objetos.append(CampanaCasino.TIENDA.buscar(id).nombre)
	var mensaje := "%s cartas   ·   %s fichas   ·   %s / 3 sellos\n%s / 2 lentes de humo. Amuletos: %s." % [campana.baraja.size(),campana.saldo,mini(3,campana.superadas),campana.lentes,", ".join(objetos) if objetos.size() else "ninguno"]
	_aviso("Tus pertenencias",mensaje if campana.recibida else "Una invitación lacrada y una ficha antigua. Enséñale la invitación a la anfitriona.")

func tienda() -> void:
	if not campana.recibida:
		_aviso("Mostrador cerrado","Presenta primero tu invitación en el vestíbulo.")
		return
	_abrir("Gabinete de la anfitriona","«Mira bien antes de gastar. Algunas piezas te acompañan toda la noche.»\nSaldo disponible: %s fichas." % campana.saldo,"",_cerrar)
	for item: ObjetoTienda in CampanaCasino.TIENDA.objetos:
		libro.opcion("%s    ·    %s fichas" % [item.nombre,item.precio],_elegir_producto.bind(item.id))
	libro.opcion("Salir del gabinete",_cerrar)

func _elegir_producto(id: String) -> void:
	if id not in ["eliminar","subir","bajar"]:
		_confirmar_compra(id)
		return
	var item := CampanaCasino.TIENDA.buscar(id)
	_abrir(item.nombre,"%s   ·   %s fichas. Saldo: %s." % [item.descripcion,item.precio,campana.saldo],"",tienda)
	libro.opcion("Volver al catálogo",tienda)
	for carta in campana.baraja:
		var razon := campana.impedimento(id,carta)
		var nombre := "%s · %s" % [carta.definicion.palo.capitalize(),carta.definicion.valor_impreso]
		libro.opcion(nombre if razon.is_empty() else nombre+"   /   "+razon,_confirmar_compra.bind(id,carta),razon.is_empty())

func _confirmar_compra(id: String, carta: CartaEnPartida = null) -> void:
	var item := CampanaCasino.TIENDA.buscar(id)
	var razon := campana.impedimento(id,carta)
	var detalle := item.descripcion + "\nPrecio: %s fichas. Saldo actual: %s." % [item.precio,campana.saldo]
	if carta != null: detalle += " Carta: %s de %s." % [carta.definicion.valor_impreso,carta.definicion.palo]
	if not razon.is_empty(): detalle += "\n" + razon
	var ilustracion := "res://casino/arte/objeto_%s.webp" % id if carta == null else ""
	_abrir(item.nombre,detalle,ilustracion,tienda)
	if razon.is_empty(): libro.opcion("Confirmar compra",_comprar.bind(id,carta))
	libro.opcion("Volver al catálogo",tienda)

func _comprar(id: String, carta: CartaEnPartida) -> void:
	if not campana.comprar(id,carta): return
	_refrescar()
	_abrir("Trato cerrado","%s. Saldo tras la compra: %s fichas." % [CampanaCasino.TIENDA.buscar(id).nombre,campana.saldo],"",tienda)
	libro.opcion("Ver el catálogo",tienda)
	libro.opcion("Dejar el mostrador",_cerrar)
