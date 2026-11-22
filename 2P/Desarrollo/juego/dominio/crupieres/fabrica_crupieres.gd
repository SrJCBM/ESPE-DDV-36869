class_name FabricaCrupieres
extends RefCounted
## Elige la regla del crupier de cada mesa. Añadir una mesa es crear su clase y registrarla aquí.

static func para(mesa: String) -> ReglaCrupier:
	match mesa:
		"recaudador": return ReglaRecaudador.new()
		"coleccionista": return ReglaColeccionista.new()
		"dueno": return ReglaDueno.new()
	return ReglaCrupier.new()
