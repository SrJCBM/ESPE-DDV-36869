extends GutTest
## Balance del Recaudador: misma baraja por semilla, dos recorridos y dos estilos.
## Imprime la tabla y guarda exportaciones/qa/balance_recaudador.json y .md para revisarla.

const Sim := preload("res://tests/sim_recaudador.gd")

func test_balance_del_recaudador_es_reproducible_y_se_registra() -> void:
	var datos: Dictionary = Sim.ejecutar()
	assert_eq(datos.filas.size(), 4)
	var ahorra: Dictionary = datos.filas[0]
	var compra: Dictionary = datos.filas[2]
	assert_eq(ahorra.saldo_al_sentarse, 45, "30 tras el Custodio + 15 del Recaudador")
	assert_eq(compra.saldo_al_sentarse, 18, "30 − Corona (15) − Sello del prudente (12) + 15")
	# Misma semilla y recorrido producen exactamente el mismo intento.
	assert_eq(Sim.jugar(7, Sim.RECORRIDOS[1], Sim.ESTILOS[1]), Sim.jugar(7, Sim.RECORRIDOS[1], Sim.ESTILOS[1]))
	var tabla: String = Sim.tabla(datos)
	gut.p("\n" + tabla)
	gut.p("Ejemplo: " + JSON.stringify(datos.ejemplo, "  "))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://exportaciones/qa"))
	var json := FileAccess.open("res://exportaciones/qa/balance_recaudador.json", FileAccess.WRITE)
	json.store_string(JSON.stringify(datos, "  "))
	json.close()
	var md := FileAccess.open("res://exportaciones/qa/balance_recaudador.md", FileAccess.WRITE)
	md.store_string(tabla + "\n")
	md.close()
