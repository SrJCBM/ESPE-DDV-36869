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
const DialogoNovela := preload("res://casino/dialogos/dialogo_novela.gd")
const MenuCasino := preload("res://casino/interfaz/menus/menu_casino.gd")
const VistaBaraja := preload("res://casino/interfaz/baraja/vista_baraja.gd")
const ANFITRIONA: Conversacion = preload("res://datos/dialogos/anfitriona.tres")
const BASE := Vector2(1440,810)
const DIALOGOS := {
	"custodio": "He guardado la primera silla para ti. Escucha lo que calla la Máscara antes de pedir otra carta.",
	"recaudador": "Quince fichas de cortesía. Cada carta que pidas después del reparto cuesta una. Hasta el azar lleva cuentas.",
	"coleccionista": "Quédate con los puntos. Yo conservaré la carta más alta de cada mano, incluso si te pasas.",
	"dueno": "¿Ya distingues el alba tras la verja? Empiezas en veinticinco. Cada mano que cierres sin pasarte me devuelve un paso, hasta diecisiete."
}
const NOTAS := {
	"entrada": ["La farola", "Bajo la luz hay una invitación pisoteada con tu nombre. La tuya sigue lacrada en el bolsillo."],
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
var indicador_objetivo := IndicadorObjetivo.new()
var vitrina := VitrinaGabinete.new()
var dialogo := DialogoNovela.new()
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
	pagina.add_child(dialogo)
	dialogo.solicitud.connect(_solicitud)
	dialogo.cerrado.connect(_cerrar)
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
		var limites := PlanoSalas.LIMITES_GALERIA if PlanoGaleria.es_pasillo(destino) else PlanoSalas.LIMITES
		if limites.has_point(punto):
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
	var mostrar := not libro.visible and not velo.visible and not vitrina.visible and not dialogo.visible and not menu.visible and not vista_baraja.visible and not is_instance_valid(mesa)
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
	if libro.visible or vitrina.visible or dialogo.visible or menu.visible or is_instance_valid(mesa): return
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
	if menu.visible or vista_baraja.visible or not evento is InputEventKey or not evento.pressed or evento.echo: return
	# La mesa, la vitrina y el diálogo resuelven antes su propio Esc; si llega aquí, pausa.
	if evento.keycode == KEY_ESCAPE and not libro.visible:
		pausar()
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(mesa) or vitrina.visible or dialogo.visible: return
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

## Conversación con la anfitriona en la escena de diálogos (I4-06); sus líneas son datos.
func _recepcion() -> void:
	visitante.bloqueado = true
	if not dialogo.abrir(ANFITRIONA, campana.cumple, AjustesJuego.movimiento_reducido(), _describir_opcion):
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
	if campana.atender(id):
		audio.reproducir(&"sello")
		_refrescar()

## Atajo de las pruebas y capturas: la misma solicitud que «Entregar la invitación».
func _entregar() -> void:
	_solicitud("entregar_invitacion")

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
		if guardado_activo:
			PartidaGuardada.borrar()
		_abrir("La casa gana","La última campanada se apaga. Tu siguiente invitación abrirá un intento nuevo.","",Callable())
		libro.opcion("Volver al vestíbulo",_nuevo_intento)

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
	vitrina.hide()
	dialogo.hide()
	libro.hide()
	velo.hide()
	visitante.bloqueado = false
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
			"valor": null if oculta else carta.definicion.valor_impreso,
			"valor_efectivo": null if oculta else carta.valor_efectivo(),
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
