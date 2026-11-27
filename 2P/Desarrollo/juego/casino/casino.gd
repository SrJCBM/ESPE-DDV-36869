extends Control
## Casino explorable: monta las salas, abre cada pantalla y reparte la entrada. El guion vive en
## GuionCasino, las notas en NotasCasino, el estado del intento en CampanaCasino y la pantalla
## que está encima en PilaPantallas; este nodo solo los coordina.

const Visitante := preload("res://casino/exploracion/visitante.gd")
const SalaExplorable := preload("res://casino/exploracion/sala_explorable.gd")
const Libro := preload("res://casino/interfaz/libro.gd")
const Mesa := preload("res://mesa/mesa.tscn")
const VitrinaGabinete := preload("res://casino/interfaz/vitrina/vitrina_gabinete.gd")
const PantallaRecompensa := preload("res://casino/interfaz/recompensa/pantalla_recompensa.gd")
const IndicadorObjetivo := preload("res://casino/interfaz/indicador_objetivo.gd")
const Minimapa := preload("res://casino/interfaz/minimapa.gd")
const HudCampana := preload("res://casino/interfaz/hud/hud_campana.gd")
const CifrasMesa := preload("res://casino/interfaz/cifras_mesa.gd")
const DialogoNovela := preload("res://casino/dialogos/dialogo_novela.gd")
const MenuCasino := preload("res://casino/interfaz/menus/menu_casino.gd")
const VistaBaraja := preload("res://casino/interfaz/baraja/vista_baraja.gd")
const InventarioCampana := preload("res://casino/interfaz/inventario_campana.gd")
const Cinematica := preload("res://casino/dialogos/cinematica.gd")
## Lienzo de diseño; el proyecto lo escala a la ventana (Proyecto › Pantalla › Estirar).
const BASE := Vector2(1440, 810)

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
var mesa: MesaUI
var audio := AudioCasino.new()
var indicador_objetivo := IndicadorObjetivo.new()
var minimapa := Minimapa.new()
var vitrina := VitrinaGabinete.new()
var globo := GloboConsejo.new()
var recompensa := PantallaRecompensa.new()
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
## Qué pantalla está encima; la única que recibe la entrada.
var pantallas := PilaPantallas.new()
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
	get_window().min_size = Vector2i(1024, 576)
	add_child(audio)
	visitante.pisada.connect(audio.reproducir.bind(&"paso"))
	visitante.movido.connect(actualizar_exploracion)
	var fondo := ColorRect.new()
	fondo.color = Color("0a1915")
	add_child(fondo)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(pagina)
	pagina.size = BASE
	pagina.add_child(mundo)
	mundo.position = Vector2(80, 52)
	# Orden por la altura de los pies: el visitante queda detrás de quien está más abajo.
	mundo.y_sort_enabled = true
	decorado.y_sort_enabled = true
	mundo.add_child(decorado)
	mundo.add_child(visitante)
	pagina.add_child(capa_superior)
	capa_superior.position = mundo.position
	# Revisión de pantallas (26 nov 2026): el título del juego queda solo en el menú de inicio.
	titulo = Libro.rotulo("", 26, Libro.PAPEL, true)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(435, 5)
	titulo.size.x = 570
	pagina.add_child(titulo)
	hud.position = Vector2(982, 6)
	hud.size = Vector2(376, 40)
	pagina.add_child(hud)
	pista = Libro.rotulo("", 18, Libro.PAPEL)
	pista.position = Vector2(80, 774)
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
	velo.color = Color(0.015, 0.035, 0.026, 0.66)
	pagina.add_child(velo)
	pagina.add_child(libro)
	pagina.add_child(vitrina)
	vitrina.cerrada.connect(_cerrar)
	pagina.add_child(recompensa)
	recompensa.resuelta.connect(_resolver_recompensa)
	pagina.add_child(globo)
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
	add_child(menu)
	menu.audio = audio
	menu.mostrar_inventario = _mostrar_inventario
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
	menu.ver_baraja.connect(ver_baraja)
	add_child(vista_baraja)
	vista_baraja.cerrada.connect(_baraja_cerrada)
	_registrar_pantallas()
	_configurar_lectura()
	entrar("entrada")
	_inicio_si_principal.call_deferred()

## De la más alta a la más baja. El velo acompaña al libro, la vitrina y la recompensa.
func _registrar_pantallas() -> void:
	pantallas.registrar(&"menu", func() -> bool: return menu.visible, menu)
	pantallas.registrar(&"baraja", func() -> bool: return vista_baraja.visible, vista_baraja)
	pantallas.registrar(&"cinematica", func() -> bool: return cinematica.activa, cinematica)
	pantallas.registrar(&"mesa", func() -> bool: return is_instance_valid(mesa))
	pantallas.registrar(&"recompensa", func() -> bool: return recompensa.visible, recompensa)
	pantallas.registrar(&"vitrina", func() -> bool: return vitrina.visible, vitrina)
	pantallas.registrar(&"libro", func() -> bool: return libro.visible, libro)
	pantallas.registrar(&"dialogo", func() -> bool: return dialogo.visible, dialogo)
	pantallas.registrar(&"velo", func() -> bool: return velo.visible, velo)
	pantallas.registrar(&"mapa", func() -> bool: return minimapa.ampliado)
	pantallas.cambiada.connect(actualizar_exploracion)
	cinematica.terminada.connect(func(_completa: bool) -> void: pantallas.avisar())

## El menú de inicio solo aparece al arrancar el juego, no cuando las pruebas montan el casino.
func _inicio_si_principal() -> void:
	if is_inside_tree() and get_tree().current_scene == self:
		guardado_activo = true
		abrir_inicio()

func abrir_inicio() -> void:
	menu.abrir("inicio")
	_congelar(true)

## Pausa con la sala libre o en una mano sin nada abierto. Congela sala, mesa y animaciones.
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
		for accion: Control in [mesa.boton_iniciar_pedir, mesa.boton_plantarse, mesa.boton_ayuda]:
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
	actualizar_exploracion()

## Vuelve a la pantalla de inicio. Con guardado, la partida queda guardada (una mesa en
## curso vuelve a como estaba al sentarse); sin él, se abandona el intento.
func volver_al_inicio() -> void:
	guardar()
	_quitar_mesa()
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
		_mostrar_recompensa(0, _linea_crupier("victoria"))
	return true

func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_CLOSE_REQUEST:
		guardar()

func _cambiar_movimiento(reducido: bool) -> void:
	if is_instance_valid(mesa):
		mesa.establecer_movimiento_reducido(reducido)
	_refrescar()

func entrar(destino: String, origen := "") -> void:
	if not CampanaCasino.NOMBRES.has(destino) or not campana.puerta_abierta(destino):
		return
	sala = destino
	audio.seleccionar_espacio(sala)
	visitante.position = exploracion.montar(sala, origen, campana, NotasCasino.titulo(sala))
	_refrescar()
	# P6: la primera vez que se pisa el vestíbulo, una cinemática lleva a la anfitriona.
	if sala == "vestibulo" and guardado_activo and campana.cumple("no:historia:vio_vestibulo"):
		reproducir_cinematica.call_deferred(GuionCasino.LLEGADA, _recepcion)

func cercano() -> Dictionary:
	return exploracion.cercano(visitante.position)

## Objetivo, minimapa y pista de la sala. Se recalcula cuando el visitante se mueve o cuando
## una pantalla se abre o se cierra, nunca en cada fotograma.
func actualizar_exploracion() -> void:
	indicador_objetivo.presentar(campana.objetivo(), not pantallas.alguna([&"mapa"]))
	var libre := not pantallas.alguna([&"mapa", &"velo", &"baraja"])
	minimapa.visible = libre
	if not libre:
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
	var tecla := Acciones.tecla(Acciones.INTERACTUAR)
	if elegido.tipo == "puerta":
		var cerrada: bool = (elegido.destino == "entrada" and campana.recibida) or not campana.puerta_abierta(elegido.destino)
		return "%s · %s" % [tecla, "Examinar la puerta" if cerrada else "Entrar"]
	if elegido.tipo == "visitante" and (campana.superadas >= 3 or (elegido.destino == "tobias" and campana.cumple("historia:tobias.estado=cobrado"))):
		return "%s · Examinar la figura" % tecla
	return "%s · %s" % [tecla, elegido.accion]

## Solo actúa la pantalla de arriba. Las que tienen su propia entrada (menú, mesa, vitrina,
## diálogo…) la resuelven antes, porque son hijas de este nodo; si la pausa llega aquí, pausa.
func _unhandled_input(evento: InputEvent) -> void:
	if not Acciones.es_pulsacion(evento):
		return
	var arriba := pantallas.superior()
	if arriba in [&"menu", &"baraja", &"recompensa"]:
		return
	if arriba == &"mapa":
		if evento.is_action_pressed(Acciones.MAPA) or evento.is_action_pressed(Acciones.VOLVER):
			_alternar_mapa()
		get_viewport().set_input_as_handled()
		return
	if evento.is_action_pressed(Acciones.PAUSA) and arriba != &"libro":
		pausar()
		get_viewport().set_input_as_handled()
		return
	if arriba == &"libro":
		if evento.is_action_pressed(Acciones.VOLVER) or (evento.is_action_pressed(Acciones.INVENTARIO) and libro.cierre == _cerrar):
			if libro.cierre.is_valid(): libro.cierre.call()
		elif evento.is_action_pressed(Acciones.INTERACTUAR) and libro.lista.get_child_count() == 1:
			libro.primero.pressed.emit()
		else:
			return
	elif arriba not in [&"", &"velo"]:
		return
	elif evento.is_action_pressed(Acciones.MAPA):
		_alternar_mapa()
	elif evento.is_action_pressed(Acciones.INTERACTUAR):
		var punto := cercano()
		if not punto.is_empty(): interactuar(punto)
	elif evento.is_action_pressed(Acciones.INVENTARIO):
		inventario()
	elif evento.is_action_pressed(Acciones.SONIDO):
		_sonido()
	else:
		return
	get_viewport().set_input_as_handled()

func _alternar_mapa() -> void:
	minimapa.ampliado = not minimapa.ampliado
	visitante.bloqueado = minimapa.ampliado
	pista.text = ""
	pantallas.avisar()

func interactuar(p: Dictionary) -> void:
	match p.tipo:
		"anfitriona": _recepcion()
		"tienda": tienda()
		"nota": examinar()
		"mesa": _presentar_jefe()
		"visitante": _hablar_visitante(p.destino)
		"salida":
			if campana.superadas == 4:
				audio.reproducir(&"puerta")
				_abrir("El primer amanecer", "El cerrojo cede. Por primera vez oyes pájaros en lugar de campanas. Has salido de la casa.", "", Callable())
				libro.opcion("Comenzar otro viaje", _nuevo_intento)
			else: _aviso_puerta("La verja del alba", "Falta vencer al Dueño de la Casa.")
		"puerta":
			if p.destino == "entrada" and campana.recibida:
				_aviso_puerta("La puerta de la calle", "Donde estaba la puerta solo queda su contorno grabado en el mármol. No hay picaporte.")
			elif campana.puerta_abierta(p.destino):
				audio.reproducir(&"puerta")
				entrar(p.destino, sala)
			else:
				_aviso_puerta(CampanaCasino.NOMBRES[p.destino], PlanoGaleria.requisito(p.destino))

## Abre una conversación en el diálogo de la sala; el visitante queda quieto mientras dure.
func _conversar(conversacion: Conversacion, describir := Callable(), barra_lectura := true) -> bool:
	visitante.bloqueado = dialogo.abrir(conversacion, _condicion, AjustesJuego.movimiento_reducido(), describir, barra_lectura)
	return visitante.bloqueado

func _hablar_visitante(id: String) -> void:
	var encuentro := GuionCasino.visitante(id, campana.superadas)
	if encuentro != null and not dialogo.visible and not cinematica.activa:
		_conversar(encuentro)

func _aviso_puerta(titulo_puerta: String, mensaje: String) -> void:
	_conversar(GuionCasino.aviso_puerta(titulo_puerta, mensaje), Callable(), false)

## Conversación con la anfitriona en la escena de diálogos (I4-06); sus líneas son datos.
func _recepcion() -> void:
	visitante.bloqueado = true
	if dialogo.visible or cinematica.activa:
		return
	_conversar(GuionCasino.ANFITRIONA, GuionCasino.describir_opcion)

## Una elección del diálogo pide un cambio; la campaña comprueba si corresponde.
func _solicitud(id: String) -> void:
	if id == "tomar_asiento":
		_jugar()
		return
	if id == "ver_recuerdo":
		if GuionCasino.RECUERDOS.has(sala) and _condicion("mesa_superada"):
			reproducir_cinematica(GuionCasino.RECUERDOS[sala], _volver_del_recuerdo.bind(sala))
		return
	if campana.atender(id):
		if not id.begins_with("historia:"):
			audio.reproducir(&"sello")
		_refrescar()

func _condicion(condicion: String) -> bool:
	return GuionCasino.condicion(condicion, sala, campana)

func _formatear(texto: String) -> String:
	return GuionCasino.formatear(texto, sala, campana)

func _linea_crupier(id: String) -> String:
	return GuionCasino.linea_crupier(id, sala, campana)

## Ajustes de lectura de Opciones para las conversaciones, las cinemáticas y la mesa.
func _configurar_lectura() -> void:
	var ajustes := AjustesJuego.ajustes_dialogo()
	dialogo.configurar(ajustes)
	historia.configurar(ajustes)
	if is_instance_valid(mesa):
		mesa.comentarios = AjustesJuego.comentarios_crupieres()
		mesa.consejos = AjustesJuego.consejos()

func _sonar(id: String) -> void:
	audio.reproducir(StringName(id))

## Examinar una nota: escena de novela visual con la ilustración del objeto y su descripción.
func examinar() -> void:
	var escena := NotasCasino.escena(sala, campana)
	if escena != null:
		reproducir_cinematica(escena)

## Prólogo de novela visual antes de la entrada (I5-10). Al terminar o saltarlo, el jugador
## aparece frente a la fachada con el control.
func iniciar_prologo() -> void:
	reproducir_cinematica(GuionCasino.PROLOGO)

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

func _fin_cinematica(_completa: bool) -> void:
	_cerrar()
	var despues := _tras_cinematica
	_tras_cinematica = Callable()
	if despues.is_valid():
		despues.call()

func _volver_del_recuerdo(jefe: String) -> void:
	if sala == jefe:
		_conversar(GuionCasino.revisita(jefe))

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
	if not _conversar(GuionCasino.CRUPIERES[sala]):
		return
	if not _condicion("mesa_superada"):
		dialogo.poner_anexo(CifrasMesa.new(CampanaCasino.MESAS_CAMPANA.de(sala)))

func _jugar() -> void:
	guardar() # Si el juego se cierra en la mesa, se continúa frente al crupier.
	if not campana.iniciar(sala): return
	_cerrar()
	visitante.bloqueado = true
	pagina.hide()
	mesa = Mesa.instantiate() as MesaUI
	mesa.campana = campana
	mesa.comentarios = AjustesJuego.comentarios_crupieres()
	mesa.consejos = AjustesJuego.consejos()
	mesa.salir_de_mesa.connect(_levantarse, CONNECT_ONE_SHOT)
	add_child(mesa)
	mesa.activar_audio(audio)
	audio.seleccionar_espacio(sala, true)
	mesa.establecer_movimiento_reducido(AjustesJuego.movimiento_reducido())
	pantallas.avisar()

func _quitar_mesa() -> void:
	if not is_instance_valid(mesa):
		return
	remove_child(mesa)
	mesa.queue_free()
	mesa = null
	pagina.show()
	pantallas.avisar()

func _levantarse(victoria: bool, exactos: int) -> void:
	var premio := campana.cerrar(victoria, exactos)
	var ultima_mesa: Image
	if not victoria and DisplayServer.get_name() != "headless":
		ultima_mesa = get_viewport().get_texture().get_image()
	_quitar_mesa()
	visitante.bloqueado = false
	audio.seleccionar_espacio(sala)
	_refrescar()
	if victoria:
		var ruta := "Dirígete al portón del norte." if campana.superadas == 4 else "La siguiente sala está abierta."
		var dicho := _linea_crupier("victoria")
		if campana.hay_recompensa():
			_mostrar_recompensa(premio, dicho)
		else:
			_aviso("Mesa superada", "%s\n\n+%s fichas · %s" % [dicho, premio, ruta])
	else:
		if guardado_activo:
			PartidaGuardada.borrar()
		reproducir_cinematica(GuionCasino.derrota(sala, campana, ultima_mesa), _nuevo_intento)

## La frase de victoria del crupier acompaña la elección; sus preguntas quedan para la revisita.
func _mostrar_recompensa(premio: int, dicho := "") -> void:
	_preparar_libro()
	recompensa.movimiento_reducido = AjustesJuego.movimiento_reducido()
	recompensa.presentar(sala, dicho, premio, campana.superadas, campana.opciones_recompensa(), campana.baraja)
	var primera: Control = recompensa.cartas[0]
	var ultima: Control = recompensa.cartas[-1]
	# La flecha apunta a la última carta para no tapar el título de la pantalla.
	_consejo("recompensa", Rect2(primera.position, ultima.position + ultima.size - primera.position), Rect2(ultima.position, ultima.size))

func _resolver_recompensa(indice: int) -> void:
	if campana.resolver_recompensa(indice):
		audio.reproducir(&"naipe" if indice >= 0 else &"interfaz")
		recompensa.hide()
		_cerrar()

func _sonido() -> void:
	if libro.visible:
		return
	_abrir("Sonido", "Ajusta el volumen de cada canal.", "", _cerrar)
	audio.reproducir(&"interfaz")
	var controles := ControlesSonido.new()
	controles.construir(audio)
	libro.lista.add_child(controles)
	libro.opcion("Volver al casino", _cerrar)

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

func _aviso(t: String, mensaje: String, foto := "") -> void:
	_abrir(t, mensaje, foto, _cerrar)
	libro.opcion("Continuar", _cerrar)

func _cerrar() -> void:
	minimapa.ampliado = false
	globo.ocultar()
	vitrina.hide()
	recompensa.hide()
	dialogo.hide()
	dialogo.poner_anexo(null)
	libro.hide()
	velo.hide()
	# Al tomar asiento desde el diálogo, este se cierra con la mesa ya abierta.
	visitante.bloqueado = is_instance_valid(mesa) or cinematica.activa
	_refrescar()

func _refrescar() -> void:
	titulo.text = CampanaCasino.NOMBRES.get(sala, "")
	hud.presentar(campana, AjustesJuego.movimiento_reducido())
	actualizar_exploracion()
	guardar()

func inventario() -> void:
	_preparar_libro()
	libro.presentar("Tus pertenencias", "", "", _cerrar, 390.0)
	_mostrar_inventario(libro.lista)
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

func _baraja_cerrada() -> void:
	var previo = _foco_baraja
	_foco_baraja = null
	if _enfocable(previo):
		previo.grab_focus()

## Proyección pública de la baraja; durante una mano, sin delatar las Máscaras.
func datos_baraja() -> Dictionary:
	return campana.proyeccion_baraja(is_instance_valid(mesa))

func _mostrar_inventario(destino: Control) -> void:
	var panel := InventarioCampana.new()
	panel.presentar(campana)
	destino.add_child(panel)

func tienda() -> void:
	if not campana.recibida:
		_aviso("Mostrador cerrado", "Presenta primero tu invitación en el vestíbulo.")
		return
	_preparar_libro()
	vitrina.abrir(campana)
	_consejo_tienda.call_deferred() # Tras colocar las fichas de la vitrina.

func _consejo_tienda() -> void:
	if not vitrina.visible:
		return
	var origen := pagina.get_global_transform().affine_inverse()
	var objetos := (origen * vitrina.fichas[0].get_global_rect()).merge(origen * vitrina.fichas[-1].get_global_rect())
	# A la derecha, sobre el detalle aún vacío, sin tapar el título del gabinete.
	_consejo("tienda", objetos, Rect2(), true)

## Consejo del tutorial en contexto fuera de la mesa: una vez y si Opciones lo permite.
func _consejo(id: String, objetivo: Rect2, ancla := Rect2(), a_la_derecha := false) -> void:
	if not AjustesJuego.consejos() or AjustesJuego.consejos_vistos().has(id):
		return
	AjustesJuego.marcar_consejo(id)
	globo.senalar(id, Consejos.texto(id), objetivo, AjustesJuego.movimiento_reducido(), ancla, a_la_derecha)
