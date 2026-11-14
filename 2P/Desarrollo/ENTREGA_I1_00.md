# Entrega I1-00 · base común de Godot

## Alcance de este registro

Este documento conserva la revisión histórica de la base `5d73d50`. Sus cifras de cuatro pruebas y su escena mínima describen esa base, no la mesa jugable posterior. La base ya forma parte de la integración local; la verificación de Ariel y la aceptación humana siguen pendientes. Para el estado vigente consultar [REVISION_I1.md](REVISION_I1.md) y el [tablero](README.md).

**Responsable:** Kenned Sigcha. **Estado de la tarea:** **En curso**. Base entregada e incluida en la integración local de I1; verificación técnica de Julio completada. Faltan comprobación de Ariel y aceptación humana del equipo.
**Entrega y revisión de la base:** 13 de noviembre de 2026. **Commit base:** `e6daeff`. **Rama entregada:** `feat/i1-00-base`. **Commit revisado:** `5d73d5012850f06278f28a19642075f5d1ff836b`. Las comprobaciones siguientes describen la entrega original; la revisión posterior del incremento está en REVISION_I1.md.

## Contenido

`2P/Desarrollo/juego/`: `project.godot` (GDScript, Compatibility, escena principal `res://principal/principal.tscn`), escena mínima, `tests/test_arranque.gd`, `addons/gut/` (GUT 9.7.1, MIT, ver `PROCEDENCIA.md`), `export_presets.cfg` (preset "Windows Desktop" → `exportaciones/LaUltimaMesa.exe`, ignorada por Git), `README.md` con pasos.

No incluye cartas, puntuación, comandos, estados, LAN, tienda, campaña ni diseño final.

## Versiones (equipo de Kenned)

| Elemento | Resultado |
| --- | --- |
| Godot | `4.7.2.stable.official.ed1daf0bf`, descargado del release oficial `godot-builds` 4.7.2-stable; SHA-512 del zip y de las plantillas coinciden con `SHA512-SUMS.txt` |
| Plantillas | 4.7.2.stable, solo Windows, en `%APPDATA%\Godot\export_templates\4.7.2.stable` (la carpeta debe llevar el sufijo `.stable`) |
| GUT | 9.7.1, desde la etiqueta `v9.7.1` de bitwes/Gut |
| Git | 2.45.0.windows.1 |

## Comprobaciones registradas por Kenned (CLI)

| Comprobación | Resultado observado |
| --- | --- |
| `--headless --editor --import` | Código 0; sin líneas de error ni aviso en el registro |
| `--headless --quit-after 5` | Código 0 |
| GUT `-gdir=res://tests -gexit` | 4/4 pruebas, 7 asserts, código 0 |
| Fallo preparado temporal (`assert_eq(1, 2)`) | Runner reportó `Failing Tests 1` y código 1; el archivo se eliminó y las 4 pruebas volvieron a pasar con código 0 |
| `--export-release "Windows Desktop"` | Código 0; `exportaciones/LaUltimaMesa.exe` (~109 MB, `.pck` incrustado). Un primer intento falló porque la carpeta de plantillas no tenía el sufijo `.stable`; se corrigió |
| Ejecución de ejemplo del `.exe` con `--headless --quit-after 5` y con ventana `--quit-after 60` | Código 0; el renderer Compatibility se inicializó (OpenGL 3.3, NVIDIA RTX 3050 Ti) |

Los comandos están en `juego/README.md`.

## Pendiente (no realizado ni observado)

- Aceptación humana del equipo. La inspección visual técnica en Julio ya se realizó mediante herramientas sobre el editor, la escena y el ejecutable; no implica aprobación de los integrantes. La observación humana de Kenned sigue sin registrarse.
- Comprobación completa de Ariel: editor, plantillas, importación, pruebas, exportación y apertura.
- Completar la revisión cruzada humana de la base, incluida en la integración local de I1. La revisión técnica no acredita la verificación del equipo de Ariel ni la aceptación humana del equipo.

## Revisión técnica en el equipo de Julio

Se revisó la entrega `5d73d50` el **13 de noviembre de 2026**, sin modificar sus scripts, escenas, pruebas finales ni presets. Se contrastaron los comandos con la [documentación de Godot 4.7](https://docs.godotengine.org/en/4.7/tutorials/editor/command_line_tutorial.html).

| Comprobación repetida | Resultado observado |
| --- | --- |
| Versión del editor invocado por CLI | `4.7.2.stable.official.ed1daf0bf` |
| Importación `--headless --editor --import` | Código 0, sin errores observados |
| Arranque `--headless --quit-after 5` | Código 0 |
| Runner GUT 9.7.1 | 4/4 pruebas, 7 aserciones, código 0 |
| Fallo temporal añadido solo durante la revisión | Un test con `assert_eq(1, 2)` produjo código 1. Se retiró el archivo temporal y las cuatro pruebas volvieron a pasar, código 0 |
| Exportación Windows, primer intento | Código 1 por ausencia de plantillas `4.7.2.stable`; no se generó el ejecutable. Bloqueo resuelto en la comprobación siguiente |
| Plantillas y repetición de exportación | Archivo oficial de plantillas 4.7.2 verificado con SHA-512; instaladas las variantes Windows. Exportación: código 0, sin errores ni avisos; `.exe` de 109 273 480 bytes con `.pck` incrustado |
| Ejecución del `.exe` en Julio | Headless con `--quit-after 5`: código 0. Ventana abierta, inspeccionada y cerrada: código 0; sin errores en stderr; Compatibility con NVIDIA RTX 4050 Laptop GPU |
| Godot MCP local | Copia compilada del servidor (paquete 0.1.1, base `1209744`) con Godot 4.7.2: versión, nombre del proyecto, UID, apertura del editor, ejecución, captura de salida sin errores y parada comprobados |
| Inspección visual técnica | La escena principal se abrió en 2D en el editor; se observaron las ventanas de la ejecución por MCP y del `.exe` exportado: título y subtítulo de I1-00 visibles; no equivale a la aceptación humana del equipo |
| Git | Autor y committer de `5d73d50`: Kenned Jhair Sigcha Palma; mensaje sin trailers de coautoría |
| Alcance | Una escena mínima, pruebas de arranque, GUT y preset; no hay comandos, estados, cartas ni puntuación |

No se encontraron defectos de arranque en la base revisada. El fallo inicial de exportación en Julio era de entorno y quedó resuelto con las plantillas coincidentes. Estas cuatro pruebas solo acreditan aquella base; las reglas R01–R20 y la mesa jugable posterior se documentan en REVISION_I1.md.

## Siguiente paso

Ariel completa la verificación de su equipo y los tres registran su aceptación humana de la versión integrada. I1-02 e I1-04 ya están completadas; interfaz, comandos y encuentro están disponibles para revisión. Julio realizará I1-07. El estado actual se mantiene en el tablero y en REVISION_I1.md.

## Herramientas de la entrega original

- Context7 no estaba disponible/configurado en la sesión original de Kenned: la configuración se contrastó con la ejecución real de Godot 4.7.2 y GUT 9.7.1, no con consulta de documentación. Godot MCP no se usó.
