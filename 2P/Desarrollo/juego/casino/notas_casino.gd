class_name NotasCasino
extends RefCounted
## Notas examinables del guion v4 (sección 11): título y texto de cada sala, sus variantes y la
## escena de novela visual que las muestra. Solo datos y funciones puras.

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

static func titulo(sala: String) -> String:
	return str(NOTAS.get(sala, [""])[0])

## La escena de la nota de `sala` según el progreso, o null si la sala no tiene nota.
static func escena(sala: String, campana: CampanaCasino) -> Conversacion:
	if not NOTAS.has(sala):
		return null
	var variante := ""
	match sala:
		"entrada":
			match str(campana.historia.get("farolero", "")):
				"escucho": variante = "entrada_escucho"
				"pregunto_ignacio": variante = "entrada_ignacio"
		"vestibulo":
			if campana.superadas > 0: variante = "vestibulo_sellos"
	var texto: String = NOTAS[sala][1] if variante.is_empty() else str(NOTAS_VARIANTES[variante]).format({"n": mini(campana.superadas, 3)})
	return conversacion_nota("nota_" + (sala if variante.is_empty() else variante), NOTAS[sala][0], texto)

static func conversacion_nota(fondo: String, titulo_nota: String, texto: String) -> Conversacion:
	var datos := Conversacion.new()
	datos.personajes = {"narrador": {"nombre": ""}}
	datos.fondos = {fondo: {"ruta": "res://historia/ilustraciones/%s.webp" % fondo, "movimiento": "acercar", "descripcion": str(ILUSTRACIONES_NOTAS.get(fondo, titulo_nota))}}
	datos.entradas = [{"ir": "nota"}]
	datos.intervenciones = {"nota": {"personaje": "narrador", "modo": "nvl", "fondo": fondo, "texto": "%s\n%s" % [titulo_nota, texto]}}
	return datos
