extends Control

const Visitante := preload("res://casino/exploracion/visitante.gd")
const SalaExplorable := preload("res://casino/exploracion/sala_explorable.gd")
const Libro := preload("res://casino/interfaz/libro.gd")
const Mesa := preload("res://mesa/mesa.tscn")
const VitrinaGabinete := preload("res://casino/interfaz/vitrina/vitrina_gabinete.gd")
const CartasRecompensa := preload("res://casino/interfaz/cartas_recompensa.gd")
const IndicadorObjetivo := preload("res://casino/interfaz/indicador_objetivo.gd")
const Minimapa := preload("res://casino/interfaz/minimapa.gd")
const HudCampana := preload("res://casino/interfaz/hud/hud_campana.gd")
const CifrasMesa := preload("res://casino/interfaz/cifras_mesa.gd")
const DialogoNovela := preload("res://casino/dialogos/dialogo_novela.gd")
const MenuCasino := preload("res://casino/interfaz/menus/menu_casino.gd")
const VistaBaraja := preload("res://casino/interfaz/baraja/vista_baraja.gd")
const ANFITRIONA: Conversacion = preload("res://datos/dialogos/anfitriona.tres")
## I5-10: el prólogo y las conversaciones de los crupieres son datos del guion v4.
const PROLOGO: Conversacion = preload("res://datos/dialogos/prologo.tres")
const LLEGADA: Conversacion = preload("res://datos/dialogos/llegada_vestibulo.tres")
const Cinematica := preload("res://casino/dialogos/cinematica.gd")
const CRUPIERES := {
	"custodio": preload("res://datos/dialogos/custodio.tres"),
	"recaudador": preload("res://datos/dialogos/recaudador.tres"),
	"coleccionista": preload("res://datos/dialogos/coleccionista.tres"),
	"dueno": preload("res://datos/dialogos/dueno.tres"),
}
## Nombre del protagonista hasta que el jugador pueda elegirlo.
const PROTAGONISTA := {"nombre": "Klein", "apellido": "Moretti"}
const BASE := Vector2(1440,810)
## Notas examinables del guion v4 (sección 11): título y texto base de cada sala.
const NOTAS := {
	"entrada": ["La farola", "Una farola encendida en una calle que ya no existe. No da calor. No da sombra."],
	"vestibulo": ["El reloj detenido", "Todas las agujas señalan la hora a la que llegaste. Bajo el cristal alguien grabó tres ranuras del tamaño de un sello."],
	"tienda": ["La vitrina de humo", "La lámpara atraviesa la lente y dibuja dos rostros en el terciopelo. Uno desaparece cuando la luz toca el cristal. El otro sigue mirándote cuando apagas la lámpara."],
	"custodio": ["El péndulo", "Hay diez muescas en la caja. El péndulo solo avanza cuando alguien empieza una mano. Bajo cada muesca hay un nombre rayado."],
	"recaudador": ["El libro mayor", "Las primeras dos cartas de cada mano figuran como cortesía. Junto a cada petición posterior aparece una ficha de tinta roja. Una página tiene tu nombre en el encabezado y, debajo, otro nombre tachado."],
	"coleccionista": ["El expositor", "Las piezas más valiosas ocupan el estante superior. En caso de empate, la etiqueta lleva la fecha de la última adquisición. Hay una vitrina vacía, limpia, con una etiqueta en blanco."],
	"dueno": ["La inscripción", "El sol está tallado en el suelo, pero la luz que pasa bajo el portón es real. Alrededor del sol hay arañazos. Alguien intentó arrastrarse hasta él."]
}
## Variantes del guion: la farola según lo que se habló con el farolero en el prólogo, y el
## reloj del vestíbulo cuando ya tiene sellos ({n}).
const NOTAS_VARIANTES := {
	"entrada_escucho": "La farola del farolero sigue encendida. Bajo su luz, en el empedrado, alguien grabó con una uña: «levántate a tiempo».",
	"entrada_ignacio": "Bajo la luz hay un reloj de bolsillo aplastado, adelantado tres minutos. En la tapa: I. F. Dentro, un retrato tuyo de niño.",
	"vestibulo_sellos": "Hay {n} sellos en las ranuras. Si acercas el oído, oyes un tic cada mucho tiempo. Cada tic suena como un hueso.",
}
## Descripción de cada nota ilustrada. El fondo se carga por id en historia/ilustraciones.
const ILUSTRACIONES_NOTAS := {
	"nota_entrada": "La farola encendida sobre el empedrado vacío, sin calle alrededor: solo niebla y un halo que no proyecta sombra.",
	"nota_entrada_escucho": "El empedrado bajo la farola, con unas palabras grabadas a uña en la piedra.",
	"nota_entrada_ignacio": "Un reloj de bolsillo aplastado bajo la farola, con la tapa abierta: las iniciales I. F. y, dentro, el retrato de un niño.",
	"nota_vestibulo": "La esfera del reloj del vestíbulo de cerca: todas las agujas en la misma hora y tres ranuras vacías bajo el cristal.",
	"nota_vestibulo_sellos": "La misma esfera con sellos encajados en las ranuras; el segundero tiembla, a punto de moverse.",
	"nota_tienda": "La lente de humo bajo la lámpara: dos rostros proyectados en el terciopelo; uno se desvanece y el otro mira al espectador.",
	"nota_custodio": "La caja del péndulo del Custodio con diez muescas y, bajo cada una, un nombre rayado.",
	"nota_recaudador": "Una página del libro mayor: dos líneas de cortesía, fichas de tinta roja y un encabezado con un nombre tachado debajo de otro.",
	"nota_coleccionista": "El estante superior del expositor con sus etiquetas fechadas y, al lado, una vitrina vacía y limpia con la etiqueta en blanco.",
	"nota_dueno": "El sol tallado en el mármol negro, rodeado de arañazos como de uñas, y la línea de luz real bajo el portón.",
}

var campana := CampanaCasino.new()
var sala := ""
var pagina := Control.new()
var mundo := Node2D.new()
var decorado := Node2D.new()
## Marcas de interacción, por encima del mundo y debajo de los diálogos.
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
var indicador_objetivo := IndicadorObjetivo.new()
var minimapa := Minimapa.new()
var vitrina := VitrinaGabinete.new()
var dialogo := DialogoNovela.new()
## Escena de cinemática (prólogo, llegada al vestíbulo): pantalla completa con fundidos.
var cinematica := Cinematica.new()
## Su diálogo; solo se deja con «Saltar».
var historia: Control:
	get: return cinematica.dialogo
## Lo que sigue al terminar la cinemática en curso.
var _tras_cinematica := Callable()
var menu := MenuCasino.new()
var vista_baraja := VistaBaraja.new()
## Control enfocado antes de abrir «Ver baraja»; se devuelve al cerrarla.
var _foco_baraja = null
## Control enfocado antes de pausar; se devuelve al reanudar.
var _foco_previo = null
## Guardado automático de la campaña (I5). Solo se activa cuando el casino es la escena
## principal, para que las pruebas que montan el casino no toquen la partida de quien juega.
var guardado_activo := false

func _ready() -> void:
	# Hasta que entren en el árbol, un Control cuenta como visible.
	menu.visible = false
	vista_baraja.visible = false
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
	minimapa.size = BASE
	pagina.add_child(minimapa)
	pagina.add_child(dialogo)
	dialogo.solicitud.connect(_solicitud)
	dialogo.cerrado.connect(_cerrar)
	dialogo.formatear = _formatear
	dialogo.sonido.connect(_sonar)
	velo.size = BASE
	velo.color = Color(0.015,0.035,0.026,0.66)
	pagina.add_child(velo)
	pagina.add_child(libro)
	pagina.add_child(vitrina)
	vitrina.cerrada.connect(_cerrar)
	pagina.add_child(cinematica)
	historia.formatear = _formatear
	cinematica.solicitud.connect(_solicitud)
	cinematica.sonido.connect(_sonar)
	cinematica.terminada.connect(_fin_cinematica)
	vitrina.compra_realizada.connect(func(_id: String) -> void:
		audio.reproducir(&"interfaz")
		_refrescar())
	velo.hide()
	libro.hide()
	resized.connect(_adaptar)
	_adaptar()
	entrar("entrada")
	add_child(menu)
	menu.audio = audio
	menu.texto_inventario = _texto_inventario
	menu.intento_activo = _algo_se_pierde
	menu.texto_confirmar = _aviso_volver_al_inicio
	menu.hay_partida = func() -> bool: return guardado_activo and PartidaGuardada.existe()
	menu.entrar.connect(_entrar_desde_menu)
	menu.continuar.connect(_continuar_desde_menu)
	menu.reanudar.connect(_reanudar)
	menu.volver_al_inicio.connect(volver_al_inicio)
	menu.salir.connect(func() -> void: get_tree().quit())
	menu.movimiento_cambiado.connect(_cambiar_movimiento)
	menu.lectura_cambiada.connect(_configurar_lectura)
	_configurar_lectura()
	menu.ver_baraja.connect(ver_baraja)
	add_child(vista_baraja)
	vista_baraja.cerrada.connect(_baraja_cerrada)
	_inicio_si_principal.call_deferred()

## El menú de inicio solo aparece al arrancar el juego, no cuando las pruebas montan el casino.
func _inicio_si_principal() -> void:
	if is_inside_tree() and get_tree().current_scene == self:
		guardado_activo = true
		abrir_inicio()

func abrir_inicio() -> void:
	menu.abrir("inicio")
	_congelar(true)

## Esc en el juego libre o en una mano sin nada abierto. Congela sala, mesa y animaciones.
func pausar() -> void:
	if menu.visible:
		return
	guardar() # Conserva también la posición exacta del visitante.
	_foco_previo = get_viewport().gui_get_focus_owner()
	menu.abrir("pausa")
	_congelar(true)
	audio.reproducir(&"interfaz")

func _reanudar() -> void:
	menu.cerrar()
	_congelar(false)
	_restaurar_foco()

## Devuelve el foco al control que lo tenía; si ya no está, a una acción válida de la mesa.
func _restaurar_foco() -> void:
	var previo = _foco_previo
	_foco_previo = null
	if _enfocable(previo):
		previo.grab_focus()
	elif is_instance_valid(mesa):
		for nombre in ["boton_iniciar_pedir", "boton_plantarse", "boton_ayuda"]:
			var accion: Control = mesa.get(nombre)
			if _enfocable(accion):
				accion.grab_focus()
				return

static func _enfocable(control) -> bool:
	if not is_instance_valid(control) or not control is Control or not control.is_visible_in_tree() or control.focus_mode == Control.FOCUS_NONE:
		return false
	return not (control is BaseButton and control.disabled)

func _congelar(congelado: bool) -> void:
	var modo := Node.PROCESS_MODE_DISABLED if congelado else Node.PROCESS_MODE_INHERIT
	pagina.process_mode = modo
	if is_instance_valid(mesa):
		mesa.process_mode = modo
	move_child(menu, -1)
	_actualizar_objetivo()

## Vuelve a la pantalla de inicio. Con guardado, la partida queda guardada (una mesa en
## curso vuelve a como estaba al sentarse); sin él, se abandona el intento.
func volver_al_inicio() -> void:
	guardar()
	if is_instance_valid(mesa):
		remove_child(mesa)
		mesa.queue_free()
		mesa = null
		pagina.show()
	_intento_en_blanco()
	abrir_inicio()

func _algo_se_pierde() -> bool:
	if guardado_activo:
		return is_instance_valid(mesa)
	return campana.recibida or is_instance_valid(mesa)

func _aviso_volver_al_inicio() -> String:
	if guardado_activo:
		return "Se perderá la mano en curso. Al continuar, volverás frente al crupier con lo que tenías al sentarte."
	return "Se perderá el intento actual: la baraja, las fichas y los sellos."

## «Entrar al casino» o «Nueva partida» (ya confirmada): empieza de cero si había partida.
func _entrar_desde_menu() -> void:
	if guardado_activo and PartidaGuardada.existe():
		PartidaGuardada.borrar()
		_intento_en_blanco()
	_reanudar()
	if guardado_activo:
		iniciar_prologo()

func _continuar_desde_menu() -> void:
	continuar()
	_reanudar()

## Guarda el intento si se puede: con invitación, sin derrota y fuera de una mesa.
func guardar() -> void:
	if not guardado_activo or not campana.recibida or campana.derrota or is_instance_valid(mesa) or not campana.activa.is_empty():
		return
	PartidaGuardada.guardar({
		"campana": campana.a_datos(), "sala": sala,
		"posicion": [visitante.position.x, visitante.position.y],
	})

## Carga la partida guardada. false si no hay ninguna válida.
func continuar() -> bool:
	var datos := PartidaGuardada.cargar()
	if datos.is_empty():
		return false
	campana = CampanaCasino.desde_datos(datos.campana)
	_cerrar()
	var destino := str(datos.get("sala", "vestibulo"))
	if not CampanaCasino.NOMBRES.has(destino) or not campana.puerta_abierta(destino):
		destino = "vestibulo"
	entrar(destino)
	var posicion = datos.get("posicion", [])
	if destino == str(datos.get("sala", "")) and posicion is Array and posicion.size() == 2:
		var punto := Vector2(float(posicion[0]), float(posicion[1]))
		if PlanoSalas.limites(destino).has_point(punto):
			visitante.position = punto
	if campana.hay_recompensa():
		_mostrar_recompensa("Tienes una carta de la casa pendiente. Puedes añadirla a tu baraja.")
	return true

func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_CLOSE_REQUEST:
		guardar()

func _cambiar_movimiento(reducido: bool) -> void:
	if is_instance_valid(mesa):
		mesa.establecer_movimiento_reducido(reducido)
	_refrescar()

func _actualizar_objetivo() -> void:
	var mostrar := not libro.visible and not velo.visible and not vitrina.visible and not dialogo.visible and not cinematica.activa and not menu.visible and not vista_baraja.visible and not is_instance_valid(mesa)
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
	# P6: la primera vez que se pisa el vestíbulo, una cinemática lleva a la anfitriona.
	if sala == "vestibulo" and guardado_activo and campana.cumple("no:historia:vio_vestibulo"):
		reproducir_cinematica.call_deferred(LLEGADA, _recepcion)

func cercano() -> Dictionary:
	return exploracion.cercano(visitante.position)

func _process(_delta: float) -> void:
	_actualizar_objetivo()
	var modal := libro.visible or vitrina.visible or dialogo.visible or cinematica.activa or menu.visible or is_instance_valid(mesa)
	minimapa.visible = not modal
	if modal:
		return
	minimapa.presentar(sala, visitante.position, exploracion.puntos)
	if minimapa.ampliado:
		return
	var elegido := cercano()
	exploracion.marcar(elegido)
	pista.text = _pista(elegido)

## La indicación de la puerta se limita al control; el requisito se lee al interactuar.
func _pista(elegido: Dictionary) -> String:
	if elegido.is_empty():
		return ""
	if elegido.tipo == "puerta":
		var cerrada: bool = (elegido.destino == "entrada" and campana.recibida) or not campana.puerta_abierta(elegido.destino)
		return "E · Examinar la puerta" if cerrada else "E · Entrar"
	return "E · " + str(elegido.accion)

func _unhandled_key_input(evento: InputEvent) -> void:
	if menu.visible or vista_baraja.visible or not evento is InputEventKey or not evento.pressed or evento.echo: return
	if minimapa.ampliado:
		if evento.keycode in [KEY_M, KEY_ESCAPE]:
			_alternar_mapa()
		get_viewport().set_input_as_handled()
		return
	# La mesa, la vitrina y el diálogo resuelven antes su propio Esc; si llega aquí, pausa.
	if evento.keycode == KEY_ESCAPE and not libro.visible:
		pausar()
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(mesa) or vitrina.visible or dialogo.visible or cinematica.activa: return
	if libro.visible:
		if evento.keycode == KEY_ESCAPE or (evento.keycode == KEY_I and libro.cierre == _cerrar):
			if libro.cierre.is_valid(): libro.cierre.call()
		elif evento.is_action_pressed("interactuar") and libro.lista.get_child_count() == 1:
			libro.primero.pressed.emit()
		else: return
	elif evento.keycode == KEY_M:
		_alternar_mapa()
	elif evento.is_action_pressed("interactuar"):
		var p := cercano()
		if not p.is_empty(): interactuar(p)
	elif evento.keycode == KEY_I: inventario()
	elif evento.keycode == KEY_V: _sonido()
	else: return
	get_viewport().set_input_as_handled()

func _alternar_mapa() -> void:
	minimapa.ampliado = not minimapa.ampliado
	visitante.bloqueado = minimapa.ampliado
	pista.text = ""

func interactuar(p: Dictionary) -> void:
	match p.tipo:
		"anfitriona": _recepcion()
		"tienda": tienda()
		"nota": examinar()
		"mesa": _presentar_jefe()
		"salida":
			if campana.superadas == 4:
				audio.reproducir(&"puerta")
				_abrir("El primer amanecer","El cerrojo cede. Por primera vez oyes pájaros en lugar de campanas. Has salido de la casa.","",Callable())
				libro.opcion("Comenzar otro viaje",_nuevo_intento)
			else: _aviso_puerta("La verja del alba", "Falta vencer al Dueño de la Casa.")
		"puerta":
			if p.destino == "entrada" and campana.recibida:
				_aviso_puerta("La puerta de la calle", "Donde estaba la puerta solo queda su contorno grabado en el mármol. No hay picaporte.")
			elif campana.puerta_abierta(p.destino):
				audio.reproducir(&"puerta")
				entrar(p.destino,sala)
			else:
				_aviso_puerta(CampanaCasino.NOMBRES[p.destino], PlanoGaleria.requisito(p.destino))

func _aviso_puerta(titulo_puerta: String, mensaje: String) -> void:
	var aviso := Conversacion.new()
	aviso.personajes = {"puerta": {"nombre": titulo_puerta}}
	aviso.entradas = [{"ir": "aviso"}]
	aviso.intervenciones = {"aviso": {"personaje": "puerta", "texto": mensaje}}
	visitante.bloqueado = dialogo.abrir(aviso, _condicion, AjustesJuego.movimiento_reducido(), Callable(), false)

## Conversación con la anfitriona en la escena de diálogos (I4-06); sus líneas son datos.
func _recepcion() -> void:
	visitante.bloqueado = true
	if dialogo.visible or cinematica.activa:
		return
	if not dialogo.abrir(ANFITRIONA, _condicion, AjustesJuego.movimiento_reducido(), _describir_opcion):
		visitante.bloqueado = false
	_actualizar_objetivo()

## Las opciones de la oferta inicial muestran el icono y el efecto del catálogo de la tienda.
func _describir_opcion(opcion: Dictionary) -> Dictionary:
	var solicitud := str(opcion.get("solicitud", ""))
	if not solicitud.begins_with("objeto_inicial:"):
		return {}
	var producto := CampanaCasino.TIENDA.buscar(solicitud.trim_prefix("objeto_inicial:"))
	if producto == null:
		return {}
	return {"icono": "res://casino/arte/objeto_%s.webp" % producto.id, "detalle": producto.descripcion}

## Una elección del diálogo pide un cambio; la campaña comprueba si corresponde.
func _solicitud(id: String) -> void:
	if id == "tomar_asiento":
		_jugar()
		return
	if campana.atender(id):
		if not id.begins_with("historia:"):
			audio.reproducir(&"sello")
		_refrescar()

## Condiciones de los diálogos: las de la campaña y «mesa_superada» para el crupier de la sala.
func _condicion(condicion: String) -> bool:
	if condicion == "mesa_superada":
		return CampanaCasino.MESAS.find(sala) < campana.superadas
	return campana.cumple(condicion)

## Marcas del guion: el nombre del protagonista y las cifras de la mesa de la sala.
func _formatear(texto: String) -> String:
	var marcas := PROTAGONISTA.duplicate()
	# La anfitriona saluda según el tono de la primera respuesta (guion 7.3).
	var tono := str(campana.historia.get("tono", ""))
	marcas["saludo"] = str(ANFITRIONA.intervencion("saludo_" + tono).get("texto", "")) if not tono.is_empty() else ""
	var regla: ReglaMesa = CampanaCasino.MESAS_CAMPANA.de(sala) if CampanaCasino.MESAS.has(sala) else null
	if regla != null:
		marcas.merge({"umbral": regla.umbral, "meta": regla.meta, "campanadas": regla.campanadas})
	return texto.format(marcas)

## Ajustes de lectura de Opciones para las conversaciones y las cinemáticas.
func _configurar_lectura() -> void:
	var ajustes := AjustesJuego.ajustes_dialogo()
	dialogo.configurar(ajustes)
	historia.configurar(ajustes)

func _sonar(id: String) -> void:
	audio.reproducir(StringName(id))

## Examinar una nota: escena de novela visual con la ilustración del objeto y su descripción.
func examinar() -> void:
	if not NOTAS.has(sala):
		return
	var variante := ""
	match sala:
		"entrada":
			match str(campana.historia.get("farolero", "")):
				"escucho": variante = "entrada_escucho"
				"pregunto_ignacio": variante = "entrada_ignacio"
		"vestibulo":
			if campana.superadas > 0: variante = "vestibulo_sellos"
	var texto: String = NOTAS[sala][1] if variante.is_empty() else str(NOTAS_VARIANTES[variante]).format({"n": mini(campana.superadas, 3)})
	reproducir_cinematica(conversacion_nota("nota_" + (sala if variante.is_empty() else variante), NOTAS[sala][0], texto))

static func conversacion_nota(fondo: String, titulo: String, texto: String) -> Conversacion:
	var datos := Conversacion.new()
	datos.personajes = {"narrador": {"nombre": ""}}
	datos.fondos = {fondo: {"ruta": "res://historia/ilustraciones/%s.webp" % fondo, "movimiento": "acercar", "descripcion": str(ILUSTRACIONES_NOTAS.get(fondo, titulo))}}
	datos.entradas = [{"ir": "nota"}]
	datos.intervenciones = {"nota": {"personaje": "narrador", "modo": "nvl", "fondo": fondo, "texto": "%s\n%s" % [titulo, texto]}}
	return datos

## Prólogo de novela visual antes de la entrada (I5-10). Al terminar o saltarlo, el jugador
## aparece frente a la fachada con el control.
func iniciar_prologo() -> void:
	reproducir_cinematica(PROLOGO)

## Abre una cinemática a pantalla completa; al terminar, vuelve la exploración y se llama a
## `despues` (por ejemplo, la conversación que la continúa).
func reproducir_cinematica(conversacion: Conversacion, despues := Callable()) -> void:
	if cinematica.activa:
		return
	_cerrar()
	visitante.bloqueado = true
	_tras_cinematica = despues
	if not cinematica.reproducir(conversacion, _condicion, AjustesJuego.movimiento_reducido()):
		visitante.bloqueado = false
	_actualizar_objetivo()

func _fin_cinematica(_completa: bool) -> void:
	_cerrar()
	var despues := _tras_cinematica
	_tras_cinematica = Callable()
	if despues.is_valid():
		despues.call()

## Atajo de las pruebas y capturas: la misma solicitud que «Entregar la invitación».
func _entregar() -> void:
	_solicitud("entregar_invitacion")

## Presentación del crupier en la escena de novela visual (I5-10): sus líneas del guion, las
## tres cifras de la mesa encima del cuadro y «Tomar asiento», «Preguntar…» o «Volver».
## Tras vencerlo, la revisita y sus preguntas.
func _presentar_jefe() -> void:
	if dialogo.visible:
		return
	visitante.bloqueado = true
	if not dialogo.abrir(CRUPIERES[sala], _condicion, AjustesJuego.movimiento_reducido()):
		visitante.bloqueado = false
		return
	if not _condicion("mesa_superada"):
		dialogo.poner_anexo(CifrasMesa.new(CampanaCasino.MESAS_CAMPANA.de(sala)))
	_actualizar_objetivo()

## Línea del crupier de la sala para la victoria o la derrota, o vacío.
func _linea_crupier(id: String) -> String:
	var conversacion: Conversacion = CRUPIERES.get(sala)
	if conversacion == null:
		return ""
	return _formatear(str(conversacion.intervencion(id).get("texto", "")))

func _jugar() -> void:
	guardar() # Si el juego se cierra en la mesa, se continúa frente al crupier.
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
	mesa.set("comentarios", AjustesJuego.comentarios_crupieres())

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
		var dicho := _linea_crupier("victoria")
		dicho = dicho + "\n\n" if not dicho.is_empty() else ""
		if campana.hay_recompensa():
			_ofrecer_recompensa(premio, dicho + ruta)
		else:
			_aviso("Mesa superada","%sLa casa entrega %s fichas. %s" % [dicho,premio,ruta])
	else:
		if guardado_activo:
			PartidaGuardada.borrar()
		var dicho := _linea_crupier("derrota")
		_abrir("La casa gana",(dicho + "\n\n" if not dicho.is_empty() else "") + "La última campanada se apaga. Tu siguiente invitación abrirá un intento nuevo.","",Callable())
		libro.opcion("Nuevo intento",_nuevo_intento)

func _ofrecer_recompensa(premio: int, ruta: String) -> void:
	_mostrar_recompensa("Recibes %s fichas. Puedes añadir una carta a tu baraja.\n%s" % [premio, ruta])

func _mostrar_recompensa(mensaje: String) -> void:
	_abrir("Una carta de la casa", mensaje, "", Callable())
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
	if guardado_activo:
		PartidaGuardada.borrar()
	_intento_en_blanco()

## Intento nuevo en memoria, sin tocar la partida guardada.
func _intento_en_blanco() -> void:
	campana = CampanaCasino.new()
	_cerrar()
	entrar("entrada")

func _abrir(t: String, mensaje: String, foto: String, volver: Callable) -> void:
	_preparar_libro()
	libro.presentar(t, mensaje, foto, volver)

func _preparar_libro() -> void:
	visitante.bloqueado = true
	velo.show()
	_actualizar_objetivo()

func _aviso(t: String, mensaje: String, foto := "") -> void:
	_abrir(t,mensaje,foto,_cerrar)
	libro.opcion("Continuar",_cerrar)

func _cerrar() -> void:
	minimapa.ampliado = false
	vitrina.hide()
	dialogo.hide()
	dialogo.poner_anexo(null)
	libro.hide()
	velo.hide()
	# Al tomar asiento desde el diálogo, este se cierra con la mesa ya abierta.
	visitante.bloqueado = is_instance_valid(mesa) or cinematica.activa
	_refrescar()

func _refrescar() -> void:
	titulo.text = CampanaCasino.NOMBRES.get(sala,"")
	hud.presentar(campana, AjustesJuego.movimiento_reducido())
	_actualizar_objetivo()
	guardar()

func inventario() -> void:
	var datos := _texto_inventario()
	_abrir(datos[0], datos[1], "", _cerrar)
	if campana.recibida:
		libro.opcion("Ver baraja", ver_baraja)
	libro.opcion("Continuar", _cerrar)

## «Ver baraja» desde el inventario, en exploración o en la pausa durante una mano.
## Al cerrarla, el foco vuelve al botón desde el que se abrió.
func ver_baraja() -> void:
	if not campana.recibida or vista_baraja.visible:
		return
	_foco_baraja = get_viewport().gui_get_focus_owner()
	move_child(vista_baraja, -1)
	vista_baraja.abrir(datos_baraja())
	audio.reproducir(&"naipe")
	_actualizar_objetivo()

func _baraja_cerrada() -> void:
	var previo = _foco_baraja
	_foco_baraja = null
	if _enfocable(previo):
		previo.grab_focus()
	_actualizar_objetivo()

## Proyección pública de la baraja: ordenada por palo y valor, nunca por el mazo. Durante una
## mano las Máscaras van boca abajo, sin valor ni ajuste, para no delatar las de la mano.
func datos_baraja() -> Dictionary:
	var en_mano := is_instance_valid(mesa)
	var cartas := []
	for carta in campana.baraja:
		var id := carta.id_instancia
		var oculta := en_mano and carta.definicion.palo == Palos.MASCARAS
		var ajuste := 0 if oculta else int(campana.ajustadas.get(id, 0))
		var notas := PackedStringArray()
		if not oculta and carta.definicion.rasgo == CartaEnPartida.RASGO_RACHA_DOBLE: notas.append("RACHA ×2")
		if campana.ganadas.has(id): notas.append("GANADA")
		if ajuste != 0: notas.append("AJUSTE %+d" % ajuste)
		cartas.append({
			"palo": carta.definicion.palo, "oculta": oculta,
			"valor": null if oculta else carta.definicion.valor_impreso as Variant,
			"valor_efectivo": null if oculta else carta.valor_efectivo() as Variant,
			"rasgo": "" if oculta else carta.definicion.rasgo, "nota": " · ".join(notas),
			"ganada": campana.ganadas.has(id), "ajuste": ajuste,
		})
	return {"cartas": cartas, "retiradas": campana.retiradas.duplicate(true), "en_mano": en_mano}

func _texto_inventario() -> Array:
	var objetos := PackedStringArray()
	for id in campana.amuletos: objetos.append(CampanaCasino.TIENDA.buscar(id).nombre)
	var sellos := PackedStringArray()
	for recuadro in hud.sellos.recuadros: sellos.append(recuadro.tooltip_text)
	var mensaje := "%s cartas   ·   %s fichas\n%s.\n%s / 2 lentes de humo. Amuletos: %s." % [campana.baraja.size(),campana.saldo,", ".join(sellos),campana.lentes,", ".join(objetos) if objetos.size() else "ninguno"]
	return ["Tus pertenencias", mensaje if campana.recibida else "Una invitación lacrada y una ficha antigua. Enséñale la invitación a la anfitriona."]

func tienda() -> void:
	if not campana.recibida:
		_aviso("Mostrador cerrado", "Presenta primero tu invitación en el vestíbulo.")
		return
	_preparar_libro()
	vitrina.abrir(campana)
