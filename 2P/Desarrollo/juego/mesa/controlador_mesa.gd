class_name ControladorMesa
extends Node
## Única entrada de acciones; publica solo datos permitidos para la presentación.

const Indicadores = preload("res://dominio/indicadores_patrones.gd")
## El Dueño empieza en el umbral de su mesa y baja uno por cada mano cerrada sin Quiebra, hasta este mínimo.
const UMBRAL_MINIMO_DUENO := 17

signal vista_actualizada(vista: Dictionary)
signal encuentro_finalizado(victoria: bool)

var campana: CampanaCasino
var presupuesto := 10
var exactos := 0
var _vistas_con_lente := {}
var _usos_prudente := 0
var _usos_moneda := 0
var retenidas: Array[CartaEnPartida] = []
var partida: EstadoPartida
var estado_activo: EstadoMesaBase
var _llaves_habilitadas: Array[String] = []
var _cartas_resueltas: Array[Dictionary] = []
var _ultimo_resultado: Dictionary = {}
var _mensaje: String = "Inicia una mano: dos cartas, una campanada."
var _numero_mano: int = 0
var _umbral_mano_anterior: int = -1
var _manos_resueltas: int = 0
var _quiebras: int = 0
var _terminado: bool = false
var _victoria: bool = false
var _modo_demostracion: bool = false
var _procesando: bool = false

func _init() -> void:
	_preparar_intento(-1)

func configurar_campana(sesion: CampanaCasino) -> void:
	campana = sesion
	var reglas: Array = CampanaCasino.REGLAS[CampanaCasino.MESAS.find(campana.activa)]
	partida.umbral = reglas[0]
	partida.meta = reglas[1]
	presupuesto = reglas[2]
	partida.campanadas = presupuesto
	partida.mazo.assign(campana.baraja)
	partida._barajar()

func usar_lente() -> bool:
	if _procesando or campana == null or campana.lentes == 0 or estado_activo.nombre != "decision" or _intervalo().ocultas == 0: return false
	for carta in partida.mano:
		if carta.definicion.palo == "mascaras": _vistas_con_lente[carta.id_instancia] = true
	campana.lentes -= 1
	_llaves_habilitadas.clear()
	vista_actualizada.emit(obtener_vista())
	return true

func _intervalo() -> Dictionary:
	return EvaluadorMano.intervalo(partida.mano, false, _vistas_con_lente)

## Reglas públicas de la mesa activa para el libro de ayuda; no expone cartas ni el mazo.
func reglas_ayuda() -> Dictionary:
	var mesa := campana.activa if campana != null and not campana.activa.is_empty() else "custodio"
	var umbral := partida.umbral
	# Con el Dueño, entre manos se muestra el umbral que tendrá la siguiente mano.
	if mesa == "dueno" and estado_activo.nombre != "decision":
		umbral = _umbral_dueno(_manos_validas())
	return {
		"mesa": mesa, "nombre": CampanaCasino.NOMBRES.get(mesa, "El Custodio"),
		"umbral": umbral, "meta": partida.meta, "presupuesto": presupuesto,
		"campanadas": partida.campanadas, "ficha_por_pedir": 1 if _cobra_comision() else 0,
		"saldo": campana.saldo if campana != null else 0, "umbral_minimo": UMBRAL_MINIMO_DUENO,
	}

func _umbral_dueno(manos_validas: int) -> int:
	return maxi(UMBRAL_MINIMO_DUENO, int(CampanaCasino.REGLAS[3][0]) - manos_validas)

## Manos cerradas sin Quiebra: son las que hacen bajar el umbral del Dueño.
func _manos_validas() -> int:
	return _manos_resueltas - _quiebras

## Umbral de la mano anterior y de la siguiente, para anunciar los cambios del Dueño. −1 si no aplica.
func _umbrales_vecinos() -> Dictionary:
	if campana == null or campana.activa != "dueno":
		return {"anterior": -1, "siguiente": -1}
	if estado_activo.nombre == "decision":
		# La siguiente supone que esta mano se cierra sin Quiebra.
		return {"anterior": _umbral_mano_anterior, "siguiente": _umbral_dueno(_manos_validas() + 1)}
	return {"anterior": partida.umbral if _manos_resueltas > 0 else -1, "siguiente": _umbral_dueno(_manos_validas())}

func _cobra_comision() -> bool:
	return campana != null and campana.activa == "recaudador"

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
	_cartas_resueltas.clear()
	_ultimo_resultado.clear()
	_numero_mano = 0
	_umbral_mano_anterior = -1
	_manos_resueltas = 0
	_quiebras = 0
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

func _iniciar_mano() -> ResultadoAccion:
	if partida.campanadas <= 0:
		return ResultadoAccion.rechazar("No quedan campanadas para iniciar.")
	if partida.disponibles() < 2 or not partida.mano.is_empty():
		return ResultadoAccion.rechazar("Se necesitan dos cartas disponibles y ninguna mano abierta.")
	if campana != null and campana.activa == "dueno":
		_umbral_mano_anterior = partida.umbral if _manos_resueltas > 0 else -1
		partida.umbral = _umbral_dueno(_manos_validas())
	_vistas_con_lente.clear()
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
	if partida.disponibles() == 0:
		return ResultadoAccion.rechazar("No hay cartas disponibles; puedes plantarte.")
	if int(_intervalo().minimo) > partida.umbral:
		return ResultadoAccion.rechazar("El mínimo ya supera el umbral: devuelve la Llave disponible o resuelve plantándote.")
	if _cobra_comision():
		if campana.saldo < 1: return ResultadoAccion.rechazar("Falta una ficha para pedir. Puedes plantarte.")
		campana.saldo -= 1
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
	if int(_intervalo().minimo) <= partida.umbral:
		return
	if not _llaves_disponibles().is_empty():
		_mensaje = "El mínimo supera el umbral. Puedes devolver una Llave o plantarte para confirmar Quiebra."
	else:
		_mensaje = "Quiebra segura: el mínimo supera el umbral. Plántate para revelar y cerrar la mano."

func _resolver_mano() -> void:
	estado_activo = EstadoResolucion.new(self)
	_ultimo_resultado = EvaluadorMano.evaluar(partida.mano, partida.umbral).duplicate(true)
	_manos_resueltas += 1
	if _ultimo_resultado.quiebra: _quiebras += 1
	_cartas_resueltas = _vista_cartas(partida.mano, true)
	if campana != null:
		_aplicar_objetos()
		if campana.activa == "coleccionista" and partida.disponibles() + partida.mano.size() > 2:
			var mayor := partida.mano.front() as CartaEnPartida
			for carta in partida.mano:
				if carta.valor_efectivo() >= mayor.valor_efectivo(): mayor = carta
			retenidas.append(mayor)
			partida.mano.erase(mayor)
	partida.puntos += int(_ultimo_resultado.puntos)
	partida.cerrar_mano()
	_llaves_habilitadas.clear()
	_victoria = partida.puntos >= partida.meta
	_terminado = _victoria or partida.campanadas <= 0
	if _terminado:
		estado_activo = EstadoFinalizada.new(self)
		_mensaje = "Mesa superada. Alcanzaste la meta del encuentro." if _victoria else "Sin campanadas y sin alcanzar la meta. Puedes reiniciar el encuentro."
	else:
		estado_activo = EstadoPreparado.new(self)
		_mensaje = "Quiebra: esta mano aporta cero puntos. Quedan oportunidades para continuar." if _ultimo_resultado.quiebra else "Mano resuelta. Revisa el desglose o inicia otra mano."

func _aplicar_objetos() -> void:
	if _ultimo_resultado.quiebra: return
	if campana.amuletos.has("corona") and _intervalo().ocultas > 0:
		_ultimo_resultado.corona = 2
		_ultimo_resultado.multiplicador += 2
		_ultimo_resultado.puntos = _ultimo_resultado.total * _ultimo_resultado.multiplicador
	if _ultimo_resultado.total == partida.umbral:
		exactos += 1
		if campana.amuletos.has("moneda") and _usos_moneda < 3:
			campana.saldo += 2
			_usos_moneda += 1
	if campana.amuletos.has("prudente") and _usos_prudente < CampanaCasino.USOS_PRUDENTE and _ultimo_resultado.total <= partida.umbral - 3:
		partida.campanadas = mini(presupuesto, partida.campanadas + 1)
		_usos_prudente += 1

func _vista_cartas(cartas: Array, revelar: bool) -> Array[Dictionary]:
	var vista: Array[Dictionary] = []
	var elegibles: Array[String] = []
	if not revelar:
		elegibles = _llaves_disponibles()
	for carta: CartaEnPartida in cartas:
		var oculta := carta.definicion.palo == "mascaras" and not revelar and not _vistas_con_lente.has(carta.id_instancia)
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
	var intervalo := _intervalo()
	var cartas := _vista_cartas(partida.mano, false)
	if not decision and not _cartas_resueltas.is_empty():
		cartas = _cartas_resueltas.duplicate(true)
		intervalo = {"conocido": int(_ultimo_resultado.total), "ocultas": 0, "minimo": int(_ultimo_resultado.total), "maximo": int(_ultimo_resultado.total)}
	var llaves := _llaves_disponibles()
	var resultado_visible: Dictionary = {}
	# Solo se anticipa una puntuación determinada por información ya pública.
	if decision and int(intervalo.ocultas) == 0:
		resultado_visible = EvaluadorMano.evaluar(partida.mano, partida.umbral).duplicate(true)
	var vecinos := _umbrales_vecinos()
	return {
		"mesa": campana.activa if campana != null else "", "retenidas": retenidas.size(),
		"umbral_anterior": vecinos.anterior, "umbral_siguiente": vecinos.siguiente,
		"comision": _cobra_comision(), "saldo": campana.saldo if campana != null else 0,
		"fase": estado_activo.nombre, "campanadas": partida.campanadas, "presupuesto": presupuesto,
		"puntos": partida.puntos, "meta": partida.meta, "umbral": partida.umbral,
		"mazo": partida.mazo.size(), "descarte": partida.descarte.size(),
		"numero_mano": _numero_mano, "modo_demostracion": _modo_demostracion,
		"terminado": _terminado, "victoria": _victoria, "mensaje": _mensaje,
		"cartas": cartas, "intervalo": intervalo, "llaves_disponibles": llaves,
		"ultima_mano": _ultimo_resultado.duplicate(true),
		"resumen_intento": {"manos": _manos_resueltas, "validas": _manos_resueltas - _quiebras, "quiebras": _quiebras},
		"resultado_visible": resultado_visible,
		"patrones_visibles": Indicadores.calcular(cartas, intervalo, partida.umbral),
		"acciones": {
			"iniciar": estado_activo.nombre == "preparado" and partida.campanadas > 0 and partida.disponibles() >= 2 and partida.mano.is_empty(),
			"pedir": decision and (not _cobra_comision() or campana.saldo > 0) and partida.disponibles() > 0 and int(intervalo.minimo) <= partida.umbral,
			"plantarse": decision and not partida.mano.is_empty(),
			"devolver": not llaves.is_empty(), "reiniciar": campana == null,
		},
	}
