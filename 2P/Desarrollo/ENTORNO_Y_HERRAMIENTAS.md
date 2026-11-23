# Entorno común y herramientas del equipo

Guía preparada el **9 de noviembre de 2026**; actualizada el **13 de noviembre de 2026**. Versión acordada: **Godot 4.7.2 estándar con GDScript**. Kenned entregó la base; la mesa jugable actual se comprobó técnicamente en Julio. Ariel completó la homologación de I1-00. La revisión del piloto espera comentarios. [Revisión actual](Archivo/I1/REVISION_I1.md) y [antecedente I1-00](Archivo/I1/ENTREGA_I1_00.md).

## Qué necesita cada equipo

| Elemento | Quién lo necesita | Versión y comprobación |
| --- | --- | --- |
| Godot estándar para Windows | Los tres desarrolladores | **4.7.2**, misma versión exacta. Abrir y consultar Acerca de; usar la edición estándar para GDScript |
| Plantillas de exportación | Los tres para poder verificar una entrega | **4.7.2**, coincidentes con el editor; comprobar exportación Windows |
| Git para Windows y acceso a GitHub | Los tres | Versión estable y acceso propio a [SrJCBM/ESPE-DDV-36869](https://github.com/SrJCBM/ESPE-DDV-36869); registrar versión y comprobar lectura/escritura autorizada del repositorio |
| GUT dentro del proyecto | Los tres al clonar el proyecto | **9.7.1**, incorporado y fijado en la base `5d73d50`; cuatro pruebas de arranque pasan en Kenned y Julio; Ariel completó su revisión según el reporte de Julio |
| Navegador | Los tres | Acceso al tablero de tareas, documentación y bocetos compartidos |
| Figma | Principalmente quien diseña y quienes revisan | Aplicación web suficiente para el flujo propuesto; acceso al archivo compartido |
| Cliente de IA con soporte MCP | Quienes decidan usar asistencia con herramientas | Codex es el cliente usado en esta sesión; cada persona configura su cuenta y permisos |
| Node.js y npm | Solo quienes ejecuten Godot MCP local | Para nuevas instalaciones, **Node 24 LTS** con parche vigente y npm incluido; comprobar la compatibilidad del servidor |
| Godot MCP y Context7 | Quienes usen un cliente MCP | Configuración por persona; detalles más abajo |

Descargas y requisitos: [Godot para Windows](https://godotengine.org/download/windows/), [Git para Windows](https://git-scm.com/install/windows), [Node y ramas con soporte](https://nodejs.org/en/about/previous-releases). Seleccionar Godot **4.7.2** aunque la portada de descargas cambie después. Sus plantillas deben corresponder a esa misma versión.

La edición estándar de Godot se distribuye como archivo para extraer y ejecutar. Para este proyecto con GDScript, el editor integrado permite empezar sin instalar un IDE adicional. Node/npm atienden al servidor MCP elegido; no son dependencias del juego distribuido. El proyecto no requiere .NET SDK, Unity, Unreal, un servidor de base de datos ni Python para ejecutar su primera mesa.

## Preparación y homologación

1. Descargar y extraer Godot 4.7.2 desde el sitio oficial. Mantener juntos el ejecutable gráfico y el de consola. Cada persona registra dónde lo extrajo; esa ubicación es local.
2. Instalar las plantillas 4.7.2 desde el gestor de plantillas de exportación del editor.
3. Instalar Git si falta, configurar identidad propia y obtener el repositorio. La carpeta de trabajo del segundo parcial es **2P**.
4. Obtener la base que Kenned publicó en `feat/i1-00-base` (`5d73d50`), en `2P/Desarrollo/juego/`, con GDScript y renderer Compatibility. Ariel y Julio verifican esa misma entrega; no crear proyectos separados. Comprobarla en los tres equipos y revisar antes de integrar en `main`.
5. Usar la copia de GUT 9.7.1 ya incorporada con procedencia y licencia. Los demás la reciben por Git; evitar que cada integrante descargue una versión distinta.
6. Ejecutar una prueba que pase y un fallo preparado para comprobar el runner. Corregir o retirar el fallo preparado antes de integrar la tarea.
7. Ejecutar una escena mínima, crear un preset Windows y abrir su exportación en otro equipo. Registrar editor, plantillas, addon, commit y resultado.

Kenned registró importación, arranque, pruebas y exportación por CLI; su observación visual humana sigue pendiente. Julio repitió importación, arranque, las cuatro pruebas y el fallo temporal; el primer intento de exportación falló por plantillas ausentes. Tras instalar las plantillas Windows 4.7.2 y verificar el SHA-512 oficial, la exportación y el ejecutable en modos headless y gráfico pasan. Se inspeccionaron visualmente editor, escena y ejecutable mediante herramientas; la aceptación humana sigue pendiente. El 18 de noviembre Julio confirmó que Ariel terminó I1-00 e I1-08 y entregó el ejecutable.

### Comandos de comprobación

Desde la raíz del repositorio, en PowerShell. El primer valor es un ejemplo de ubicación elegida por cada persona, no una ruta que deba compartirse en GitHub.

```powershell
$GodotExe = 'C:\Herramientas\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe'
& $GodotExe --version
git --version
```

Solo al usar Godot MCP local:

```powershell
node --version
npm --version
```

Con la base de Kenned y su copia de GUT:

```powershell
& $GodotExe --headless --editor --path '2P/Desarrollo/juego' --import
& $GodotExe --headless --path '2P/Desarrollo/juego' -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

Aceptación: importación sin errores y tests del incremento sin fallos ni errores inesperados. La base actual ya ejecuta cuatro pruebas de arranque con siete aserciones en Kenned y Julio; las pruebas de reglas R01–R20 todavía no existen. GUT ofrece ejecución de tests GDScript y runner de consola; la rama 9.7 incorpora compatibilidad con Godot 4.7. [GUT](https://github.com/bitwes/Gut), [releases](https://github.com/bitwes/Gut/releases), [runner](https://github.com/bitwes/Gut/blob/main/documentation/docs/Command-Line.md).

### Registro que completa cada integrante

| Persona | Godot 4.7.2 | Plantillas 4.7.2 | GUT fijado | Proyecto y tests | Exportación | MCP, si usa |
| --- | --- | --- | --- | --- | --- | --- |
| Ariel | Entorno de I1-00 completado | Comprobación incluida en I1-00 | Sin registro de consola adjunto | I1-00 completada según Julio | I1-08 completada y ejecutable compartido | Sin registro |
| Julio | 4.7.2.stable.official.ed1daf0bf, comprobado por CLI y MCP el 13 nov 2026 | Windows 4.7.2.stable instaladas; archivo oficial verificado con SHA-512 | GUT 9.7.1 recibido por Git y ejecutado | Base: 4/4 pruebas y fallo temporal detectado; incremento actual: suite de reglas, vista, UI y arranque aprobada, con recuento en REVISION_I1.md | Primer fallo por plantillas resuelto; exportación y `.exe` headless/gráfico: código 0; ventana inspeccionada | Godot MCP local compilado; devuelve 4.7.2, nombre correcto y UID; editor, ejecución, depuración y parada verificados. Documentación consultada con Context7 |
| Kenned | 4.7.2.stable.official.ed1daf0bf (13 nov 2026; zip verificado con SHA-512) | 4.7.2.stable instaladas (solo Windows) | GUT 9.7.1 incorporado | Importación, arranque y 4 pruebas pasan (CLI); fallo preparado detectado | Exportación Windows generada y abierta (CLI); apertura visual humana pendiente | Por decidir; Context7 no se usó |

La consulta histórica del MCP devolvió 4.7.1. En esta revisión se invocó explícitamente Godot **4.7.2** por CLI en el equipo de Julio; el resultado histórico del MCP no describe el ejecutable usado para estas pruebas. La versión de cada integrante y la del MCP, si lo usa, se verifican por separado.

## Plugins y herramientas investigados

| Opción | Utilidad concreta | Decisión para este proyecto |
| --- | --- | --- |
| **UI nativa de Godot**: Control, Containers y Theme | Distribución adaptable, tema compartido y estados de foco/botones | Base de la primera iteración; ya forma parte del motor |
| **GUT** | Repetir pruebas de cartas, patrones, costes, estados y reinicio | 9.7.1 incorporado; arranque comprobado en Kenned y Julio. Reglas, estados, privacidad y UI comprobados en la versión actual de Julio; ver REVISION_I1.md |
| **Figma y su plugin para Codex** | Bocetos y revisión de la mesa y sus estados antes de implementarlos | Usar como apoyo de diseño. El catálogo de esta sesión lo muestra instalado; cada integrante necesita sus propios permisos de acceso |
| **ThemeGen** | Generar temas Godot mediante GDScript y reutilizar colores y estilos | Candidato opcional. La documentación declara soporte Godot 4, pero no se ha probado aquí con 4.7.2; hacer una prueba acotada antes de incorporarlo |
| **Context7 MCP** | Consultar documentación actual al implementar APIs y revisar compatibilidad | Recomendado para quienes usen IA con MCP; disponible en esta sesión |
| **Coding-Solo Godot MCP** | Consultar versión, abrir/ejecutar proyectos y recoger salida de depuración | Opcional para asistencia local; servidor comunitario, distinto del motor Godot |

ThemeGen permite reutilizar estilos y colores y generar recursos Theme; esa capacidad no evalúa si el usuario comprende las decisiones. [Repositorio y documentación de ThemeGen](https://github.com/Inspiaaa/ThemeGen).

La búsqueda de plugins para Codex también devolvió Product Design, MagicPath y Canva como opciones no instaladas. Para este primer ciclo se propone aprovechar Figma y la UI del motor; esas otras opciones no se incorporan como dependencias. No se ha instalado ningún plugin nuevo durante esta investigación.

Figma entrega decisiones visuales y recursos; el flujo propuesto implementa la UI en nodos de Godot. Un mockup o un exportador de interfaces web no acredita el comportamiento de una interfaz Godot.

## MCP y utilidades de IA

Un **addon de Godot** vive dentro del proyecto y puede afectar su ejecución. Un **MCP** conecta el cliente de IA con documentación o herramientas del equipo. El ejecutable del juego debe funcionar en un equipo de prueba sin MCP, Node ni Codex.

### Context7

El servidor remoto es `https://mcp.context7.com/mcp`. No requiere ejecutar Node localmente en este modo. Si el proveedor solicita autenticación o se necesita una clave para sus límites de uso, cada integrante utiliza la suya. La configuración por URL y autenticación se documenta en [Context7](https://github.com/upstash/context7#readme).

Comprobación: pedir documentación de Godot indicando versión y tema; el cliente debe resolver la biblioteca y devolver fuentes oficiales relevantes. Verificar después que el ejemplo corresponda a la API que se va a usar.

### Godot MCP local

En el equipo de Julio se usa una copia local del [servidor Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp), compilada desde el commit `1209744` (paquete **0.1.1**), con Node **22.20.0** y Godot **4.7.2**. Se verificaron conexión, nombre del proyecto, versión, UID de un script, apertura del editor, ejecución, salida de depuración sin errores y detención. Se corrigió localmente la lectura del nombre del proyecto del servidor y se añadieron dos pruebas de regresión; ese cambio pertenece al repositorio de la herramienta, fuera del juego. El servidor es comunitario y no forma parte del ejecutable distribuido.

Para usar una copia local, clonar el servidor fuera del repositorio del juego, ejecutar `npm ci` y `npm run build`, y configurar el cliente con `node`, la ruta absoluta a `build/index.js` y `GODOT_PATH` del editor 4.7.2. Reiniciar la conexión después del cambio. Cada integrante configura sus rutas personales; no se versiona esa configuración dentro del juego. [Instrucciones del servidor](https://github.com/Coding-Solo/godot-mcp#readme).

Como alternativa a la copia local, este ejemplo usa el paquete npm fijado. Configuración de usuario para Codex basada en su [documentación MCP](https://learn.chatgpt.com/docs/extend/mcp?surface=cli):

```toml
[mcp_servers.context7]
url = "https://mcp.context7.com/mcp"
# Si el proveedor requiere una clave, configurarla en el entorno personal:
# bearer_token_env_var = "CONTEXT7_API_KEY"

[mcp_servers.godot]
command = "npx"
args = ["-y", "@coding-solo/godot-mcp@0.1.1"]

[mcp_servers.godot.env]
GODOT_PATH = 'C:\Herramientas\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe'
```

Cada persona adapta `GODOT_PATH` al ejecutable real y reinicia la conexión del cliente. La configuración pertenece a su entorno; no se copian claves o rutas personales al repositorio. El servidor documenta esa variable y los requisitos de Node/npm en su [README](https://github.com/Coding-Solo/godot-mcp). La versión del paquete se contrastó con el [registro npm](https://registry.npmjs.org/@coding-solo%2fgodot-mcp/latest).

Comprobación: el MCP debe devolver 4.7.2; después abre la escena mínima, la ejecuta, recoge la salida y la detiene. Estas operaciones se comprobaron en la base I1-00 del equipo de Julio. La consulta de información cuenta también escenas y scripts de GUT; esos totales no representan funcionalidades del juego implementadas. No se necesita instalar otro Godot MCP distinto en cada equipo: elegir y registrar el mismo servidor facilita comparar resultados.

El mínimo recomendado para asistencia es **Context7 + Godot MCP**. Figma se añade para revisar diseños cuando la persona tenga acceso. Otros MCP de navegador, bases de datos o servicios en nube se incorporarán solo si una tarea concreta los necesita.

## Usabilidad y accesibilidad

Las herramientas ayudan a producir y comprobar la interfaz; la observación de personas jugando comprueba su comprensión. La iteración incluye un piloto de tres personas, tareas y una tabla de hallazgos en [ITERACION_01.md](ITERACION_01.md).

- Tema común para texto, botones, foco y paneles; medir contraste antes de aprobar la paleta.
- Símbolos y nombres para los cuatro palos; evitar comunicar reglas solo con color.
- Foco visible, orden de navegación definido y retorno de foco al cerrar ayuda. [Godot, navegación](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html).
- Probar etiquetas accesibles y el orden de lectura si se incorpora lector de pantalla. Godot dispone de integración mediante AccessKit, pero requiere trabajo y pruebas del proyecto. [Godot, accesibilidad](https://docs.godotengine.org/en/stable/tutorials/ui/creating_applications.html).
- Usar [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/basic/) como lista de revisión y el [criterio de contraste de W3C](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) como referencia de diseño.
- La guía de [pruebas moderadas de GOV.UK](https://www.gov.uk/service-manual/user-research/using-moderated-usability-testing) respalda observar tareas con participantes; el tamaño y las tareas del piloto son decisiones de este equipo.

La primera iteración valida legibilidad y comprensión de la mesa. Las pruebas completas de audio, lector de pantalla, ajustes y balance se amplían según se implementen esas funciones. No se declara una certificación de accesibilidad ni resultados de pruebas que todavía no se han hecho.

## Política de versiones y de incorporación

- Fijar Godot y sus plantillas en 4.7.2. No mezclar versiones durante el ciclo sin registrar el cambio y repetir importación, pruebas y exportación.
- Mantener la misma versión de cada addon dentro del proyecto y registrar origen y licencia.
- Probar ThemeGen o cualquier addon nuevo en un cambio acotado antes de integrarlo; aceptar solo si aporta una ventaja al trabajo y permite exportar.
- Versionar escenas, scripts, recursos fuente y presets compartibles; mantener cachés, credenciales y ejecutables generados fuera de los cambios de código.
- Un cambio de addon o motor se revisa igual que una tarea del juego. Clonar el repositorio debe proporcionar las dependencias del proyecto acordadas, y la guía cubre las aplicaciones externas.
- Las herramientas artísticas y de audio adicionales se eligen cuando haya tareas de producción concretas; los recursos provisionales permiten validar primero las reglas y la interfaz.
