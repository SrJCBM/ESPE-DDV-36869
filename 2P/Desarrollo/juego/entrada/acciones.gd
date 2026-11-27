class_name Acciones
extends RefCounted
## Acciones de entrada del juego (project.godot › Mapa de entrada): cada una tiene su tecla y su
## botón de mando. El código pregunta por la acción, nunca por una tecla concreta, y los textos
## que nombran un atajo lo leen de aquí, así que reasignar una tecla no deja textos desfasados.
## Navegar, aceptar y volver usan las acciones de Godot (ui_*), que ya incluyen el mando.

const PEDIR := &"pedir"
const PLANTARSE := &"plantarse"
const DEVOLVER_LLAVE := &"devolver_llave"
const PATRONES := &"patrones"
const AYUDA := &"ayuda"
const INVENTARIO := &"inventario"
const MAPA := &"mapa"
const SONIDO := &"sonido"
const REINICIAR := &"reiniciar"
const PAUSA := &"pausa"
const INTERACTUAR := &"interactuar"
const VOLVER := &"ui_cancel"
const ACEPTAR := &"ui_accept"

## true para una tecla o un botón de mando recién pulsados (sin repetición). El ratón y los
## ejes no cuentan: esos los resuelve cada control.
static func es_pulsacion(evento: InputEvent) -> bool:
	return (evento is InputEventKey or evento is InputEventJoypadButton) and evento.is_pressed() and not evento.is_echo()

## Nombres cortos para los textos; el resto, como los da Godot.
const NOMBRES_CORTOS := {"Escape": "Esc", "Space": "Espacio"}

## Nombre de la tecla de una acción para los textos («P», «Esc»), o "" si no tiene.
static func tecla(accion: StringName) -> String:
	if not InputMap.has_action(accion):
		return ""
	for evento in InputMap.action_get_events(accion):
		if evento is InputEventKey:
			var codigo: Key = evento.keycode if evento.keycode != KEY_NONE else evento.physical_keycode
			var nombre := OS.get_keycode_string(codigo)
			return NOMBRES_CORTOS.get(nombre, nombre)
	return ""

## «Tecla · Texto», como en las pistas de exploración («M · Plano»).
static func rotulo_previo(texto: String, accion: StringName) -> String:
	var nombre := tecla(accion)
	return texto if nombre.is_empty() else "%s · %s" % [nombre, texto]

## «Texto · Tecla», como en los botones de la mesa («CÓMO JUGAR · H»).
static func rotulo(texto: String, accion: StringName) -> String:
	var nombre := tecla(accion)
	return texto if nombre.is_empty() else "%s · %s" % [texto, nombre]
