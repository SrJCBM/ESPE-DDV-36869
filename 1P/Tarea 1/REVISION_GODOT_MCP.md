# Revisión de Godot y su integración MCP

Comprobación local: 12 de octubre de 2026. Proyecto: La Última Mesa.

## Resultado

Godot y su MCP funcionan en las operaciones verificadas. No fue necesario cambiar la instalación ni la configuración global. Todavía no existe en este repositorio un proyecto Godot definitivo de La Última Mesa. La prueba se hizo en `.godot-mcp-check/`, una carpeta de diagnóstico separada e ignorada por Git. Esa carpeta temporal se retiró en la limpieza del 9 de noviembre de 2026; este informe conserva el registro de las comprobaciones realizadas.

## Instalación

| Elemento | Evidencia local |
|---|---|
| Godot | `4.7.1.stable.official.a13da4feb`, coincide entre CLI y MCP. |
| Ejecutable configurado | `C:\Users\jcbla\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.1-stable_win64.exe` |
| Ejecutable de consola | `Godot_v4.7.1-stable_win64_console.exe` disponible en la misma carpeta. |
| Importación del editor | `--headless --editor --import` terminó sin errores en el diagnóstico. |
| GPU en la prueba | NVIDIA GeForce RTX 4050 Laptop GPU, OpenGL 3.3, Compatibility. |
| Otra GPU detectada | Intel Iris Xe Graphics. |
| Memoria del sistema | Aproximadamente 15,7 GiB, según inventario local. |
| Plantillas de exportación | `4.7.1.stable`, Windows x86_64 debug y release, incluidas variantes console. |
| Plantillas web | No estaban presentes en la carpeta de plantillas consultada. |

La ejecución de la escena funciona. La presencia de plantillas no demuestra que una exportación del videojuego final funcione: no se exportó La Última Mesa porque su implementación Godot todavía no existe. Para usar GDScript no hace falta convertir el proyecto a C#.

## Conector MCP

Configuración inspeccionada: sección `mcp_servers.godot` de `C:\Users\jcbla\.codex\config.toml`.

- Comando: `npx`.
- Argumentos: `-y @coding-solo/godot-mcp`.
- Paquete instalado en la caché: `@coding-solo/godot-mcp`, versión `0.1.1`.
- `GODOT_PATH` apunta al ejecutable Godot encontrado y ejecutado.
- `DEBUG` está activado. Algunas respuestas, como la consulta de UID, incluyen logs además del resultado.

La invocación no fija una versión del paquete. El número anterior identifica el paquete observado en esta revisión, no una garantía para futuras reconexiones. Si cambia la ubicación del ejecutable después de actualizar Godot, habrá que comprobar `GODOT_PATH`.

## Operaciones comprobadas

| Operación | Resultado |
|---|---|
| `get_godot_version` | Versión obtenida correctamente. |
| `list_projects` | Consulta del repositorio correcta. Antes del diagnóstico no encontró proyectos Godot. |
| `create_scene` | Creó `diagnostico.tscn` con raíz Control. |
| `add_node` | Añadió un Label llamado Estado con texto comprobable. |
| `get_project_info` | Leyó estructura y versión del proyecto de diagnóstico. |
| `get_uid` | Obtuvo un UID válido para `diagnostico.gd`. |
| CLI headless | La escena ejecutó el script y sus comprobaciones sin errores. |
| `run_project` | Ejecutó la escena mediante MCP con la GPU NVIDIA. |
| `get_debug_output` | Capturó salida de motor y `MCP_RUNTIME_OK: escena, nodo y GDScript ejecutados`. Lista de errores vacía. |
| `stop_project` | Detuvo la ejecución y devolvió la salida final, sin errores. |

El script verificó la existencia del Label y su texto. La primera consulta de logs después de un cierre automático devolvió “No active Godot process”. Para capturar salida se mantuvo la prueba viva hasta leer sus logs y detenerla mediante MCP. También es necesario dar tiempo al arranque: una lectura inmediatamente después de `run_project` puede tener salida todavía vacía.

## Alcance de la revisión

Se verificaron instalación, importación, escenas, nodos, UID, ejecución y depuración. No se abrió ni se inspeccionó visualmente el editor, y no se probaron exportación de mallas, carga de sprites o herramientas que no necesita este diagnóstico. No se modificaron datos ni proyectos Godot existentes.

La arquitectura del conector usa procesos Godot y operaciones de archivos. Estas pruebas no acreditan sincronización continua con una escena que el usuario tenga abierta en el editor ni validan todas las herramientas disponibles.

## Preparación del proyecto

La decisión vigente es Godot 4 con GDScript. Se construirá una nueva implementación. El prototipo web está descartado como base y solo podrán revisarse sus reglas, casos de prueba, criterios visuales y recursos con licencia compatible.

El siguiente trabajo de desarrollo será crear el proyecto Godot definitivo, sus escenas y las reglas de blackjack. Esta revisión no implementa ese videojuego.

## Referencias

- [Conector Godot MCP](https://github.com/Coding-Solo/godot-mcp).
- [Interfaz Control de Godot](https://docs.godotengine.org/en/stable/classes/class_control.html).
- [Exportación web de Godot](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).
- [Licencia de Godot](https://godotengine.org/license/).
