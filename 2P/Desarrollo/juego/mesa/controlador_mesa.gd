class_name ControladorMesa
extends Node
## Única entrada de acciones; publica solo datos permitidos para la presentación.

signal vista_actualizada(vista: Dictionary)
signal encuentro_finalizado(victoria: bool)

var partida: EstadoPartida
var estado_activo: EstadoMesaBase
var _llaves_habilitadas: Array[String] = []
var _cartas_resueltas: Array[Dictionary] = []
var _ultimo_resultado: Dictionary = {}
var _mensaje: String = "Inicia una mano: dos cartas, una campanada."
var _numero_mano: int = 0
var _terminado: bool = false
var _victoria: bool = false
var _modo_demostracion: bool = false
var _procesando: bool = false

func _init() -> void:
	_preparar_intento(-1)

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
	if _procesando:
		return
	_procesando = true
	_preparar_intento(semilla)
	vista_actualizada.emit(obtener_vista())
	_procesando = false

func _preparar_intento(semilla: int) -> void:
	partida = EstadoPartida.new(semilla)
	estado_activo = EstadoPreparado.new(self)
	_llaves_habilitadas.clear()
	_cartas_resueltas.clear()
	_ultimo_resultado.clear()
	_numero_mano = 0
	_terminado = false
	_victoria = false
	_modo_demostracion = false
	_mensaje = "Inicia una mano: dos cartas, una campanada."

func cargar_demostracion() -> void:
	if _procesando:
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

func _iniciar_mano() -> ResultadoAccion:
	if partida.campanadas <= 0:
		return ResultadoAccion.rechazar("No quedan campanadas para iniciar.")
	if partida.disponibles() < 2 or not partida.mano.is_empty():
		return ResultadoAccion.rechazar("Se necesitan dos cartas disponibles y ninguna mano abierta.")
	partida.campanadas -= 1
	partida.llave_usada = false
	_llaves_habilitadas.clear()
	_cartas_resueltas.clear()
	_ultimo_resultado.clear()
	_numero_mano += 1
	for i in range(2):
		var carta := partida.robar()
		partida.mano.append(carta)
		if carta.definicion.palo == "llaves":
			_llaves_habilitadas.append(carta.id_instancia)
	estado_activo = EstadoDecision.new(self)
	_mensaje = "Elige pedir o plantarte. Puedes devolver una Llave inicial antes de otra acción."
	_comprobar_quiebra_demostrable()
	return ResultadoAccion.aceptar()

func _pedir_carta() -> ResultadoAccion:
	if partida.campanadas <= 0:
		return ResultadoAccion.rechazar("No quedan campanadas; todavía puedes plantarte.")
	if partida.disponibles() == 0:
		return ResultadoAccion.rechazar("No hay cartas disponibles; puedes plantarte.")
	if int(EvaluadorMano.intervalo(partida.mano).minimo) > partida.umbral:
		return ResultadoAccion.rechazar("El mínimo ya supera el umbral: devuelve la Llave disponible o resuelve plantándote.")
	partida.campanadas -= 1
	_llaves_habilitadas.clear()
	var carta := partida.robar()
	partida.mano.append(carta)
	if carta.definicion.palo == "llaves" and not partida.llave_usada:
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
		if partida.mano[i].id_instancia == carta_id and partida.mano[i].definicion.palo == "llaves":
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

func _llaves_disponibles() -> Array[String]:
	var ids: Array[String] = []
	if estado_activo.nombre != "decision" or partida.llave_usada or partida.disponibles() == 0:
		return ids
	for carta: CartaEnPartida in partida.mano:
		if carta.definicion.palo == "llaves" and _llaves_habilitadas.has(carta.id_instancia):
			ids.append(carta.id_instancia)
	return ids

func _comprobar_quiebra_demostrable() -> void:
	if int(EvaluadorMano.intervalo(partida.mano).minimo) <= partida.umbral:
		return
	if not _llaves_disponibles().is_empty():
		_mensaje = "El mínimo supera el umbral. Puedes devolver una Llave o plantarte para confirmar Quiebra."
	else:
		_resolver_mano()

func _resolver_mano() -> void:
	estado_activo = EstadoResolucion.new(self)
	_ultimo_resultado = EvaluadorMano.evaluar(partida.mano, partida.umbral).duplicate(true)
	_cartas_resueltas = _vista_cartas(partida.mano, true)
	partida.puntos += int(_ultimo_resultado.puntos)
	partida.cerrar_mano()
	_llaves_habilitadas.clear()
	_victoria = partida.puntos >= partida.meta
	_terminado = _victoria or partida.campanadas <= 0
	if _terminado:
		estado_activo = EstadoFinalizada.new(self)
		_mensaje = "Mesa superada. Alcanzaste la meta del Custodio." if _victoria else "Sin campanadas y sin alcanzar la meta. Puedes reiniciar el encuentro."
	else:
		estado_activo = EstadoPreparado.new(self)
		_mensaje = "Quiebra: esta mano aporta cero puntos. Quedan oportunidades para continuar." if _ultimo_resultado.quiebra else "Mano resuelta. Revisa el desglose o inicia otra mano."

func _vista_cartas(cartas: Array, revelar: bool) -> Array[Dictionary]:
	var vista: Array[Dictionary] = []
	var elegibles: Array[String] = []
	if not revelar:
		elegibles = _llaves_disponibles()
	for carta: CartaEnPartida in cartas:
		var oculta := carta.definicion.palo == "mascaras" and not revelar
		var valor: Variant = null
		var efectivo: Variant = null
		if not oculta:
			valor = carta.definicion.valor_impreso
			efectivo = carta.valor_efectivo()
		vista.append({
			"id": carta.id_instancia, "palo": carta.definicion.palo,
			"valor": valor, "valor_efectivo": efectivo,
			"oculta": oculta, "puede_devolver": elegibles.has(carta.id_instancia),
		})
	return vista

func obtener_vista() -> Dictionary:
	var decision := estado_activo.nombre == "decision"
	var intervalo := EvaluadorMano.intervalo(partida.mano)
	var cartas := _vista_cartas(partida.mano, false)
	if not decision and not _cartas_resueltas.is_empty():
		cartas = _cartas_resueltas.duplicate(true)
		intervalo = {"conocido": int(_ultimo_resultado.total), "ocultas": 0, "minimo": int(_ultimo_resultado.total), "maximo": int(_ultimo_resultado.total)}
	var llaves := _llaves_disponibles()
	return {
		"fase": estado_activo.nombre, "campanadas": partida.campanadas, "presupuesto": 10,
		"puntos": partida.puntos, "meta": partida.meta, "umbral": partida.umbral,
		"mazo": partida.mazo.size(), "descarte": partida.descarte.size(),
		"numero_mano": _numero_mano, "modo_demostracion": _modo_demostracion,
		"terminado": _terminado, "victoria": _victoria, "mensaje": _mensaje,
		"cartas": cartas, "intervalo": intervalo, "llaves_disponibles": llaves,
		"ultima_mano": _ultimo_resultado.duplicate(true),
		"acciones": {
			"iniciar": estado_activo.nombre == "preparado" and partida.campanadas > 0 and partida.disponibles() >= 2 and partida.mano.is_empty(),
			"pedir": decision and partida.campanadas > 0 and partida.disponibles() > 0 and int(intervalo.minimo) <= partida.umbral,
			"plantarse": decision and not partida.mano.is_empty(),
			"devolver": not llaves.is_empty(), "reiniciar": true,
		},
	}
