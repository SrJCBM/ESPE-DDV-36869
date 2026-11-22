# La Última Mesa · campaña local

Versión **0.2.0** para Godot 4.7.2 estándar. La campaña enlaza el vestíbulo, la tienda y cuatro mesas mediante la galería. [Recorrido y objetos](../ITERACION_02.md).

## Ejecutar en local

1. Abrir Godot 4.7.2 → **Importar** → seleccionar `2P/Desarrollo/juego/project.godot`.
2. Pulsar **F5** para entrar al vestíbulo. Caminar con **WASD o flechas**, interactuar con **E** y consultar el inventario con **I**. Para el piloto de I1, usar su ejecutable o abrir `principal/principal.tscn` con **F6**.
3. Hablar con la anfitriona, recibir las cartas y salir por el sur hacia la galería. En la tienda se ve el coste antes de confirmar. En la mesa, **H** abre la ayuda y **I** muestra los objetos y la regla del crupier.

| Tecla | Acción |
| --- | --- |
| P | Iniciar / pedir; al terminar, volver a jugar |
| S | Plantarse / saltar la revelación |
| L | Elegir / cambiar entre Llaves elegibles; confirmar junto a la carta |
| H | Consultar reglas |
| R | Reiniciar; pide confirmación si el intento avanzó |
| Tab / Mayús+Tab | Recorrer controles |
| Enter / Espacio | Activar el control enfocado |
| Esc | Cancelar la elección de Llave, cerrar una ventana o saltar la revelación |

Activar una Llave elegible la selecciona en la mano: **Confirmar** la devuelve y recibe su reemplazo al final; **Cancelar / Esc** conserva cartas y recursos. No se abre una ventana de selección. Las demás cartas se amplían y explican su palo. P/S están dentro de sus botones y H/R junto a sus controles.

Sin Máscaras, el botón Plantarse anticipa los puntos que ofrece la mano. Con valores ocultos conserva el intervalo y no anticipa la puntuación. El boleto mantiene acumulado y meta. [Coste por mano, patrones y revelación](../ITERACION_01.md#ajuste-de-jugabilidad-del-14-de-noviembre).

La ayuda no consume recursos. **Movimiento reducido**, en «A tu ritmo», desactiva las transiciones de cartas y progreso; se mantiene al reiniciar el intento durante esa sesión. Toda información necesaria se muestra sin depender de animaciones o sonido.

Los cinco indicadores muestran progreso y bonos de patrones. Señalarlos con el ratón o enfocarlos con Tab resalta las cartas relacionadas y muestra una explicación breve; Racha señala las últimas tres. Pulsarlos abre ejemplos. Solo una indicación contextual acompaña la mano: las reglas completas siguen en el libro y el desglose.

Plantarse inicia una revelación breve antes del resultado; se puede saltar con S/Esc y es inmediata con movimiento reducido. Una Quiebra demostrable avisa, pero no cierra la mano automáticamente. Al resolver, la mesa muestra la cuenta y los bonos aplicados; en Quiebra, indica cuánto se excedió el umbral y el aporte cero. Cada Máscara se voltea al revelarse, los puntos de la mano se cuentan hasta su aporte y las cartas saltan con un Punto exacto o tiemblan con una Quiebra. Estas respuestas solo recorren textos ya calculados, se interrumpen al iniciar otra mano y desaparecen con movimiento reducido. El final resume manos válidas y Quiebras y ofrece **Volver a jugar / P**, que abre un intento normal nuevo sin cobrar ni iniciar una mano automáticamente.

## Demostración repetible

Confirmar **Demostración guiada**. Jugar estas tres manos:

1. P → P → S: 102 puntos.
2. P → P → S: Quiebra, cero puntos adicionales.
3. P → P → P → S: 119 puntos adicionales; victoria con 221 y siete campanadas.

El primer P de cada fila inicia la mano. Esperar a la revelación o saltarla con S/Esc antes de iniciar la siguiente. Es un reparto preparado para revisión; **Reiniciar** vuelve a un intento normal mezclado. Para el piloto I1-07, seguir el protocolo del plan y registrar cuándo se utilizó la demostración.

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

Capturas del objetivo de exploración (I2-K2). `progreso` va de -1 (sin invitación) a 4; las imágenes quedan en `exportaciones/qa/`:

```powershell
foreach ($t in '1024x576','1280x720') {
  & $GodotExe --path '2P/Desarrollo/juego' --script res://tests/qa_objetivo.gd -- --sala=vestibulo --progreso=-1 --tamano=$t
  & $GodotExe --path '2P/Desarrollo/juego' --script res://tests/qa_objetivo.gd -- --sala=corredor --progreso=2 --tamano=$t
}
```

## Exportar para Windows

En el editor: **Editor → Administrar plantillas de exportación** y comprobar las plantillas **4.7.2**. Después **Proyecto → Exportar → Windows Desktop → Exportar proyecto**, desmarcar exportación de depuración y guardar en `exportaciones/LaUltimaMesa-I2.exe`. El preset ya existe.

También se puede exportar por PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path '2P/Desarrollo/juego/exportaciones' | Out-Null
& $GodotExe --headless --path '2P/Desarrollo/juego' --export-release 'Windows Desktop' 'exportaciones/LaUltimaMesa-I2.exe'
if ($LASTEXITCODE -ne 0) { throw 'Falló la exportación' }
& '.\2P\Desarrollo\juego\exportaciones\LaUltimaMesa-I2.exe'
```

La ruta de salida del comando es relativa a `project.godot`. El preset incrusta el `.pck` en el `.exe`; Godot puede generar también bibliotecas de soporte: conservarlas junto al ejecutable y copiar la carpeta de distribución completa al otro equipo. GUT, pruebas y `exportaciones/` se excluyen del paquete; las salidas no se suben a Git. El ejecutable de I2 se verificó localmente. Ariel ya distribuyó el de I1 y faltan los comentarios del piloto.

## Estructura

```text
casino/      entrada de I2, salas, movimiento, diálogos y economía
principal/   acceso independiente a la mesa de I1
datos/       definiciones y catálogo de 24 cartas
dominio/     cartas del intento, fábrica, zonas, evaluador, comandos y estados
mesa/        controlador, interfaz, libro del Custodio y marco de ventanas
cartas/      carta visual y transiciones
temas/       tipografía y estilos
recursos/    ilustraciones originales, vectores y fuentes con sus licencias
tests/       reglas, privacidad, interfaz, arranque y capturas reproducibles
addons/gut/  GUT 9.7.1; procedencia y licencia incluidas
```
