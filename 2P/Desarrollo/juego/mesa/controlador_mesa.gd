class_name ControladorMesa
extends Node
## Única entrada de acciones; publica solo datos permitidos para la presentación.

const ObjetosMesa := preload("res://dominio/campana/objetos_mesa.gd")
const VistaMano := preload("res://mesa/vista_mano.gd")

signal vista_actualizada(vista: Dictionary)
signal encuentro_finalizado(victoria: bool)

var campana: CampanaCasino
## Regla especial del crupier activo (Strategy). Sin campaña, la mesa no tiene regla especial.
var regla: ReglaCrupier = ReglaCrupier.new()
var presupuesto := 10
var exactos: int:
	get: return _objetos.exactos
var partida: EstadoPartida
var estado_activo: EstadoMesaBase
var _objetos := ObjetosMesa.new()
var _vista_mano := VistaMano.new()
var _llaves_habilitadas: Array[String] = []
var _mensaje: String = "Inicia una mano: dos cartas, una campanada."
var _numero_mano: int = 0
var _terminado: bool = false
var _victoria: bool = false
var _modo_demostracion: bool = false
var _procesando: bool = false

func _init() -> void:
	_preparar_intento(-1)

func configurar_campana(sesion: CampanaCasino) -> void:
	campana = sesion
	regla = FabricaCrupieres.para(campana.activa)
	var reglas := CampanaCasino.MESAS_CAMPANA.de(campana.activa)
	partida.umbral = reglas.umbral
	partida.meta = reglas.meta
	presupuesto = reglas.campanadas
	partida.campanadas = presupuesto
	partida.mazo.assign(campana.baraja)
	partida._barajar()

func usar_lente() -> bool:
	if _procesando or campana == null or estado_activo.nombre != "decision":
		return false
	if not _objetos.usar_lente(campana, partida.mano):
		return false
	_llaves_habilitadas.clear()
	_procesando = true
	vista_actualizada.emit(obtener_vista())
	_procesando = false
	return true

func _intervalo() -> Dictionary:
	return EvaluadorMano.intervalo(partida.mano, false, _objetos.mascaras_vistas)

## Reglas públicas de la mesa activa para el libro de ayuda; no expone cartas ni el mazo.
func reglas_ayuda() -> Dictionary:
	var mesa := campana.activa if campana != null and not campana.activa.is_empty() else "custodio"
	# Entre manos se muestra el umbral que tendrá la siguiente mano.
	var umbral := partida.umbral if estado_activo.nombre == "decision" else regla.umbral_entre_manos(partida)
	return {
		"mesa": mesa, "nombre": CampanaCasino.NOMBRES.get(mesa, "El Custodio"),
		"umbral": umbral, "meta": partida.meta, "presupuesto": presupuesto,
		"campanadas": partida.campanadas, "ficha_por_pedir": 1 if _cobra_comision() else 0,
		"saldo": campana.saldo if campana != null else 0, "umbral_minimo": ReglaDueno.MINIMO,
	}

func _cobra_comision() -> bool:
	return campana != null and regla.cobra_por_pedir()

func procesar_comando(comando: ComandoMesa) -> ResultadoAccion:
	if _procesando:
		return ResultadoAccion.rechazar("La acción anterior todavía se está notificando.")
	if comando == null:
		return ResultadoAccion.rechazar("No se recibió una acción.")
	_procesando = true
	var resultado := comando.ejecutar(estado_activo)
	if resultado.aceptado:
		vista_actualizada.emit(obtener_vista())
		if _terminado:
			encuentro_finalizado.emit(_victoria)
	_procesando = false
	return resultado

func reiniciar(semilla: int = -1) -> void:
	if _procesando or campana != null:
		return
	_procesando = true
	_preparar_intento(semilla)
	vista_actualizada.emit(obtener_vista())
	_procesando = false

func _preparar_intento(semilla: int) -> void:
	partida = EstadoPartida.new(semilla)
	estado_activo = EstadoPreparado.new(self)
	_llaves_habilitadas.clear()
	_vista_mano.limpiar()
	_objetos = ObjetosMesa.new()
	_numero_mano = 0
	regla = FabricaCrupieres.para(campana.activa if campana != null else "")
	_terminado = false
	_victoria = false
	_modo_demostracion = false
	_mensaje = "Inicia una mano: dos cartas, una campanada."

func cargar_demostracion() -> void:
	if _procesando or campana != null:
		return
	_procesando = true
	_preparar_intento(102)
	_modo_demostracion = true
	# Recorrido del GDD: las diez cartas son distintas y el resto sigue disponible.
	var secuencia: Array[String] = [
		"llaves_04", "relojes_06", "mascaras_08",
		"velas_06", "relojes_07", "mascaras_10",
		"velas_02", "velas_04", "llaves_03", "velas_08",
	]
	var orden: Array[CartaEnPartida] = []
	for id: String in secuencia:
		for carta: CartaEnPartida in partida.mazo:
			if carta.definicion.id == id:
				orden.append(carta)
	for carta: CartaEnPartida in partida.mazo:
		if not orden.has(carta):
			orden.append(carta)
	partida.mazo = orden
	_mensaje = "Demostración guiada: inicia, pide y plántate. La partida normal usa una baraja aleatoria."
	vista_actualizada.emit(obtener_vista())
	_procesando = false

func _impedimento_inicio() -> String:
	if partida.campanadas <= 0:
		return "No quedan campanadas para iniciar."
	if partida.disponibles() < 2 or not partida.mano.is_empty():
		return "Se necesitan dos cartas disponibles y ninguna mano abierta."
	return ""

func _iniciar_mano() -> ResultadoAccion:
	var impedimento := _impedimento_inicio()
	if not impedimento.is_empty():
		return ResultadoAccion.rechazar(impedimento)
	partida.umbral = regla.umbral_al_iniciar(partida)
	_objetos.mascaras_vistas.clear()
	partida.campanadas -= 1
	partida.llave_usada = false
	_llaves_habilitadas.clear()
	_vista_mano.limpiar()
	_numero_mano += 1
	for i in range(2):
		var carta := partida.robar()
		partida.mano.append(carta)
		if carta.definicion.palo == Palos.LLAVES:
			_llaves_habilitadas.append(carta.id_instancia)
	estado_activo = EstadoDecision.new(self)
	_mensaje = "Elige pedir o plantarte. Puedes devolver una Llave inicial antes de otra acción."
	_comprobar_quiebra_demostrable()
	return ResultadoAccion.aceptar()

func _impedimento_pedir(minimo: int) -> String:
	if partida.disponibles() == 0:
		return "No hay cartas disponibles; puedes plantarte."
	if minimo > partida.umbral:
		return "El mínimo ya supera el umbral: devuelve la Llave disponible o resuelve plantándote."
	if _cobra_comision() and campana.saldo < 1:
		return "Falta una ficha para pedir. Puedes plantarte."
	return ""

func _pedir_carta() -> ResultadoAccion:
	var impedimento := _impedimento_pedir(_intervalo().minimo)
	if not impedimento.is_empty():
		return ResultadoAccion.rechazar(impedimento)
	if _cobra_comision():
		campana.saldo -= 1
	_llaves_habilitadas.clear()
	var carta := partida.robar()
	partida.mano.append(carta)
	if carta.definicion.palo == Palos.LLAVES and not partida.llave_usada:
		_llaves_habilitadas.append(carta.id_instancia)
	_mensaje = "Carta recibida. Decide con la información visible; plantarse no cuesta campanadas."
	_comprobar_quiebra_demostrable()
	return ResultadoAccion.aceptar()

func _devolver_llave(carta_id: String) -> ResultadoAccion:
	if partida.llave_usada or not _llaves_habilitadas.has(carta_id):
		return ResultadoAccion.rechazar("Solo puedes devolver una Llave elegible una vez por mano.")
	# Se comprueba antes de poner la Llave al fondo: nunca se reemplaza a sí misma.
	if partida.disponibles() == 0:
		return ResultadoAccion.rechazar("No existe otra carta disponible para reemplazar la Llave.")
	var indice: int = -1
	for i in range(partida.mano.size()):
		if partida.mano[i].id_instancia == carta_id and partida.mano[i].definicion.palo == Palos.LLAVES:
			indice = i
			break
	if indice < 0:
		return ResultadoAccion.rechazar("Esa Llave no está en la mano.")
	var devuelta: CartaEnPartida = partida.mano.pop_at(indice)
	var reemplazo := partida.robar()
	partida.mazo.append(devuelta)
	partida.mano.append(reemplazo)
	partida.llave_usada = true
	_llaves_habilitadas.clear()
	_mensaje = "Llave devuelta al fondo; reemplazo al final de la mano. Sin coste adicional."
	_comprobar_quiebra_demostrable()
	return ResultadoAccion.aceptar()

func _plantarse() -> ResultadoAccion:
	if partida.mano.is_empty():
		return ResultadoAccion.rechazar("No hay cartas para resolver.")
	_resolver_mano()
	return ResultadoAccion.aceptar()

## Usos restantes de los objetos limitados en este encuentro (inventario de la mesa).
func usos_objetos() -> Dictionary:
	return _objetos.usos_restantes()

func _llaves_disponibles() -> Array[String]:
	var ids: Array[String] = []
	if estado_activo.nombre != "decision" or partida.llave_usada or partida.disponibles() == 0:
		return ids
	for carta: CartaEnPartida in partida.mano:
		if carta.definicion.palo == Palos.LLAVES and _llaves_habilitadas.has(carta.id_instancia):
			ids.append(carta.id_instancia)
	return ids

func _comprobar_quiebra_demostrable() -> void:
	if int(_intervalo().minimo) <= partida.umbral:
		return
	if not _llaves_disponibles().is_empty():
		_mensaje = "El mínimo supera el umbral. Puedes devolver una Llave o plantarte para confirmar Quiebra."
	else:
		_mensaje = "Quiebra segura: el mínimo supera el umbral. Plántate para revelar y cerrar la mano."

func _resolver_mano() -> void:
	estado_activo = EstadoResolucion.new(self)
	var resultado := EvaluadorMano.evaluar(partida.mano, partida.umbral)
	partida.manos_resueltas += 1
	if resultado.quiebra:
		partida.quiebras += 1
	if campana != null:
		_objetos.aplicar(campana, partida, resultado, presupuesto)
	_vista_mano.registrar_cierre(partida.mano, resultado)
	if campana != null:
		regla.al_resolver(partida)
	partida.puntos += int(resultado.puntos)
	partida.cerrar_mano()
	_llaves_habilitadas.clear()
	_victoria = partida.puntos >= partida.meta
	_terminado = _victoria or partida.campanadas <= 0
	if _terminado:
		estado_activo = EstadoFinalizada.new(self)
		_mensaje = "Mesa superada. Alcanzaste la meta del encuentro." if _victoria else "Sin campanadas y sin alcanzar la meta. Puedes reiniciar el encuentro."
	else:
		estado_activo = EstadoPreparado.new(self)
		_mensaje = "Quiebra: esta mano aporta cero puntos. Quedan oportunidades para continuar." if resultado.quiebra else "Mano resuelta. Revisa el desglose o inicia otra mano."

func obtener_vista() -> Dictionary:
	var decision := estado_activo.nombre == "decision"
	var llaves := _llaves_disponibles()
	var mano := _vista_mano.proyectar(partida, decision, llaves, _objetos.mascaras_vistas)
	var vecinos := regla.umbrales_vecinos(partida, decision)
	var vista := {
		"mesa": campana.activa if campana != null else "", "retenidas": partida.retenidas.size(),
		"umbral_anterior": vecinos.anterior, "umbral_siguiente": vecinos.siguiente,
		"comision": _cobra_comision(), "saldo": campana.saldo if campana != null else 0,
		"fase": estado_activo.nombre, "campanadas": partida.campanadas, "presupuesto": presupuesto,
		"puntos": partida.puntos, "meta": partida.meta, "umbral": partida.umbral,
		"mazo": partida.mazo.size(), "descarte": partida.descarte.size(),
		"numero_mano": _numero_mano, "modo_demostracion": _modo_demostracion,
		"terminado": _terminado, "victoria": _victoria, "mensaje": _mensaje,
		"resumen_intento": {"manos": partida.manos_resueltas, "validas": partida.manos_validas(), "quiebras": partida.quiebras},
		"acciones": {
			"iniciar": estado_activo.nombre == "preparado" and _impedimento_inicio().is_empty(),
			"pedir": decision and _impedimento_pedir(mano.intervalo.minimo).is_empty(),
			"plantarse": decision and not partida.mano.is_empty(),
			"devolver": not llaves.is_empty(), "reiniciar": campana == null,
		},
	}
	vista.merge(mano)
	return vista
