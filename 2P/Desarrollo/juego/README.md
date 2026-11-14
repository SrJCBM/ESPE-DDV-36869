# La Última Mesa · mesa local del Custodio

Versión **0.1.0**. Godot **4.7.2 estándar**, GDScript, renderer Compatibility y GUT **9.7.1**. Implementa el alcance jugable de I1: 24 cartas, umbral 17, meta 200, diez campanadas, cuatro palos, cinco patrones, victoria, derrota y reinicio.

## Ejecutar en local

1. Abrir Godot 4.7.2 → **Importar** → seleccionar `2P/Desarrollo/juego/project.godot`.
2. Importar y editar; después pulsar **F5**. Se abre la mesa del Custodio.
3. Iniciar mano reparte dos cartas y cuesta una campanada. **Cómo jugar / H** abre el libro de reglas, ejemplos y controles.

| Tecla | Acción |
| --- | --- |
| P | Iniciar / pedir |
| S | Plantarse |
| L | Devolver una Llave elegible |
| H | Consultar reglas |
| R | Reiniciar; pide confirmación si el intento avanzó |
| Tab / Mayús+Tab | Recorrer controles |
| Enter / Espacio | Activar el control enfocado |
| Esc | Cerrar una ventana |

Activar una carta la amplía y explica su palo. La ayuda no consume recursos. **Movimiento reducido**, en «A tu ritmo», desactiva las transiciones de cartas y progreso; se mantiene al reiniciar el intento durante esa sesión. Toda información necesaria se muestra sin depender de animaciones o sonido.

## Demostración repetible

Confirmar **Demostración guiada**. Jugar estas tres manos:

1. P → P → S: 102 puntos.
2. P → P → S: Quiebra, cero puntos adicionales.
3. P → P → P → S: 119 puntos adicionales; victoria con 221 y tres campanadas.

El primer P de cada fila inicia la mano. Es un reparto preparado para revisión; **Reiniciar** vuelve a un intento normal mezclado. Para el piloto I1-07, seguir el protocolo del plan y registrar cuándo se utilizó la demostración.

## Comandos PowerShell

Ejecutar desde la raíz del repositorio. En otro equipo, cambiar la ruta del editor:

```powershell
$GodotExe = "$env:LOCALAPPDATA\Programs\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe"
& $GodotExe --version
& $GodotExe --editor --path '2P/Desarrollo/juego'
```

Para abrir directamente el juego, sin el editor:

```powershell
& $GodotExe --path '2P/Desarrollo/juego'
```

## Pruebas

```powershell
& $GodotExe --headless --editor --path '2P/Desarrollo/juego' --import
& $GodotExe --headless --path '2P/Desarrollo/juego' -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
if ($LASTEXITCODE -ne 0) { throw 'Fallaron las pruebas' }
```

El runner devuelve 0 si todas pasan y distinto de 0 si alguna falla. [Resultados registrados](../REVISION_I1.md).

## Exportar para Windows

En el editor: **Editor → Administrar plantillas de exportación** y comprobar las plantillas **4.7.2**. Después **Proyecto → Exportar → Windows Desktop → Exportar proyecto**, desmarcar exportación de depuración y guardar en `exportaciones/LaUltimaMesa.exe`. El preset ya existe.

También se puede exportar por PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path '2P/Desarrollo/juego/exportaciones' | Out-Null
& $GodotExe --headless --path '2P/Desarrollo/juego' --export-release 'Windows Desktop' 'exportaciones/LaUltimaMesa.exe'
if ($LASTEXITCODE -ne 0) { throw 'Falló la exportación' }
& '.\2P\Desarrollo\juego\exportaciones\LaUltimaMesa.exe'
```

La ruta de salida del comando es relativa a `project.godot`. El preset incrusta el `.pck` en el `.exe`; Godot puede generar también bibliotecas de soporte: conservarlas junto al ejecutable y copiar la carpeta de distribución completa al otro equipo. GUT, pruebas y `exportaciones/` se excluyen del paquete; las salidas no se suben a Git. El piloto y la comprobación en otro equipo siguen pendientes.

## Estructura

```text
principal/   punto de entrada
datos/       definiciones y catálogo de 24 cartas
dominio/     cartas del intento, fábrica, zonas, evaluador, comandos y estados
mesa/        controlador, interfaz, libro del Custodio y marco de ventanas
cartas/      carta visual y transiciones
temas/       tipografía y estilos
recursos/    ilustraciones originales, vectores y fuentes con sus licencias
tests/       reglas, privacidad, interfaz, arranque y capturas reproducibles
addons/gut/  GUT 9.7.1; procedencia y licencia incluidas
```
