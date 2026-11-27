extends GutHookScript
## Antes de cada ejecución de GUT: las pruebas leen y escriben sus propios ajustes y partida, para
## no tocar los de quien juega (por ejemplo, los consejos del tutorial ya vistos).
## Se activa desde .gutconfig.json (línea de órdenes); en el panel de GUT del editor, ponlo como
## «Pre-Run Hook».

func run() -> void:
	AjustesJuego.ruta = "user://ajustes_pruebas.cfg"
	PartidaGuardada.ruta = "user://partida_pruebas.json"
	AjustesJuego.borrar()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PartidaGuardada.ruta))
