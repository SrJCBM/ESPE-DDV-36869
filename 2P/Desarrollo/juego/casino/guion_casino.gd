class_name GuionCasino
extends RefCounted
## Guion del casino como datos (I5-10, guion v4): conversaciones de la anfitriona, los
## crupieres y los visitantes, y las funciones puras que las adaptan al progreso de la campaña.
## El casino decide cuándo abrir cada una; aquí solo se decide qué dicen.

const ANFITRIONA: Conversacion = preload("res://datos/dialogos/anfitriona.tres")
const PROLOGO: Conversacion = preload("res://datos/dialogos/prologo.tres")
const LLEGADA: Conversacion = preload("res://datos/dialogos/llegada_vestibulo.tres")
const DERROTA: Conversacion = preload("res://datos/dialogos/derrota_v5.tres")
const CRUPIERES := {
	"custodio": preload("res://datos/dialogos/custodio.tres"),
	"recaudador": preload("res://datos/dialogos/recaudador.tres"),
	"coleccionista": preload("res://datos/dialogos/coleccionista.tres"),
	"dueno": preload("res://datos/dialogos/dueno.tres"),
}
const RECUERDOS := {
	"custodio": preload("res://datos/dialogos/fb_campanario.tres"),
	"recaudador": preload("res://datos/dialogos/fb_deuda_muerto.tres"),
	"coleccionista": preload("res://datos/dialogos/fb_habitacion_cristal.tres"),
	"dueno": preload("res://datos/dialogos/fb_apuesta_alba.tres"),
}
const VISITANTES := {
	"amparo": preload("res://datos/dialogos/amparo.tres"),
	"tobias": preload("res://datos/dialogos/tobias.tres"),
	"benavides": preload("res://datos/dialogos/benavides.tres"),
}
## Nombre del protagonista hasta que el jugador pueda elegirlo.
const PROTAGONISTA := {"nombre": "Klein", "apellido": "Moretti"}

## Condiciones de los diálogos: las de la campaña y «mesa_superada» para el crupier de `sala`.
static func condicion(texto: String, sala: String, campana: CampanaCasino) -> bool:
	if texto == "mesa_superada":
		var mesa_actual := CampanaCasino.MESAS.find(sala)
		return mesa_actual >= 0 and mesa_actual < campana.superadas
	if texto == "historia:lore.garantia":
		return campana.cumple(texto) or campana.cumple("historia:garantia")
	return campana.cumple(texto)

## Marcas del guion: el nombre del protagonista, el saludo según el tono y las cifras de la mesa.
static func formatear(texto: String, sala: String, campana: CampanaCasino) -> String:
	var marcas := PROTAGONISTA.duplicate()
	# La anfitriona saluda según el tono de la primera respuesta (guion 7.3).
	var tono := str(campana.historia.get("tono", ""))
	marcas["saludo"] = str(ANFITRIONA.intervencion("saludo_" + tono).get("texto", "")) if not tono.is_empty() else ""
	var regla: ReglaMesa = CampanaCasino.MESAS_CAMPANA.de(sala) if CampanaCasino.MESAS.has(sala) else null
	if regla != null:
		marcas.merge({"umbral": regla.umbral, "meta": regla.meta, "campanadas": regla.campanadas})
	return texto.format(marcas)

## Línea del crupier de `sala` para la victoria o la derrota, o vacío.
static func linea_crupier(id: String, sala: String, campana: CampanaCasino) -> String:
	var conversacion: Conversacion = CRUPIERES.get(sala)
	if conversacion == null:
		return ""
	return formatear(str(conversacion.intervencion(id).get("texto", "")), sala, campana)

## Conversación de un visitante con los retratos de la etapa que corresponde al progreso.
static func visitante(id: String, superadas: int) -> Conversacion:
	var base: Conversacion = VISITANTES.get(id)
	if base == null:
		return null
	var encuentro: Conversacion = base.duplicate(true)
	var etapa := mini(superadas + 1, 3)
	var personaje: Dictionary = encuentro.personajes[id]
	personaje.retrato = "res://historia/retratos/%s_neutral_p%s.webp" % [id, etapa]
	personaje.expresiones = "res://historia/retratos/%s_%%s_p%s.webp" % [id, etapa]
	return encuentro

## Aviso breve de una puerta, con su nombre como hablante.
static func aviso_puerta(titulo: String, mensaje: String) -> Conversacion:
	var aviso := Conversacion.new()
	aviso.personajes = {"puerta": {"nombre": titulo}}
	aviso.entradas = [{"ir": "aviso"}]
	aviso.intervenciones = {"aviso": {"personaje": "puerta", "texto": mensaje}}
	return aviso

## La revisita al crupier tras volver de su recuerdo.
static func revisita(jefe: String) -> Conversacion:
	var conversacion: Conversacion = CRUPIERES[jefe].duplicate()
	conversacion.entradas = [{"ir": "pos_fin_recuerdo"}]
	return conversacion

## Escena de derrota con el crupier de `sala` y, si la hay, la imagen de la última mesa.
static func derrota(sala: String, campana: CampanaCasino, ultima_mesa: Image) -> Conversacion:
	var escena: Conversacion = DERROTA.duplicate(true)
	var jefe: Conversacion = CRUPIERES[sala]
	escena.personajes.jefe = jefe.personajes[sala].duplicate()
	escena.intervenciones.inicio.texto = linea_crupier("derrota", sala, campana)
	escena.fondos.mesa.ruta = "res://casino/arte/%s.webp" % sala
	if ultima_mesa != null and not ultima_mesa.is_empty():
		escena.fondos.mesa.textura = ImageTexture.create_from_image(ultima_mesa)
	return escena

## Las opciones de la oferta inicial muestran el icono y el efecto del catálogo de la tienda.
static func describir_opcion(opcion: Dictionary) -> Dictionary:
	var solicitud := str(opcion.get("solicitud", ""))
	if not solicitud.begins_with("objeto_inicial:"):
		return {}
	var producto := CampanaCasino.TIENDA.buscar(solicitud.trim_prefix("objeto_inicial:"))
	if producto == null:
		return {}
	return {"icono": "res://casino/arte/objeto_%s.webp" % producto.id, "detalle": producto.descripcion}
