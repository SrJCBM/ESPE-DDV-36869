# Entorno común y herramientas del equipo

Guía preparada el **9 de noviembre de 2026** para los tres integrantes de La Última Mesa. La versión acordada con Julio es **Godot 4.7.2 estándar con GDScript**. Este documento recomienda y describe instalaciones; no acredita que se hayan realizado en los tres equipos.

## Qué necesita cada equipo

| Elemento | Quién lo necesita | Versión y comprobación |
| --- | --- | --- |
| Godot estándar para Windows | Los tres desarrolladores | **4.7.2**, misma versión exacta. Abrir y consultar Acerca de; usar la edición estándar para GDScript |
| Plantillas de exportación | Los tres para poder verificar una entrega | **4.7.2**, coincidentes con el editor; comprobar exportación Windows |
| Git para Windows y acceso a GitHub | Los tres | Versión estable y acceso propio a [SrJCBM/ESPE-DDV-36869](https://github.com/SrJCBM/ESPE-DDV-36869); registrar versión y comprobar lectura/escritura autorizada del repositorio |
| GUT dentro del proyecto | Los tres al clonar el proyecto | **9.7.1** como base propuesta de la rama 9.7 para Godot 4.7; fijar la versión tras el test de homologación |
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
4. Durante I1-00, Kenned crea una sola base del proyecto en `2P/Desarrollo/juego/`, con GDScript y renderer Compatibility como propuesta inicial para este 2D. Ariel y Julio obtienen esa misma base del repositorio. Comprobarla en los tres equipos antes de fijar la configuración.
5. Incorporar una sola copia de GUT 9.7.1 al proyecto y registrar su procedencia y versión. Los demás reciben esa copia a través de Git; evitar que cada integrante descargue una versión distinta.
6. Ejecutar una prueba que pase y un fallo preparado para comprobar el runner. Corregir o retirar el fallo preparado antes de integrar la tarea.
7. Ejecutar una escena mínima, crear un preset Windows y abrir su exportación en otro equipo. Registrar editor, plantillas, addon, commit y resultado.

Las comprobaciones anteriores son tareas pendientes del primer ciclo. La compatibilidad declarada de una dependencia no sustituye la comprobación en el proyecto.

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

Después de crear el proyecto, incorporar GUT y escribir tests:

```powershell
& $GodotExe --headless --editor --path '2P/Desarrollo/juego' --import
& $GodotExe --headless --path '2P/Desarrollo/juego' -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

Aceptación: importación sin errores y tests del incremento sin fallos ni errores inesperados. El comando de pruebas todavía no se ha ejecutado porque no existe el proyecto de juego. GUT ofrece ejecución de tests GDScript y runner de consola; la rama 9.7 incorpora compatibilidad con Godot 4.7. [GUT](https://github.com/bitwes/Gut), [releases](https://github.com/bitwes/Gut/releases), [runner](https://github.com/bitwes/Gut/blob/main/documentation/docs/Command-Line.md).

### Registro que completa cada integrante

| Persona | Godot 4.7.2 | Plantillas 4.7.2 | GUT fijado | Proyecto y tests | Exportación | MCP, si usa |
| --- | --- | --- | --- | --- | --- | --- |
| Ariel | Pendiente | Pendiente | Pendiente | Pendiente | Pendiente | Por decidir |
| Julio | Pendiente | Pendiente | Pendiente | Pendiente | Pendiente | Configuración previa detectada; repetir con 4.7.2 |
| Kenned | Pendiente | Pendiente | Pendiente | Pendiente | Pendiente | Por decidir |

Una consulta del MCP durante esta preparación devolvió 4.7.1 y se encontraron archivos con ese nombre. Eso no cambia la versión elegida ni acredita una instalación nueva. Se comprobará expresamente el ejecutable 4.7.2 que cada integrante vaya a utilizar.

## Plugins y herramientas investigados

| Opción | Utilidad concreta | Decisión para este proyecto |
| --- | --- | --- |
| **UI nativa de Godot**: Control, Containers y Theme | Distribución adaptable, tema compartido y estados de foco/botones | Base de la primera iteración; ya forma parte del motor |
| **GUT** | Repetir pruebas de cartas, patrones, costes, estados y reinicio | Adoptar al preparar el entorno y comprobar la versión elegida |
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

La configuración existente en esta máquina utiliza el paquete `@coding-solo/godot-mcp`. El registro npm consultado publica **0.1.1** y declara **Node >=18**; se propone fijar esa versión como punto de partida y repetir la comprobación con Godot 4.7.2. Esto no certifica su compatibilidad completa ni convierte al servidor comunitario en un componente oficial de Godot.

Ejemplo de configuración de usuario para Codex, basado en su [documentación MCP](https://learn.chatgpt.com/docs/extend/mcp?surface=cli):

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

Comprobación: el MCP devuelve 4.7.2; después abre la escena mínima, la ejecuta, recoge la salida y la detiene. Hacerlo con el proyecto de prueba de I1-00. No se necesita instalar otro Godot MCP distinto en cada equipo: elegir y registrar el mismo servidor facilita comparar resultados.

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
