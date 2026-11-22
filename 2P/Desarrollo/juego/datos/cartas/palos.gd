class_name Palos
extends RefCounted
## Identificadores de los cuatro palos. Usar estas constantes evita que una errata pase desapercibida.

const VELAS := "velas"
const LLAVES := "llaves"
const RELOJES := "relojes"
const MASCARAS := "mascaras"
const TODOS: Array[String] = [VELAS, LLAVES, RELOJES, MASCARAS]
const NOMBRES := {VELAS: "Velas", LLAVES: "Llaves", RELOJES: "Relojes", MASCARAS: "Máscaras"}

static func es_valido(palo: String) -> bool:
	return TODOS.has(palo)
