extends RefCounted
## Simulación del balance del Recaudador con las reglas y precios actuales.
## Usa CampanaCasino y ControladorMesa reales; la estrategia solo ve la vista pública.
## La ejecuta tests/test_balance_recaudador.gd y escribe exportaciones/qa/balance_recaudador.json.

const SEMILLAS := 200
## Saldo al salir del Custodio: diez iniciales + premio con dos Puntos exactos (10 + 5 × 2), como en el GDD.
const SALDO_TRAS_CUSTODIO := 30
const RECORRIDOS := [
	{"nombre": "Ahorra", "compras": []},
	{"nombre": "Compra", "compras": ["corona", "prudente"]},
]
const ESTILOS := [
	{"nombre": "Se planta pronto", "extra": false},
	{"nombre": "Pide una carta más", "extra": true},
]
## Regla base (la misma de la simulación de ITERACION_02): pedir si el punto medio
## del intervalo visible queda seis o más por debajo del umbral.
const MARGEN := 6

static func jugar(semilla: int, recorrido: Dictionary, estilo: Dictionary, registrar := false) -> Dictionary:
	var c := CampanaCasino.new()
	c.recibir_invitacion()
	c.saldo = SALDO_TRAS_CUSTODIO
	for id: String in recorrido.compras:
		var comprado := c.comprar(id)
		assert(comprado, "Compra rechazada: %s" % id)
	c.superadas = 1
	c.iniciar("recaudador")
	var m := ControladorMesa.new()
	m.configurar_campana(c)
	# Mismo reparto para todos los recorridos: la baraja no cambia de composición
	# y se mezcla con la semilla, sin depender del azar de configurar_campana.
	m.partida._rng.seed = semilla
	m.partida.mazo.assign(c.baraja)
	m.partida.descarte.clear()
	m.partida._barajar()
	var r := {"saldo_al_sentarse": c.saldo, "comisiones": 0, "manos_sin_saldo": 0,
		"manos": 0, "victoria": false, "puntos": 0, "registro": []}
	var mano_actual := -1
	var extra_usada := false
	var falto := false
	for _paso in range(400):
		var v := m.obtener_vista()
		if v.terminado: break
		if v.fase == "preparado":
			m.procesar_comando(IniciarMano.new())
			continue
		if int(v.numero_mano) != mano_actual:
			mano_actual = int(v.numero_mano)
			extra_usada = false
			falto = false
		var iv: Dictionary = v.intervalo
		var umbral := int(v.umbral)
		if int(iv.minimo) > umbral:
			var llave := _mejor_llave(v)
			if not llave.is_empty():
				m.procesar_comando(DevolverLlave.new(llave))
				continue
			_plantar(m, r, registrar, falto)
			continue
		var quiere := (float(iv.minimo) + float(iv.maximo)) / 2.0 <= umbral - MARGEN
		if not quiere and estilo.extra and not extra_usada:
			quiere = true
			extra_usada = true
		var hay_cartas := int(v.mazo) + int(v.descarte) > 0
		if quiere and hay_cartas and bool(v.acciones.pedir):
			var antes := c.saldo
			m.procesar_comando(PedirCarta.new())
			r.comisiones += antes - c.saldo
			continue
		if quiere and hay_cartas and c.saldo < 1:
			falto = true
		_plantar(m, r, registrar, falto)
	var final := m.obtener_vista()
	r.victoria = bool(final.victoria)
	r.puntos = int(final.puntos)
	m.free()
	return r

static func _mejor_llave(v: Dictionary) -> String:
	var elegida := ""
	var valor := -1
	for carta: Dictionary in v.cartas:
		if v.llaves_disponibles.has(carta.id) and int(carta.valor) > valor:
			valor = int(carta.valor)
			elegida = carta.id
	return elegida

static func _plantar(m: ControladorMesa, r: Dictionary, registrar: bool, falto: bool) -> void:
	m.procesar_comando(Plantarse.new())
	var v := m.obtener_vista()
	r.manos += 1
	if falto: r.manos_sin_saldo += 1
	if registrar:
		var cartas := PackedStringArray()
		for carta: Dictionary in v.cartas: cartas.append("%s %s" % [carta.valor, str(carta.palo).capitalize()])
		var u: Dictionary = v.ultima_mano
		r.registro.append({"mano": v.numero_mano, "cartas": ", ".join(cartas), "total": u.total,
			"puntos": u.puntos, "quiebra": u.quiebra, "patrones": ", ".join(u.patrones),
			"le_falto_saldo": falto, "saldo": v.saldo, "acumulado": v.puntos})

## Recorre todas las combinaciones con las mismas semillas.
static func ejecutar() -> Dictionary:
	var filas: Array = []
	for recorrido: Dictionary in RECORRIDOS:
		for estilo: Dictionary in ESTILOS:
			var fila := {"recorrido": recorrido.nombre, "estilo": estilo.nombre, "intentos": SEMILLAS,
				"saldo_al_sentarse": 0, "comisiones": 0, "manos_sin_saldo": 0, "victorias": 0,
				"intentos_con_falta": 0, "manos": 0}
			for semilla in range(SEMILLAS):
				var r := jugar(semilla, recorrido, estilo)
				fila.saldo_al_sentarse = r.saldo_al_sentarse
				fila.comisiones += r.comisiones
				fila.manos_sin_saldo += r.manos_sin_saldo
				fila.manos += r.manos
				if r.manos_sin_saldo > 0: fila.intentos_con_falta += 1
				if r.victoria: fila.victorias += 1
			filas.append(fila)
	return {"filas": filas, "ejemplo": ejemplo()}

## Primera semilla en la que quien compra quiere pedir la carta extra y no puede.
## Hasta esa mano ambos recorridos jugaron exactamente igual (mismo reparto y decisiones).
static func ejemplo() -> Dictionary:
	for semilla in range(SEMILLAS):
		var compra := jugar(semilla, RECORRIDOS[1], ESTILOS[1], true)
		if compra.manos_sin_saldo == 0: continue
		var ahorra := jugar(semilla, RECORRIDOS[0], ESTILOS[1], true)
		for i in range(mini(compra.registro.size(), ahorra.registro.size())):
			if compra.registro[i].le_falto_saldo:
				return {"semilla": semilla, "mano": compra.registro[i].mano,
					"compra": compra.registro[i], "ahorra": ahorra.registro[i],
					"resultado_compra": {"victoria": compra.victoria, "puntos": compra.puntos},
					"resultado_ahorra": {"victoria": ahorra.victoria, "puntos": ahorra.puntos}}
	return {}

static func tabla(datos: Dictionary) -> String:
	var lineas := PackedStringArray(["| Recorrido | Estilo | Saldo al sentarse | Fichas en comisiones (media) | Manos sin saldo para pedir (total) | Intentos ganados |", "|---|---|---:|---:|---:|---:|"])
	for f: Dictionary in datos.filas:
		lineas.append("| %s | %s | %s | %.1f | %s en %s intentos | %s / %s |" % [f.recorrido, f.estilo, f.saldo_al_sentarse,
			float(f.comisiones) / f.intentos, f.manos_sin_saldo, f.intentos_con_falta, f.victorias, f.intentos])
	return "\n".join(lineas)
