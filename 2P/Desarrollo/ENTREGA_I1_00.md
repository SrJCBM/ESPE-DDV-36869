# Entrega I1-00 · base común de Godot

**Responsable:** Kenned Sigcha. **Estado de la tarea:** En curso (faltan comprobaciones de Ariel y Julio y la revisión cruzada).
**Fecha:** 13 de noviembre de 2026. **Commit base:** e6daeff. **Rama:** `feat/i1-00-base`. El hash de la entrega es el del commit que contiene este archivo (`git log -1 -- 2P/Desarrollo/ENTREGA_I1_00.md`).

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

## Comprobaciones ejecutadas automáticamente (CLI)

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

- Observación humana: abrir la escena en el editor, ejecutarla y abrir el `.exe` viendo la ventana. Los comandos con ventana solo comprobaron que el proceso termina con código 0.
- Comprobación en el equipo de Ariel y en el de Julio (editor, plantillas, pruebas, exportación); el `.exe` en un segundo equipo.
- Revisión cruzada de la base.
- Context7 no estaba disponible/configurado en esta sesión: la configuración se contrastó con la ejecución real de Godot 4.7.2 y GUT 9.7.1, no con consulta de documentación. Godot MCP no se usó.
