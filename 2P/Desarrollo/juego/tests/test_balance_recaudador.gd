extends GutTest
## Balance del Recaudador: misma baraja por semilla, dos recorridos y dos estilos.
## Imprime la tabla y guarda exportaciones/qa/balance_recaudador.json y .md para revisarla.

const Sim := preload("res://tests/sim_recaudador.gd")

func test_balance_del_recaudador_es_reproducible_y_se_registra() -> void:
	var datos: Dictionary = Sim.ejecutar()
	assert_eq(datos.filas.size(), 8)
	var saldos := []
	for fila: Dictionary in datos.filas: saldos.append(fila.saldo_al_sentarse)
	# Ahorra 30 + 15; Compra 30 − Corona (15) − Sello (12) + 15; controles 3 + 15 y 57 − 27 + 15.
	assert_eq(saldos, [45, 45, 18, 18, 18, 18, 45, 45])
	# Misma semilla y recorrido producen exactamente el mismo intento.
	assert_eq(Sim.jugar(7, Sim.RECORRIDOS[1], Sim.ESTILOS[1]), Sim.jugar(7, Sim.RECORRIDOS[1], Sim.ESTILOS[1]))
	var tabla: String = Sim.tabla(datos)
	gut.p("\n" + tabla)
	gut.p("Ejemplo sin saldo (se planta pronto): " + JSON.stringify(datos.ejemplo_sin_saldo, "  "))
	gut.p("Ejemplo carta extra evitada: " + JSON.stringify(datos.ejemplo_carta_extra, "  "))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://exportaciones/qa"))
	var json := FileAccess.open("res://exportaciones/qa/balance_recaudador.json", FileAccess.WRITE)
	json.store_string(JSON.stringify(datos, "  "))
	json.close()
	var md := FileAccess.open("res://exportaciones/qa/balance_recaudador.md", FileAccess.WRITE)
	md.store_string(tabla + "\n")
	md.close()
