extends Control

const Visitante := preload("res://casino/exploracion/visitante.gd")
const SalaExplorable := preload("res://casino/exploracion/sala_explorable.gd")
const Libro := preload("res://casino/interfaz/libro.gd")
const Mesa := preload("res://mesa/mesa.tscn")
const VitrinaGabinete := preload("res://casino/interfaz/vitrina/vitrina_gabinete.gd")
const CartasRecompensa := preload("res://casino/interfaz/cartas_recompensa.gd")
const IndicadorObjetivo := preload("res://casino/interfaz/indicador_objetivo.gd")
const HudCampana := preload("res://casino/interfaz/hud/hud_campana.gd")
const CifrasMesa := preload("res://casino/interfaz/cifras_mesa.gd")
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
var hud := HudCampana.new()
var pista: Label
var exploracion := SalaExplorable.new(decorado, capa_superior)
var mesa: Control
var audio := AudioCasino.new()
var boton_sonido := Button.new()
var indicador_objetivo := IndicadorObjetivo.new()
var vitrina := VitrinaGabinete.new()

func _ready() -> void:
	get_window().min_size = Vector2i(1024,576)
	add_child(audio)
	visitante.pisada.connect(audio.reproducir.bind(&"paso"))
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
	boton_sonido.text = "Sonido · V"
	boton_sonido.position = Vector2(290, 9)
	boton_sonido.size = Vector2(104, 33)
	boton_sonido.add_theme_stylebox_override("normal", Libro.caja(Color("10251f"), Color("645c44")))
	boton_sonido.add_theme_color_override("font_color", Libro.PAPEL)
	boton_sonido.pressed.connect(_sonido)
	pagina.add_child(boton_sonido)
	titulo = Libro.rotulo("",26,Libro.PAPEL,true)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(435,5)
	titulo.size.x = 570
	pagina.add_child(titulo)
	hud.position = Vector2(982,6)
	hud.size = Vector2(376,40)
	pagina.add_child(hud)
	pista = Libro.rotulo("",17,Libro.PAPEL)
	pista.position = Vector2(80,777)
	pagina.add_child(pista)
	indicador_objetivo.name = "IndicadorObjetivo"
	pagina.add_child(indicador_objetivo)
	velo.size = BASE
	velo.color = Color(0.015,0.035,0.026,0.66)
	pagina.add_child(velo)
	pagina.add_child(libro)
	pagina.add_child(vitrina)
	vitrina.cerrada.connect(_cerrar)
	vitrina.compra_realizada.connect(func(_id: String) -> void:
		audio.reproducir(&"interfaz")
		_refrescar())
	velo.hide()
	libro.hide()
	resized.connect(_adaptar)
	_adaptar()
	entrar("vestibulo")

func _actualizar_objetivo() -> void:
	var mostrar := not libro.visible and not velo.visible and not vitrina.visible and not is_instance_valid(mesa)
	indicador_objetivo.presentar(campana.objetivo(), mostrar)

func _adaptar() -> void:
	var escala := minf(size.x/BASE.x, size.y/BASE.y)
	pagina.scale = Vector2.ONE*escala
	pagina.position = (size-BASE*escala)*0.5

func entrar(destino: String, origen := "") -> void:
	if not CampanaCasino.NOMBRES.has(destino) or not campana.puerta_abierta(destino):
		return
	sala = destino
	var nota: String = NOTAS.get(sala, [""])[0]
	visitante.position = exploracion.montar(sala, origen, campana, nota)
	_refrescar()

func cercano() -> Dictionary:
	return exploracion.cercano(visitante.position)

func _process(_delta: float) -> void:
	_actualizar_objetivo()
	if libro.visible or vitrina.visible or is_instance_valid(mesa): return
	var elegido := cercano()
	exploracion.marcar(elegido)
	pista.text = _pista(elegido)

## Una sola línea cerca de una interacción; una puerta cerrada muestra su requisito.
func _pista(elegido: Dictionary) -> String:
	if elegido.is_empty():
		return ""
	if elegido.tipo == "puerta" and not campana.puerta_abierta(elegido.destino):
		return str(elegido.accion)
	return "E · " + str(elegido.accion)

func _unhandled_key_input(evento: InputEvent) -> void:
	if is_instance_valid(mesa) or vitrina.visible or not evento is InputEventKey or not evento.pressed or evento.echo: return
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
	elif evento.keycode == KEY_V: _sonido()
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
				audio.reproducir(&"puerta")
				_abrir("El primer amanecer","El cerrojo cede. Por primera vez oyes pájaros en lugar de campanas. Has salido de la casa.","",Callable())
				libro.opcion("Comenzar otro viaje",_nuevo_intento)
			else: _aviso("La verja del alba","Falta vencer al Dueño de la Casa.")
		"puerta":
			if campana.puerta_abierta(p.destino):
				audio.reproducir(&"puerta")
				entrar(p.destino,sala)
			else:
				_aviso(CampanaCasino.NOMBRES[p.destino], PlanoGaleria.requisito(p.destino) + ".")

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
	_abrir(CampanaCasino.NOMBRES[sala],"«%s»" % DIALOGOS[sala],foto,_cerrar)
	libro.lista.add_child(CifrasMesa.new(CampanaCasino.MESAS_CAMPANA.de(sala)))
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
	mesa.activar_audio(audio)
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
		if campana.hay_recompensa():
			_ofrecer_recompensa(premio, ruta)
		else:
			_aviso("Mesa superada","La casa entrega %s fichas. %s" % [premio,ruta])
	else:
		_abrir("La casa gana","La última campanada se apaga. Tu siguiente invitación abrirá un intento nuevo.","",Callable())
		libro.opcion("Volver al vestíbulo",_nuevo_intento)

func _ofrecer_recompensa(premio: int, ruta: String) -> void:
	_abrir("Una carta de la casa", "Recibes %s fichas. Puedes añadir una carta a tu baraja.\n%s" % [premio, ruta], "", Callable())
	var fila := CartasRecompensa.new()
	libro.lista.add_child(fila)
	fila.presentar(campana.opciones_recompensa())
	fila.elegida.connect(_resolver_recompensa)
	libro.opcion("Continuar sin carta", _resolver_recompensa.bind(-1))

func _resolver_recompensa(indice: int) -> void:
	if campana.resolver_recompensa(indice):
		audio.reproducir(&"naipe" if indice >= 0 else &"interfaz")
		_cerrar()

func _sonido() -> void:
	if libro.visible:
		return
	_abrir("Sonido","Ajusta el volumen de cada canal.","",_cerrar)
	audio.reproducir(&"interfaz")
	var controles := ControlesSonido.new()
	controles.construir(audio)
	libro.lista.add_child(controles)
	libro.opcion("Volver al casino",_cerrar)

func _nuevo_intento() -> void:
	campana = CampanaCasino.new()
	_cerrar()
	entrar("vestibulo")

func _abrir(t: String, mensaje: String, foto: String, volver: Callable) -> void:
	_preparar_libro()
	libro.presentar(t, mensaje, foto, volver)

func _preparar_libro() -> void:
	visitante.bloqueado = true
	boton_sonido.focus_mode = Control.FOCUS_NONE
	velo.show()
	_actualizar_objetivo()

func _aviso(t: String, mensaje: String, foto := "") -> void:
	_abrir(t,mensaje,foto,_cerrar)
	libro.opcion("Continuar",_cerrar)

func _cerrar() -> void:
	vitrina.hide()
	libro.hide()
	velo.hide()
	boton_sonido.focus_mode = Control.FOCUS_ALL
	visitante.bloqueado = false
	_refrescar()

func _refrescar() -> void:
	titulo.text = CampanaCasino.NOMBRES.get(sala,"")
	hud.presentar(campana, AjustesJuego.movimiento_reducido())
	_actualizar_objetivo()

func inventario() -> void:
	var objetos := PackedStringArray()
	for id in campana.amuletos: objetos.append(CampanaCasino.TIENDA.buscar(id).nombre)
	var sellos := PackedStringArray()
	for recuadro in hud.sellos.recuadros: sellos.append(recuadro.tooltip_text)
	var mensaje := "%s cartas   ·   %s fichas\n%s.\n%s / 2 lentes de humo. Amuletos: %s." % [campana.baraja.size(),campana.saldo,", ".join(sellos),campana.lentes,", ".join(objetos) if objetos.size() else "ninguno"]
	_aviso("Tus pertenencias",mensaje if campana.recibida else "Una invitación lacrada y una ficha antigua. Enséñale la invitación a la anfitriona.")

func tienda() -> void:
	if not campana.recibida:
		_aviso("Mostrador cerrado", "Presenta primero tu invitación en el vestíbulo.")
		return
	_preparar_libro()
	vitrina.abrir(campana)
