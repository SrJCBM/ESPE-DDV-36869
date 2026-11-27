extends SceneTree
## I6-07: genera la partida de respaldo del piloto, justo después de vencer al Custodio y frente
## a su puerta, por si un participante no consigue el primer sello en el tiempo de la sesión.
## godot --headless --path . --script res://tests/qa_piloto_i6_07.gd
## Excluido de la exportación.

const DESTINO := "res://exportaciones/piloto_i6_07/partida_con_sello.json"

func _init() -> void:
	call_deferred("_generar")

func _generar() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DESTINO.get_base_dir()))
	PartidaGuardada.ruta = DESTINO
	AjustesJuego.ruta = "res://exportaciones/piloto_i6_07/ajustes_tmp.cfg"
	var juego: Control = load("res://casino/casino.tscn").instantiate()
	root.add_child(juego)
	await process_frame
	juego.guardado_activo = true
	juego._entregar()
	juego._cerrar()
	# Lo mismo que deja una victoria sin carta: el sello y las diez fichas de la recompensa.
	juego.campana.superadas = 1
	juego.campana.saldo += 10
	juego.entrar("pasillo_custodio", "custodio")
	juego.guardar()
	var datos := PartidaGuardada.cargar()
	print("partida de respaldo: sala=%s superadas=%d saldo=%d" % [datos.get("sala"), datos.campana.get("superadas", -1), datos.campana.get("saldo", -1)])
	AjustesJuego.borrar()
	quit()
