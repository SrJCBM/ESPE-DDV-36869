class_name MesaUI
extends Control
## Adaptador visual: toda decisión y cálculo pertenece al controlador. El lienzo mide BASE y el
## proyecto lo escala a la ventana; los atajos se leen del mapa de entrada (Acciones).

const Controlador = preload("res://mesa/controlador_mesa.gd")
const Iniciar = preload("res://dominio/comandos/iniciar_mano.gd")
const Pedir = preload("res://dominio/comandos/pedir_carta.gd")
const ComandoPlantarse = preload("res://dominio/comandos/plantarse.gd")
const Devolver = preload("res://dominio/comandos/devolver_llave.gd")
const Carta = preload("res://cartas/carta.tscn")
const Guia = preload("res://mesa/guia_custodio.gd")
const Lectura = preload("res://mesa/lectura_mesa.gd")
const Piezas = preload("res://mesa/piezas_mesa.gd")
const Desglose = preload("res://mesa/desglose_mano.gd")
const PlacaRegla = preload("res://mesa/placa_regla.gd")
const Respuesta = preload("res://mesa/respuesta_resultado.gd")
const FranjaPatrones := preload("res://mesa/interfaz/franja_patrones.gd")
const EleccionLlave := preload("res://mesa/interfaz/eleccion_llave.gd")
const RevelacionMano := preload("res://mesa/interfaz/revelacion_mano.gd")
const ManoMesa := preload("res://mesa/interfaz/mano_mesa.gd")
const ModalMesa := preload("res://mesa/interfaz/modal_mesa.gd")
const HudCampana := preload("res://casino/interfaz/hud/hud_campana.gd")
const InventarioMesa := preload("res://mesa/interfaz/inventario_mesa.gd")
const DialCampanadas := preload("res://mesa/interfaz/dial_campanadas.gd")
const C := preload("res://mesa/interfaz/composicion_mesa.gd")
const TAPETES := {
	"custodio": "res://mesa/arte/tapete_custodio_i6.webp",
	"recaudador": "res://mesa/arte/tapete_recaudador.webp",
	"coleccionista": "res://mesa/arte/tapete_coleccionista.webp",
	"dueno": "res://mesa/arte/tapete_dueno.webp",
}
const ORO := Piezas.ORO
const MARFIL := Piezas.MARFIL
const MUTED := Piezas.MUTED
const TINTA := Piezas.TINTA
const BASE := Vector2(1440, 810)
const BocadilloCrupier := preload("res://mesa/interfaz/bocadillo_crupier.gd")
## Reacciones del crupier durante la mano (I6-10, guion §9).
const REACCIONES: ReaccionesCrupier = preload("res://datos/reacciones/reacciones.tres")
## Encima del retrato, con la cola hacia su rostro.
const LUGAR_BOCADILLO := Vector2(34, 132)

signal salir_de_mesa(victoria: bool, exactos: int)
var campana: CampanaCasino
var audio: AudioCasino
var boton_lente: Button

@export var conectar_controlador := true
var controlador: Node
var vista: Dictionary = {}
var bocadillo: Control
## Última línea dicha por disparador, para no repetirla.
var _ultimas_reacciones := {}
var _azar_reacciones := RandomNumberGenerator.new()
## Tutorial en contexto (Consejos): solo cuando el casino lo activa según Opciones.
var consejos := false
var globo: GloboConsejo
## Si es false, la mesa no comenta (Opciones · Comentarios de los crupieres).
var comentarios := true:
	set(activos):
		comentarios = activos
		if not activos and is_instance_valid(bocadillo):
			bocadillo.ocultar()
var lienzo: Control
var boton_iniciar_pedir: Button
var boton_plantarse: Button
var boton_ayuda: Button
var boton_reiniciar: Button
var boton_demostracion: Button
var boton_desglose: Button
## Abre y cierra la consulta de patrones (I6-04). T hace lo mismo.
var boton_patrones: Button
## Patrón cercano junto a la mano, p. ej. «Mano larga · 4/5».
var _cercano: Label
var _franja_fondo: Panel
var mano: ManoMesa
var _titulo_estado: Label
var _contador: Label
var _presupuesto: Label
var _meta: Label
var _puntos: Label
var _umbral: Label
var _lectura: Label
var _lectura_titulo: Label
var _explicacion: Label
var _mensaje: Label
var _mazo: Label
var _subtitulo: Label
## Sellos y saldo de la campaña (I4-04); solo existe dentro del casino.
var hud: HudCampana
var modal: ModalMesa
var movimiento_reducido := false
var _progreso: ProgressBar
## Dial de campanadas con el aro que gira al gastar una (I4-05).
var dial: DialCampanadas
var boleto: TextureRect
var tapete: TextureRect
var _transicion_progreso: Tween
var franja_patrones: FranjaPatrones
var eleccion_llave: EleccionLlave
var revelacion: RevelacionMano
## Respuesta visual al resolver y aviso del cambio de umbral (respuesta_resultado.gd).
var _respuesta: Respuesta
## La cuenta de puntos en curso, o null si no hay ninguna. Solo la leen las pruebas.
@warning_ignore("unused_private_class_variable")
var _feedback: Tween:
	get: return _respuesta.tween if _respuesta != null else null
## Placa con la regla del crupier sobre el pie del retrato (placa_regla.gd).
var _regla: PlacaRegla
var _regla_texto: Label
var _nota_umbral: Label

func _ready() -> void:
	_construir()
	if conectar_controlador:
		controlador = Controlador.new()
		if campana != null: controlador.configurar_campana(campana)
		controlador.name = "ControladorMesa"
		add_child(controlador)
		controlador.vista_actualizada.connect(presentar_vista)
		presentar_vista(controlador.obtener_vista())
	boton_iniciar_pedir.grab_focus()

func activar_audio(servicio: AudioCasino) -> void:
	# El volumen vive en Opciones del menú de pausa (I4-07); V sigue abriendo el panel aquí.
	audio = servicio

func _sonido() -> void:
	if audio == null or revelacion.activa or modal.visible:
		return
	_abrir_modal("Sonido")
	audio.reproducir(&"interfaz")
	var controles := ControlesSonido.new()
	controles.position = Vector2(36, 110)
	controles.size.x = 680
	modal.contenido.add_child(controles)
	controles.construir(audio)
	modal.boton_cerrar()

func _construir() -> void:
	var fondo := ColorRect.new()
	fondo.color = Color("0b2119")
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fondo)
	lienzo = Control.new()
	lienzo.name = "LienzoMesa"
	lienzo.size = BASE
	add_child(lienzo)
	Piezas.imagen(lienzo, "res://mesa/arte/marco-casino.svg", Rect2(24, 24, 1391, 761))
	# El título del juego queda solo en el menú de inicio; la esquina nombra la mesa.
	_subtitulo = Piezas.etiqueta(lienzo, "MESA I  /  EL PRIMER SELLO", Rect2(44, 41, 480, 22), 13, MUTED)
	boton_reiniciar = Piezas.boton_texto(lienzo, "boton_reiniciar", Acciones.rotulo("REINICIAR", Acciones.REINICIAR), Rect2(1025, 32, 158, 38), _solicitar_reinicio)
	boton_ayuda = Piezas.boton_texto(lienzo, "boton_ayuda", Acciones.rotulo("CÓMO JUGAR", Acciones.AYUDA), Rect2(1200, 32, 195, 38), mostrar_ayuda)
	boton_demostracion = Piezas.boton_texto(lienzo, "boton_demostracion", "DEMOSTRACIÓN GUIADA", Rect2(531, 66, 245, 30), _solicitar_demostracion)
	boton_demostracion.tooltip_text = "Cargar una secuencia preparada para aprender las reglas. Reinicia el intento."
	var retrato := "res://recursos/arte/custodio-grabado.png"
	var nombre := "El Custodio"
	if campana != null:
		nombre = CampanaCasino.NOMBRES[campana.activa]
		if campana.activa != "custodio": retrato = "res://casino/arte/personaje_%s.webp" % campana.activa
		boton_demostracion.hide()
		boton_reiniciar.hide()
		Piezas.boton_texto(lienzo, "bolsa_campana", Acciones.rotulo("OBJETOS", Acciones.INVENTARIO), Rect2(1025, 32, 158, 38), _ver_objetos)
		_subtitulo.hide()
		hud = HudCampana.new()
		hud.position = Vector2(560, 30)
		hud.size = Vector2(440, 40)
		lienzo.add_child(hud)
		boton_lente = Piezas.boton_texto(lienzo, "boton_lente", "LENTE", Rect2(510, 66, 340, 36), _usar_lente, 15)
	Piezas.imagen(lienzo, retrato, Rect2(22, 124, 356, 534), true)
	_construir_regla()
	bocadillo = BocadilloCrupier.new()
	bocadillo.position = LUGAR_BOCADILLO
	lienzo.add_child(bocadillo)
	Piezas.etiqueta(lienzo, nombre, C.NOMBRE, 46, MARFIL, true)
	_titulo_estado = Piezas.etiqueta(lienzo, "", C.ESTADO, 16, ORO)
	_cercano = Piezas.etiqueta(lienzo, "", C.CERCANO, 16, MARFIL)
	_cercano.name = "PatronCercano"
	_cercano.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var id_tapete := campana.activa if campana != null else "custodio"
	tapete = Piezas.imagen(lienzo, TAPETES.get(id_tapete, TAPETES.custodio), C.TAPETE)
	tapete.name = "Tapete"
	_umbral = Piezas.etiqueta(lienzo, "", Rect2(32, 660, 115, 112), 88, ORO, true)
	Piezas.etiqueta(lienzo, "UMBRAL", Rect2(155, 671, 215, 28), 18, ORO)
	_nota_umbral = Piezas.etiqueta(lienzo, "", Rect2(155, 703, 215, 29), 20, MUTED)
	dial = DialCampanadas.new(C.DIAL.size.x)
	dial.position = C.DIAL.position
	lienzo.add_child(dial)
	_contador = dial.cifra
	_presupuesto = dial.presupuesto
	var rotulo_dial := Piezas.etiqueta(lienzo, "CAMPANADAS", C.ETIQUETA_DIAL, 17, ORO)
	rotulo_dial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Boleto compacto alrededor de «acumulado / meta» y su barra.
	boleto = Piezas.imagen(lienzo, "res://mesa/arte/boleto.svg", C.BOLETO)
	boleto.name = "Boleto"
	Piezas.etiqueta(lienzo, "ACUMULADO / META", C.BOLETO_TITULO, 12, TINTA)
	_meta = Piezas.etiqueta(lienzo, "", C.BOLETO_TITULO, 12, TINTA)
	_meta.hide()
	_puntos = Piezas.etiqueta(lienzo, "", C.BOLETO_PUNTOS, 38, TINTA, true)
	_progreso = ProgressBar.new()
	_progreso.position = C.BOLETO_BARRA.position
	_progreso.show_percentage = false
	_progreso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pista := StyleBoxFlat.new()
	pista.bg_color = Color("b8aa89")
	_progreso.add_theme_stylebox_override("background", pista)
	var avance := StyleBoxFlat.new()
	avance.bg_color = TINTA
	_progreso.add_theme_stylebox_override("fill", avance)
	lienzo.add_child(_progreso)
	_progreso.size = C.BOLETO_BARRA.size
	boton_desglose = Piezas.boton_texto(lienzo, "boton_desglose", "VER DESGLOSE", C.DESGLOSE, mostrar_desglose, 14)
	boton_desglose.hide()
	modal = ModalMesa.new()
	mano = ManoMesa.new()
	mano.configurar(func() -> bool: return modal.visible)
	mano.carta_activada.connect(_activar_carta)
	mano.carta_creada.connect(modal.suspender_si_abierto)
	lienzo.add_child(mano)
	mano.colocar(C.MANO, C.ALTO_CARTA)
	var franja_fondo := Panel.new()
	franja_fondo.name = "FranjaPatrones"
	franja_fondo.position = C.FRANJA.position
	franja_fondo.size = C.FRANJA.size
	franja_fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var oscuro := StyleBoxFlat.new()
	oscuro.bg_color = Color(0.02, 0.07, 0.05, 0.72)
	oscuro.set_corner_radius_all(4)
	franja_fondo.add_theme_stylebox_override("panel", oscuro)
	lienzo.add_child(franja_fondo)
	_franja_fondo = franja_fondo
	franja_fondo.hide()
	franja_patrones = FranjaPatrones.new()
	lienzo.add_child(franja_patrones)
	franja_patrones.configurar(mano.fila, _puede_resaltar_patrones)
	franja_patrones.position = C.PATRONES.position
	franja_patrones.size = C.PATRONES.size
	franja_patrones.detalle_cambiado.connect(_mostrar_detalle_patron)
	franja_patrones.patron_solicitado.connect(_mostrar_patron)
	franja_patrones.boton_creado.connect(modal.suspender_si_abierto)
	# T lleva el foco a los patrones y lo devuelve a la acción; no hay botón que los abra.
	boton_patrones = Piezas.boton_texto(lienzo, "boton_patrones", Acciones.rotulo("PATRONES", Acciones.PATRONES), Rect2(990, 610, 150, 34), alternar_patrones)
	boton_patrones.hide()
	_lectura_titulo = Piezas.etiqueta(lienzo, "SIGUIENTE PASO", C.LECTURA_TITULO, 12, MUTED)
	_lectura_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lectura = Piezas.etiqueta(lienzo, "—", C.LECTURA, 36, MARFIL, true)
	_explicacion = Piezas.etiqueta(lienzo, "", C.EXPLICACION, 16, MUTED)
	_explicacion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mensaje = Piezas.etiqueta(lienzo, "", C.DETALLE, 16, MUTED)
	_mensaje.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Acciones apiladas a la derecha, bajo el boleto: solo la acción, su atajo y un coste real.
	boton_iniciar_pedir = Piezas.boton_accion(lienzo, "boton_iniciar_pedir", C.PEDIR, true, _iniciar_o_pedir, Acciones.tecla(Acciones.PEDIR))
	boton_plantarse = Piezas.boton_accion(lienzo, "boton_plantarse", C.PLANTARSE, false, _plantarse, Acciones.tecla(Acciones.PLANTARSE))
	Piezas.texto_accion(boton_plantarse, "PLANTARSE", "")
	_mazo = Piezas.etiqueta(lienzo, "", Rect2(40, 780, 350, 24), 12, MUTED)
	_mazo.name = "Mazo"
	_respuesta = Respuesta.new(_lectura, _puntos, _umbral)
	_respuesta.boleto = boleto
	add_child(_respuesta)
	eleccion_llave = EleccionLlave.new()
	lienzo.add_child(eleccion_llave)
	eleccion_llave.configurar(lienzo, mano.fila, mano.scroll)
	eleccion_llave.seleccion_cambiada.connect(_cambio_eleccion_llave)
	eleccion_llave.devolucion_solicitada.connect(func(id: String) -> void: _enviar(Devolver.new(id)))
	revelacion = RevelacionMano.new()
	add_child(revelacion)
	revelacion.iniciada.connect(_iniciar_revelacion)
	revelacion.carta_revelada.connect(_mostrar_carta_revelada)
	revelacion.terminada.connect(_pintar_vista)
	modal.name = "Modal"
	modal.foco_requerido.connect(_enfocar_accion_legal)
	lienzo.add_child(modal)
	globo = GloboConsejo.new()
	lienzo.add_child(globo)

func presentar_vista(nueva_vista: Dictionary) -> void:
	revelacion.presentar(vista, nueva_vista, movimiento_reducido)

func _iniciar_revelacion() -> void:
	globo.ocultar()
	franja_patrones.limpiar()
	eleccion_llave.cancelar(false)
	_titulo_estado.text = "LA CASA REVELA TU MANO"
	_lectura_titulo.text = "REVELANDO"
	_mensaje.hide()
	boton_iniciar_pedir.disabled = true
	boton_iniciar_pedir.get_node("Fondo").modulate.a = 0.55
	boton_plantarse.disabled = false
	Piezas.texto_accion(boton_plantarse, "MOSTRAR RESULTADO", "")

func _mostrar_carta_revelada(indice: int, datos: Dictionary) -> void:
	var reveladas := mano.revelar(indice, datos)
	if audio != null:
		audio.reproducir(&"naipe")
	_lectura_titulo.text = "SUMA REVELADA"
	_lectura.text = str(reveladas.suma) + (" + ?" if reveladas.ocultas > 0 else "")
	_explicacion.text = "%s por revelar" % reveladas.ocultas if reveladas.ocultas > 0 else ""

## El comentario vigente se retira al actuar. Solo se muestra la reacción más relevante.
func _reaccionar(previa: Dictionary, nueva: Dictionary) -> void:
	if not is_instance_valid(bocadillo):
		return
	bocadillo.ocultar()
	if not comentarios:
		return
	var crupier: String = campana.activa if campana != null and not campana.activa.is_empty() else "custodio"
	for id in ReaccionesCrupier.disparadores(previa, nueva):
		if id in ["iniciar_mano", "pedir", "plantarse_pronto"] and _azar_reacciones.randf() > 0.35:
			continue
		var linea := REACCIONES.linea(crupier, id, str(_ultimas_reacciones.get(id, "")), _azar_reacciones)
		if linea.is_empty():
			continue
		_ultimas_reacciones[id] = linea
		var usadas := int(nueva.get("presupuesto", 0)) - int(nueva.get("campanadas", 0))
		bocadillo.mostrar(CampanaCasino.NOMBRES.get(crupier, ""), linea.format({
			"umbral": nueva.get("umbral_siguiente", nueva.get("umbral", 0)), "usadas": usadas,
		}))
		break

func _pintar_vista(nueva_vista: Dictionary) -> void:
	if not is_instance_valid(lienzo):
		return
	franja_patrones.limpiar()
	_respuesta.detener()
	var umbral_previo: int = int(vista.get("umbral", 0))
	var mesa_previa: String = str(vista.get("mesa", ""))
	var recien_resuelta: bool = vista.get("fase", "") == "decision" and nueva_vista.get("fase", "") != "decision" and not nueva_vista.get("ultima_mano", {}).is_empty()
	if recien_resuelta and audio != null:
		var ultima: Dictionary = nueva_vista.ultima_mano
		if ultima.quiebra: audio.reproducir(&"quiebra")
		elif nueva_vista.get("victoria", false) or "Punto exacto" in ultima.patrones: audio.reproducir(&"sello")
	var puntos_previos: int = int(vista.get("puntos", 0))
	var vista_previa := vista
	globo.ocultar()
	_reaccionar(vista, nueva_vista)
	vista = nueva_vista.duplicate(true)
	eleccion_llave.presentar(vista)
	var acciones: Dictionary = vista.get("acciones", {})
	var fase: String = vista.get("fase", "preparado")
	var terminada: bool = vista.get("terminado", false)
	if _transicion_progreso != null and _transicion_progreso.is_valid():
		_transicion_progreso.kill()
	_progreso.max_value = float(vista.get("meta", 200))
	var destino := float(vista.get("puntos", 0))
	if movimiento_reducido or destino == 0:
		_progreso.value = destino
	else:
		_transicion_progreso = create_tween()
		_transicion_progreso.tween_property(_progreso, "value", destino, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var texto_presupuesto := "ÚLTIMA MANO" if fase == "decision" and int(vista.get("campanadas", 0)) == 0 else "DE %s" % vista.get("presupuesto", 10)
	dial.presentar(int(vista.get("campanadas", 0)), int(vista.get("presupuesto", 10)), int(vista.get("numero_mano", 0)), texto_presupuesto, movimiento_reducido)
	_meta.text = str(vista.get("meta", 200))
	_puntos.text = "%s / %s" % [vista.get("puntos", 0), vista.get("meta", 200)]
	_umbral.text = str(vista.get("umbral", 17))
	_presentar_regla(umbral_previo, mesa_previa)
	_mazo.text = "MAZO %s  ·  DESCARTE %s" % [vista.get("mazo", 0), vista.get("descarte", 0)]
	_subtitulo.text = "MESA I  /  EL PRIMER SELLO" + ("  ·  DEMOSTRACIÓN" if vista.get("modo_demostracion", false) else "")
	boton_iniciar_pedir.disabled = not bool(acciones.get("iniciar", false) or acciones.get("pedir", false))
	boton_plantarse.disabled = not bool(acciones.get("plantarse", false))
	if campana != null:
		hud.presentar(campana, movimiento_reducido)
		boton_lente.text = "USAR LENTE DE HUMO (%s)" % campana.lentes
		boton_lente.visible = campana.lentes > 0
		boton_lente.disabled = fase != "decision" or int(vista.intervalo.ocultas) == 0
	boton_reiniciar.disabled = not bool(acciones.get("reiniciar", true))
	Piezas.texto_accion(boton_iniciar_pedir, "PEDIR" if fase == "decision" else "INICIAR MANO", ("−1 ficha" if vista.get("comision", false) else "") if fase == "decision" else "−1 campanada")
	boton_plantarse.visible = fase == "decision"
	for boton in [boton_iniciar_pedir, boton_plantarse]:
		boton.get_node("Fondo").modulate.a = 0.55 if boton.disabled else 1.0
	_titulo_estado.text = "VICTORIA · EL PRIMER SELLO ES TUYO" if vista.get("victoria", false) else ("DERROTA · FIN DEL INTENTO" if terminada else ("MANO %s" % vista.get("numero_mano", 1) if fase == "decision" else ""))
	if campana != null and vista.get("victoria", false): _titulo_estado.text = "VICTORIA · MESA SUPERADA"
	var cartas: Array = vista.get("cartas", [])
	mano.presentar(cartas, vista.get("llaves_disponibles", []), movimiento_reducido, fase != "decision" and not cartas.is_empty())
	_presentar_lectura(cartas)
	_actualizar_orientacion()
	franja_patrones.presentar(vista)
	mano.objetivo.text = "Meta %s  ·  umbral %s" % [vista.get("meta", 200), vista.get("umbral", 17)]
	_sincronizar_consulta()
	if not modal.visible:
		var actual := get_viewport().gui_get_focus_owner()
		if terminada or actual == null or not actual.is_visible_in_tree() or (actual is BaseButton and actual.disabled):
			_enfocar_accion_legal()
	if recien_resuelta and not movimiento_reducido and not modal.visible:
		_respuesta.celebrar(vista, mano.fila.get_children(), puntos_previos)
	_mostrar_consejo(vista_previa, vista)

## Un consejo del tutorial, una sola vez, señalando la parte de la mesa de la que habla.
func _mostrar_consejo(previa: Dictionary, nueva: Dictionary) -> void:
	if not consejos or modal.visible:
		return
	var id := Consejos.en_mesa(previa, nueva, AjustesJuego.consejos_vistos())
	if id.is_empty():
		return
	var objetivo: Rect2
	match id:
		"umbral": objetivo = Rect2(32, 664, 340, 100)
		"pedir": objetivo = _rect_en_lienzo(boton_iniciar_pedir).merge(_rect_en_lienzo(boton_plantarse))
		"llave", "mascara": objetivo = C.MANO
		"quiebra": objetivo = C.RESULTADO
		"patron": objetivo = _rect_en_lienzo(franja_patrones)
		"campanadas": objetivo = _rect_en_lienzo(dial)
		_: return
	AjustesJuego.marcar_consejo(id)
	globo.senalar(id, Consejos.texto(id), objetivo, movimiento_reducido)
	# El globo ya lo dice: la pista de abajo no lo repite mientras se ve.
	_mensaje.hide()

func _rect_en_lienzo(control: Control) -> Rect2:
	return lienzo.get_global_transform().affine_inverse() * control.get_global_rect()

func _presentar_lectura(cartas: Array) -> void:
	var intervalo: Dictionary = vista.get("intervalo", {})
	boton_desglose.visible = _hay_resultado_revelado()
	_lectura.position = C.LECTURA.position
	_lectura.size = C.LECTURA.size
	_lectura_titulo.visible = not cartas.is_empty() and not boton_desglose.visible
	_lectura.visible = not cartas.is_empty()
	_explicacion.position = C.EXPLICACION.position
	_explicacion.size = C.EXPLICACION.size
	_explicacion.tooltip_text = ""
	if boton_desglose.visible:
		var lectura: Dictionary = Lectura.resultado(vista)
		_lectura.position = C.RESULTADO.position
		_lectura.size = C.RESULTADO.size
		_lectura.text = lectura.formula
		_lectura.add_theme_font_size_override("font_size", 34)
		_explicacion.position = C.RESULTADO_DETALLE.position
		_explicacion.size = C.RESULTADO_DETALLE.size
		_explicacion.text = lectura.detalle
		_explicacion.tooltip_text = lectura.completo
	else:
		_lectura_titulo.text = "TOTAL POSIBLE" if intervalo.get("ocultas", 0) > 0 else ("SUMA EFECTIVA" if not cartas.is_empty() else "SIGUIENTE PASO")
		# Intervalo y umbral juntos: se comparan sin buscar el umbral en otra esquina.
		if not cartas.is_empty(): _lectura_titulo.text += "\nUMBRAL %s" % vista.get("umbral", 17)
		_lectura.text = "%s–%s" % [intervalo.get("minimo", 0), intervalo.get("maximo", 0)] if intervalo.get("ocultas", 0) > 0 else (str(intervalo.get("conocido", 0)) if not cartas.is_empty() else "—")
		_lectura.add_theme_font_size_override("font_size", 36)
		_explicacion.text = ""
		if intervalo.get("ocultas", 0) > 0:
			var conocidas := "%s + ?" % intervalo.get("conocido", 0)
			if int(intervalo.get("ocultas", 0)) > 1:
				conocidas += " × %s" % intervalo.get("ocultas", 0)
			var ocultas: int = int(intervalo.get("ocultas", 0))
			_explicacion.text = conocidas + "\n%s %s" % [ocultas, "oculta" if ocultas == 1 else "ocultas"]
	_explicacion.visible = not _explicacion.text.is_empty()

## Patrones siempre a la vista (revisión de pantallas): T lleva el foco al primer patrón y, si
## ya estaba en ellos, lo devuelve a la acción. Esc también lo devuelve.
func alternar_patrones() -> void:
	if franja_patrones.tiene_foco():
		cerrar_patrones()
	else:
		abrir_patrones()

func abrir_patrones() -> void:
	if not franja_patrones.visible or modal.visible or revelacion.activa or not eleccion_llave.seleccionada.is_empty():
		return
	for boton in franja_patrones.get_children():
		if boton.visible:
			boton.grab_focus()
			return

func cerrar_patrones(enfocar := true) -> void:
	var tenia_foco := franja_patrones.tiene_foco()
	franja_patrones.limpiar()
	if tenia_foco:
		_actualizar_orientacion()
		if enfocar: _enfocar_accion_legal()

## La franja se ve siempre que hay cartas, en su propia fila: nunca tapa la lectura.
func _sincronizar_consulta() -> void:
	franja_patrones.abierta = not vista.get("cartas", []).is_empty()
	franja_patrones.ocultar_por_seleccion(false)
	_franja_fondo.visible = franja_patrones.visible
	boton_patrones.hide()
	_mensaje.size = C.DETALLE.size
	# El progreso de cada patrón ya se lee en la franja: no se repite sobre el tapete.
	_cercano.text = ""

func _construir_regla() -> void:
	_regla = PlacaRegla.new()
	lienzo.add_child(_regla)
	_regla_texto = _regla.texto

func _presentar_regla(umbral_previo: int, mesa_previa: String) -> void:
	var regla: Dictionary = Lectura.regla(vista)
	_regla.mostrar(str(regla.texto))
	_nota_umbral.text = regla.nota
	var umbral := int(vista.get("umbral", 17))
	if umbral_previo > 0 and umbral != umbral_previo and mesa_previa == str(vista.get("mesa", "")):
		_respuesta.avisar_cambio_umbral(movimiento_reducido)

func _hay_resultado_revelado() -> bool:
	if vista.get("fase", "preparado") == "decision" or vista.get("ultima_mano", {}).is_empty():
		return false
	for carta in vista.get("cartas", []):
		if carta.get("oculta", false):
			return false
	return true

func mostrar_desglose() -> void:
	revelacion.terminar()
	if not _hay_resultado_revelado():
		return
	_abrir_modal("DESGLOSE · MANO RESUELTA", Rect2(250, 62, 940, 686))
	Desglose.construir(modal.contenido, vista)
	var cerrar := modal.boton_cerrar()
	cerrar.size.x = 876

func _enfocar_accion_legal() -> void:
	var candidatos: Array = [boton_iniciar_pedir, boton_plantarse, boton_reiniciar]
	if vista.get("terminado", false):
		candidatos = [boton_iniciar_pedir, boton_reiniciar]
	for boton in candidatos:
		if boton.visible and not boton.disabled and boton.focus_mode != Control.FOCUS_NONE:
			boton.grab_focus()
			return
	boton_ayuda.grab_focus()

func _enviar(comando: RefCounted) -> void:
	if revelacion.activa or not is_instance_valid(controlador):
		return
	var resultado = controlador.procesar_comando(comando)
	if not resultado.aceptado:
		_mensaje.text = resultado.motivo
		_mensaje.show()
	elif audio != null:
		if comando is IniciarMano: audio.reproducir(&"campana")
		elif comando is PedirCarta or comando is DevolverLlave: audio.reproducir(&"naipe")

func _iniciar_o_pedir() -> void:
	if boton_iniciar_pedir.disabled:
		return
	if vista.get("terminado", false):
		if campana != null: salir_de_mesa.emit(vista.victoria, controlador.exactos)
		else: _reiniciar()
	elif vista.get("fase", "preparado") == "decision":
		_enviar(Pedir.new())
	else:
		_enviar(Iniciar.new())

## Inventario de la mesa: fichas, la regla del crupier y los objetos (inventario_mesa.gd).
func _ver_objetos() -> void:
	if campana == null or revelacion.activa or modal.visible: return
	_abrir_modal("Inventario de la mesa")
	InventarioMesa.construir(modal.contenido, campana, controlador.usos_objetos(), vista)
	modal.boton_cerrar()

func _usar_lente() -> void:
	if not revelacion.activa and not modal.visible and campana != null:
		if controlador.usar_lente() and audio != null:
			audio.reproducir(&"naipe")

func _plantarse() -> void:
	if revelacion.activa:
		revelacion.terminar()
		return
	if not boton_plantarse.disabled:
		_enviar(ComandoPlantarse.new())

func _solicitar_reinicio() -> void:
	if boton_reiniciar.disabled:
		return
	if vista.get("fase") == "decision" or int(vista.get("campanadas", 10)) < int(vista.get("presupuesto", 10)):
		_confirmar("¿REINICIAR EL INTENTO?", "Volverás a la mesa con tu baraja completa, cero puntos y diez campanadas.", _reiniciar)
	else:
		_reiniciar()

func _reiniciar() -> void:
	if is_instance_valid(controlador):
		controlador.reiniciar()
	boton_iniciar_pedir.grab_focus()

func _solicitar_demostracion() -> void:
	_confirmar("DEMOSTRACIÓN GUIADA", "Reinicia el intento y prepara tres manos: 102 puntos, una Quiebra y 119 puntos. Tú decides cuándo pedir y plantarte; la baraja está preparada para aprender.", _demostracion)

func _demostracion() -> void:
	if is_instance_valid(controlador) and controlador.has_method("cargar_demostracion"):
		controlador.cargar_demostracion()

func _abrir_modal(titulo: String, caja: Rect2 = ModalMesa.MARCO_NORMAL) -> void:
	globo.ocultar()
	revelacion.terminar()
	_respuesta.detener()
	dial.detener()
	eleccion_llave.cancelar()
	cerrar_patrones(false)
	franja_patrones.limpiar()
	_actualizar_orientacion()
	modal.abrir(titulo, caja)

func cerrar_modal() -> void:
	modal.cerrar()

func mostrar_ayuda() -> void:
	_abrir_modal("El libro de la casa" if campana != null else "El libro del Custodio", Rect2(160, 47, 1120, 716))
	var guia := Guia.new()
	guia.name = "Reglamento"
	guia.en_campana = campana != null
	if controlador != null and controlador.has_method("reglas_ayuda"): guia.reglas = controlador.reglas_ayuda()
	guia.position = Vector2(32, 100)
	modal.contenido.add_child(guia)
	guia.movimiento.set_pressed_no_signal(movimiento_reducido)
	guia.movimiento_cambiado.connect(_cambiar_movimiento_reducido)
	var cerrar := modal.boton_cerrar()
	cerrar.position = Vector2(278, 649)
	cerrar.size = Vector2(810, 42)
	Piezas.etiqueta(modal.contenido, "REGLAMENTO DE LA CASA", Rect2(32, 650, 220, 39), 12, MUTED)
	guia.navegacion[0].grab_focus()

## Elección de la persona en el libro: se aplica y se recuerda para la próxima sesión.
func _cambiar_movimiento_reducido(reducido: bool) -> void:
	establecer_movimiento_reducido(reducido)
	AjustesJuego.guardar_movimiento_reducido(reducido)

func establecer_movimiento_reducido(reducido: bool) -> void:
	movimiento_reducido = reducido
	if reducido:
		revelacion.terminar()
		_respuesta.detener()
		_respuesta.detener_aviso()
		dial.detener()
	mano.establecer_movimiento_reducido(reducido)
	if reducido:
		if _transicion_progreso != null and _transicion_progreso.is_valid():
			_transicion_progreso.kill()
		_progreso.value = float(vista.get("puntos", 0))

func mostrar_carta(carta: Dictionary) -> void:
	_abrir_modal("Los símbolos de tu mano")
	var ampliada = Carta.instantiate()
	ampliada.position = Vector2(50, 110)
	ampliada.size = Vector2(260, 470)
	ampliada.focus_mode = Control.FOCUS_NONE
	ampliada.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal.contenido.add_child(ampliada)
	ampliada.establecer_movimiento_reducido(true)
	ampliada.presentar(carta)
	var palo := str(carta.get("palo", Palos.MASCARAS))
	var nombres := Palos.NOMBRES
	Piezas.etiqueta(modal.contenido, nombres.get(palo, "Carta"), Rect2(350, 144, 370, 58), 40, ORO, true)
	var efectos := {
		Palos.VELAS: "Cada Vela conservada suma +1 al multiplicador, siempre que la mano no quiebre.",
		Palos.LLAVES: "Puedes devolver una Llave elegible para recibir otra carta gratis. Solo una vez por mano; el reemplazo se añade al final.",
		Palos.RELOJES: "Su valor efectivo es el impreso menos uno, con mínimo uno. Pedirlo es gratis en campanadas, igual que las demás cartas.",
		Palos.MASCARAS: "Su valor permanece oculto hasta plantarte. El intervalo usa de 1 a 10 por Máscara y no predice el valor real.",
	}
	var efecto: String = efectos.get(palo, "")
	if carta.get("rasgo", "") == CartaEnPartida.RASGO_RACHA_DOBLE:
		efecto += " Esta Vela cuenta como dos cartas para Racha; para el umbral vale lo impreso."
	var detalle := Piezas.etiqueta(modal.contenido, efecto, Rect2(350, 230, 362, 220), 21, MARFIL)
	detalle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var lectura := "VALOR OCULTO · 1–10" if carta.get("oculta", false) else "VALOR EFECTIVO: %s" % carta.get("valor_efectivo", carta.get("valor", "—"))
	Piezas.etiqueta(modal.contenido, lectura, Rect2(350, 489, 362, 65), 18, ORO)
	modal.boton_cerrar()

func mostrar_devolucion() -> void:
	if not revelacion.activa and not modal.visible:
		eleccion_llave.siguiente()

func _activar_carta(carta: Dictionary, id: String) -> void:
	if revelacion.activa:
		revelacion.terminar()
		return
	if modal.visible:
		return
	if vista.get("llaves_disponibles", []).has(id):
		eleccion_llave.seleccionar(id)
	else:
		mostrar_carta(carta)

func _cambio_eleccion_llave(activa: bool) -> void:
	if activa:
		cerrar_patrones(false)
	franja_patrones.ocultar_por_seleccion(activa)
	_sincronizar_consulta()
	if activa:
		franja_patrones.limpiar()
		_mensaje.hide()
	elif not revelacion.activa:
		_actualizar_orientacion()

func _actualizar_orientacion() -> void:
	_mensaje.position = C.DETALLE.position
	_mensaje.size = C.DETALLE.size
	_mensaje.text = Lectura.pista(vista)
	_mensaje.visible = not _mensaje.text.is_empty()
	Piezas.texto_accion(boton_plantarse, "PLANTARSE", "")
	boton_plantarse.tooltip_text += ". Revela y puntúa; no gasta campanadas."
	if vista.get("fase", "preparado") == "decision":
		var resultado: Dictionary = vista.get("resultado_visible", {})
		if not resultado.is_empty():
			# Lo que daría plantarse ahora se lee junto a la suma, no dentro del botón.
			_explicacion.text = "Plantarse: %s puntos" % resultado.puntos
			_explicacion.show()
	elif vista.get("terminado", false):
		boton_iniciar_pedir.disabled = false
		boton_iniciar_pedir.get_node("Fondo").modulate.a = 1.0
		Piezas.texto_accion(boton_iniciar_pedir, "LEVANTARSE" if campana != null else "VOLVER A JUGAR", "")

func _puede_resaltar_patrones() -> bool:
	return not modal.visible and not revelacion.activa and eleccion_llave.seleccionada.is_empty()

func _mostrar_detalle_patron(texto: String) -> void:
	if revelacion.activa or not eleccion_llave.seleccionada.is_empty():
		return
	_actualizar_orientacion()
	if not texto.is_empty():
		_mensaje.position = C.DETALLE.position
		_mensaje.size = C.DETALLE.size
		_mensaje.text = texto
		_mensaje.show()

func _mostrar_patron(indice: int) -> void:
	revelacion.terminar()
	mostrar_ayuda()
	var guia = modal.contenido.get_node("Reglamento")
	var patrones: Array = vista.get("patrones_visibles", [])
	if indice < patrones.size():
		guia.mostrar_patron(str(patrones[indice].nombre))
		modal.contenido.get_child(0).text = str(patrones[indice].nombre) + " · cómo conseguirlo"
	guia.navegacion[2].grab_focus()

func _confirmar(titulo: String, mensaje: String, accion: Callable) -> void:
	_abrir_modal(titulo, Rect2(310, 170, 820, 470))
	modal.pedir_confirmacion(mensaje, accion)

## Atajos de la mesa por acción del mapa de entrada (teclado o mando). Volver cierra primero lo
## que esté abierto; si no hay nada, la pausa sigue hasta el casino.
func _unhandled_input(evento: InputEvent) -> void:
	if not Acciones.es_pulsacion(evento):
		return
	var volver := evento.is_action_pressed(Acciones.VOLVER)
	if modal.visible:
		if volver:
			cerrar_modal()
			get_viewport().set_input_as_handled()
		return
	if volver and revelacion.activa:
		revelacion.terminar()
	elif volver and franja_patrones.tiene_foco():
		cerrar_patrones()
	elif volver and not eleccion_llave.seleccionada.is_empty():
		eleccion_llave.cancelar()
	else:
		# Levantarse tras el final saca la mesa del árbol: el viewport se toma antes de actuar.
		var puerto := get_viewport()
		for atajo: Array in _atajos():
			if evento.is_action_pressed(atajo[0]):
				atajo[1].call()
				puerto.set_input_as_handled()
				return
		return
	get_viewport().set_input_as_handled()

func _atajos() -> Array:
	return [
		[Acciones.PEDIR, _iniciar_o_pedir], [Acciones.PLANTARSE, _plantarse],
		[Acciones.DEVOLVER_LLAVE, mostrar_devolucion], [Acciones.AYUDA, mostrar_ayuda],
		[Acciones.PATRONES, alternar_patrones], [Acciones.INVENTARIO, _ver_objetos],
		[Acciones.SONIDO, _sonido], [Acciones.REINICIAR, _solicitar_reinicio],
	]
