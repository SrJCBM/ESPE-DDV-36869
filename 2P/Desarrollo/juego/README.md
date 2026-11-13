# La Última Mesa · proyecto Godot (base I1-00)

Base común del juego. Godot **4.7.2 estándar**, GDScript, renderer Compatibility, GUT 9.7.1.
Contiene solo una escena inicial mínima y sus pruebas de arranque; todavía no hay reglas ni interfaz del juego.

## Importar y ejecutar

1. Abrir Godot 4.7.2 → Importar → seleccionar `2P/Desarrollo/juego/project.godot`.
2. Ejecutar con F5. Debe mostrarse "La Última Mesa / Base común I1-00".

## Línea de comandos (PowerShell, desde la raíz del repositorio)

El ejecutable es local; adaptar la ruta.

```powershell
$GodotExe = 'C:\Herramientas\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe'
& $GodotExe --version                                   # 4.7.2.stable.official...
& $GodotExe --headless --editor --path '2P/Desarrollo/juego' --import
& $GodotExe --headless --path '2P/Desarrollo/juego' --quit-after 5
& $GodotExe --headless --path '2P/Desarrollo/juego' -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

## Pruebas

Las pruebas GUT están en `tests/`. El comando anterior devuelve código 0 si todas pasan y distinto de 0 si alguna falla.

## Exportar (Windows)

Requiere las plantillas de exportación **4.7.2 estándar** (carpeta `%APPDATA%\Godot\export_templates\4.7.2.stable`).

```powershell
New-Item -ItemType Directory -Force -Path '2P/Desarrollo/juego/exportaciones' | Out-Null
& $GodotExe --headless --path '2P/Desarrollo/juego' --export-release 'Windows Desktop' 'exportaciones/LaUltimaMesa.exe'
```

El preset "Windows Desktop" incrusta el `.pck` en el `.exe` (un solo archivo). `exportaciones/` está ignorada por Git.
El preset excluye `addons/gut/*` y `tests/*` del ejecutable.

## Estructura

```text
project.godot, export_presets.cfg, icon.svg
principal/   escena principal mínima (principal.tscn / principal.gd)
tests/       pruebas GUT de arranque
addons/gut/  GUT 9.7.1 (ver PROCEDENCIA.md y LICENSE.md)
```
