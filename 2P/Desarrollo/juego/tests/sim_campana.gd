extends SceneTree
## Simula campañas completas con CampanaCasino, ControladorMesa y los comandos reales.
## La estrategia solo usa la vista pública. Informa, por mesa, cuántos intentos llegan y cuántos la superan.
## godot --headless --path . --script res://tests/sim_campana.gd -- --semillas=500

const ESTRATEGIAS := [
	{"nombre": "Sin compras", "lente": false, "amuletos": []},
	## La de ITERACION_02: Lente al inicio; Corona y Sello en cuanto alcanza el saldo.
	{"nombre": "Lente, Corona y Sello", "lente": true, "amuletos": ["corona", "prudente"]},
]
const MARGENES := [4, 6, 8]
## Variantes con --variantes: {índice de mesa: [meta, campanadas]}. La primera usa las mesas de datos/mesas/mesas_campana.tres sin cambios.
const VARIANTES := [
	{"nombre": "Vigentes", "reglas": {}},
	{"nombre": "Dueño 750/18", "reglas": {3: [750, 18]}},
	{"nombre": "Dueño 800/18", "reglas": {3: [800, 18]}},
	{"nombre": "Dueño 800/17", "reglas": {3: [800, 17]}},
]

func _init() -> void:
	var semillas := 500
	var margen_elegido := -1
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("--semillas="): semillas = int(argumento.get_slice("=", 1))
		if argumento.begins_with("--margen="): margen_elegido = int(argumento.get_slice("=", 1))
	var margenes := MARGENES
	var variantes := VARIANTES.slice(0, 1)
	if OS.get_cmdline_user_args().has("--variantes"):
		margenes = [6]
		variantes = VARIANTES
	if margen_elegido >= 0:
		margenes = [margen_elegido]
	var lineas := PackedStringArray(["| Reglas | Estrategia | Margen | Custodio | Recaudador | Coleccionista | Dueño | Campañas ganadas |", "|---|---|---:|---:|---:|---:|---:|---:|"])
	var combinaciones := []
	var tomar_cartas := OS.get_cmdline_user_args().has("--recompensas")
	for variante: Dictionary in variantes:
		for estrategia: Dictionary in ESTRATEGIAS:
			for margen: int in margenes: combinaciones.append([variante, estrategia, margen])
	for combinacion: Array in combinaciones:
		var variante: Dictionary = combinacion[0]
		var estrategia: Dictionary = combinacion[1]
		var margen: int = combinacion[2]
		var llegan := [0, 0, 0, 0]
		var superan := [0, 0, 0, 0]
		for semilla in range(semillas):
			var superadas := campana(semilla, estrategia, margen, variante.reglas, tomar_cartas)
			for mesa in range(4):
				if superadas >= mesa: llegan[mesa] += 1
				if superadas > mesa: superan[mesa] += 1
		var celdas := PackedStringArray()
		for mesa in range(4):
			celdas.append("%s/%s (%d %%)" % [superan[mesa], llegan[mesa], roundi(100.0 * superan[mesa] / maxi(1, llegan[mesa]))])
		lineas.append("| %s | %s | %s | %s | %d %% |" % [variante.nombre, estrategia.nombre, margen, " | ".join(celdas), roundi(100.0 * superan[3] / semillas)])
	print("Recompensas: ", "tomar la de menor valor efectivo" if tomar_cartas else "omitir")
	print("\n".join(lineas))
	quit()

## Devuelve cuántas mesas superó el intento antes de perder (4 = campaña ganada).
static func campana(semilla: int, estrategia: Dictionary, margen: int, reglas: Dictionary = {}, tomar_cartas := false) -> int:
	var c := CampanaCasino.new()
	c.azar_recompensas.seed = semilla
	c.recibir_invitacion()
	if estrategia.lente: c.comprar("lente")
	for indice in range(4):
		for id: String in estrategia.amuletos: c.comprar(id)
		c.iniciar(CampanaCasino.MESAS[indice])
		var m := ControladorMesa.new()
		m.configurar_campana(c)
		if reglas.has(indice):
			m.partida.meta = reglas[indice][0]
			m.presupuesto = reglas[indice][1]
			m.partida.campanadas = reglas[indice][1]
		m.partida._rng.seed = semilla * 10 + indice
		m.partida.mazo.assign(c.baraja)
		m.partida.descarte.clear()
		m.partida._barajar()
		var victoria := jugar_mesa(m, margen)
		c.cerrar(victoria, m.exactos)
		if c.hay_recompensa():
			c.resolver_recompensa(_carta_menor(c.opciones_recompensa()) if tomar_cartas else -1)
		m.free()
		if not victoria: return indice
	return 4

static func _carta_menor(opciones: Array[Dictionary]) -> int:
	var elegida := 0
	var menor := 11
	for i in range(opciones.size()):
		var carta := opciones[i]
		var valor: int = maxi(1, carta.valor - 1) if carta.palo == Palos.RELOJES else carta.valor
		if valor < menor:
			menor = valor
			elegida = i
	return elegida

static func jugar_mesa(m: ControladorMesa, margen: int) -> bool:
	for _paso in range(600):
		var v := m.obtener_vista()
		if v.terminado: return bool(v.victoria)
		if v.fase == "preparado":
			m.procesar_comando(IniciarMano.new())
			continue
		var iv: Dictionary = v.intervalo
		if int(iv.ocultas) > 0 and m.usar_lente(): continue
		var umbral := int(v.umbral)
		if int(iv.minimo) > umbral:
			var llave := _mejor_llave(v)
			if not llave.is_empty():
				m.procesar_comando(DevolverLlave.new(llave))
				continue
			m.procesar_comando(Plantarse.new())
			continue
		var quiere := (float(iv.minimo) + float(iv.maximo)) / 2.0 <= umbral - margen
		if quiere and bool(v.acciones.pedir):
			m.procesar_comando(PedirCarta.new())
		else:
			m.procesar_comando(Plantarse.new())
	return false

static func _mejor_llave(v: Dictionary) -> String:
	var elegida := ""
	var valor := -1
	for carta: Dictionary in v.cartas:
		if v.llaves_disponibles.has(carta.id) and int(carta.valor) > valor:
			valor = int(carta.valor)
			elegida = carta.id
	return elegida
