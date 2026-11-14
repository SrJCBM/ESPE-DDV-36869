extends GutTest
## Casos preparados con resultados calculados a mano desde el GDD v2.4.

func c(palo: String, valor: int) -> CartaEnPartida:
	return FabricaCartas.crear_carta(palo, valor)


func test_relojes_reducen_uno_con_minimo_uno_y_otros_palos_conservan_valor() -> void:
	assert_eq(c("relojes", 1).valor_efectivo(), 1)
	assert_eq(c("relojes", 6).valor_efectivo(), 5)
	for palo in ["velas", "llaves", "mascaras"]:
		assert_eq(c(palo, 6).valor_efectivo(), 6)


func test_ejemplo_102_por_exacto_y_ascenso() -> void:
	var r := EvaluadorMano.evaluar([c("llaves", 4), c("relojes", 6), c("mascaras", 8)])
	assert_eq(r.valores, [4, 5, 8])
	assert_eq(r.total, 17)
	assert_false(r.quiebra)
	assert_eq(r.patrones, ["Punto exacto", "Ascenso"])
	assert_eq(r.bonos, {"Punto exacto": 3, "Ascenso": 2})
	assert_eq(r.multiplicador, 6)
	assert_eq(r.puntos, 102)


func test_ejemplo_quiebra_22_anula_todos_los_bonos_y_puntos() -> void:
	var r := EvaluadorMano.evaluar([c("velas", 6), c("relojes", 7), c("mascaras", 10)])
	assert_eq(r.valores, [6, 6, 10])
	assert_eq(r.total, 22)
	assert_true(r.quiebra)
	assert_eq(r.puntos, 0)
	assert_eq(r.patrones, [])
	assert_eq(r.bonos, {})
	assert_eq(r.velas, 0)
	assert_eq(r.multiplicador, 0)


func test_ejemplo_119_suma_tres_velas_y_no_ascenso() -> void:
	var r := EvaluadorMano.evaluar([c("velas", 2), c("velas", 4), c("llaves", 3), c("velas", 8)])
	assert_eq(r.total, 17)
	assert_eq(r.patrones, ["Punto exacto"])
	assert_eq(r.velas, 3)
	assert_eq(r.multiplicador, 7)
	assert_eq(r.puntos, 119)


func test_al_filo_y_exacto_se_excluyen_y_respetan_umbral() -> void:
	var filo := EvaluadorMano.evaluar([c("llaves", 7), c("mascaras", 9)])
	assert_eq(filo.patrones, ["Al filo"])
	assert_eq(filo.bonos, {"Al filo": 2})
	assert_eq(filo.puntos, 48)
	var lejos := EvaluadorMano.evaluar([c("llaves", 7), c("mascaras", 8)])
	assert_eq(lejos.patrones, [])
	assert_eq(lejos.puntos, 15)
	var otro_umbral := EvaluadorMano.evaluar([c("llaves", 9), c("mascaras", 10)], 19)
	assert_eq(otro_umbral.patrones, ["Punto exacto"])
	assert_eq(otro_umbral.puntos, 76)


func test_ascenso_acepta_saltos_pero_exige_toda_mano_y_tres_cartas() -> void:
	var sube := EvaluadorMano.evaluar([c("llaves", 1), c("mascaras", 3), c("relojes", 8)])
	assert_eq(sube.bonos.get("Ascenso", 0), 2)
	assert_eq(sube.puntos, 33)
	for mano in [
		[c("llaves", 1), c("mascaras", 3)],
		[c("llaves", 1), c("relojes", 2), c("mascaras", 3)],
		[c("llaves", 4), c("mascaras", 1), c("relojes", 3), c("llaves", 3)],
	]:
		assert_false(EvaluadorMano.evaluar(mano).bonos.has("Ascenso"))


func test_mano_larga_desde_cinco_y_solo_una_vez() -> void:
	var mano := [c("llaves", 1), c("mascaras", 1), c("relojes", 1), c("llaves", 2)]
	assert_false(EvaluadorMano.evaluar(mano).bonos.has("Mano larga"))
	mano.append(c("mascaras", 3))
	var cinco := EvaluadorMano.evaluar(mano)
	assert_eq(cinco.bonos, {"Mano larga": 2})
	assert_eq(cinco.puntos, 24)
	mano.append(c("relojes", 4))
	assert_eq(EvaluadorMano.evaluar(mano).bonos.get("Mano larga", 0), 2)


func test_racha_mira_solo_tres_ultimas_no_un_grupo_anterior() -> void:
	var mano := [c("llaves", 1), c("llaves", 2), c("llaves", 3)]
	assert_eq(EvaluadorMano.evaluar(mano).bonos.get("Racha", 0), 2)
	mano.append(c("mascaras", 1))
	assert_false(EvaluadorMano.evaluar(mano).bonos.has("Racha"))
	mano.append(c("mascaras", 3))
	mano.append(c("mascaras", 5))
	assert_eq(EvaluadorMano.evaluar(mano).bonos.get("Racha", 0), 2)
	assert_false(EvaluadorMano.evaluar([c("llaves", 1), c("llaves", 2)]).bonos.has("Racha"))


func test_patrones_y_velas_se_acumulan_una_vez_en_mano_valida() -> void:
	var r := EvaluadorMano.evaluar([c("llaves", 1), c("mascaras", 2), c("velas", 3), c("velas", 4), c("velas", 6)])
	assert_eq(r.total, 16)
	assert_eq(r.patrones, ["Al filo", "Ascenso", "Mano larga", "Racha"])
	assert_eq(r.velas, 3)
	assert_eq(r.multiplicador, 12)
	assert_eq(r.puntos, 192)


func test_intervalo_usa_cotas_1_a_10_sin_filtrar_valores_reales() -> void:
	var bajo := [c("llaves", 3), c("relojes", 6), c("mascaras", 1)]
	var alto := [c("llaves", 3), c("relojes", 6), c("mascaras", 10)]
	assert_eq(EvaluadorMano.intervalo(bajo), {"conocido": 8, "ocultas": 1, "minimo": 9, "maximo": 18})
	assert_eq(EvaluadorMano.intervalo(alto), EvaluadorMano.intervalo(bajo))
	assert_eq(EvaluadorMano.intervalo(alto, true), {"conocido": 18, "ocultas": 0, "minimo": 18, "maximo": 18})
	alto.append(c("mascaras", 5))
	assert_eq(EvaluadorMano.intervalo(alto), {"conocido": 8, "ocultas": 2, "minimo": 10, "maximo": 28})


func test_mano_vacia_y_sin_mascaras() -> void:
	var r := EvaluadorMano.evaluar([])
	assert_eq(r.total, 0)
	assert_eq(r.puntos, 0)
	assert_false(r.quiebra)
	assert_eq(r.patrones, [])
	assert_eq(r.multiplicador, 1)
	assert_eq(EvaluadorMano.intervalo([]), {"conocido": 0, "ocultas": 0, "minimo": 0, "maximo": 0})
	assert_eq(EvaluadorMano.intervalo([c("relojes", 1), c("velas", 4)]), {"conocido": 5, "ocultas": 0, "minimo": 5, "maximo": 5})
