# Plan de desarrollo de La Última Mesa

Base de trabajo: documento de diseño v2.4, actualizado el 9 de noviembre de 2026. Las tareas siguientes están pendientes; describen el desarrollo previsto.

El prototipo de Figma ya tiene material preparado para revisión. El [README de coordinación](README.md) registra el reparto de la primera iteración, sus estados actuales y la primera demostración en Godot. El proyecto ejecutable todavía no se ha creado.

## Guía para comenzar

- [Primera iteración con tareas y criterios de aceptación](ITERACION_01.md).
- [Entorno común, instalaciones, MCP y plugins](ENTORNO_Y_HERRAMIENTAS.md).
- [Arquitectura y patrones basados en el material de clase](ARQUITECTURA_Y_PATRONES.md).

**Versión acordada:** Godot **4.7.2 estándar con GDScript** y plantillas **4.7.2**. El desarrollo corresponde a **2P** en [SrJCBM/ESPE-DDV-36869](https://github.com/SrJCBM/ESPE-DDV-36869). La preparación del primer incremento comprobará el entorno de los tres equipos.

## Tecnología y plan de desarrollo

El desarrollo se organizará mediante un modelo iterativo incremental. Cada iteración incorporará una parte jugable, comprobará sus reglas y permitirá ajustar el siguiente trabajo. Esta sección define el motor, las herramientas, la organización y los resultados necesarios para comenzar la implementación de La Última Mesa.

### Motor y herramientas de desarrollo

Se mantiene Godot 4.7.2 estándar con GDScript y Windows como plataforma inicial. La decisión responde al alcance 2D, a las interfaces de cartas, a la exploración compacta y al trabajo con escenas reutilizables. Unity, Unreal Engine y GameMaker fueron considerados en la comparación de motores del curso; esa comparación respalda la elección y se conserva como documento de apoyo.

El equipo registrará la versión exacta del editor y de las plantillas de exportación al preparar el proyecto. Los tres integrantes usarán la misma versión durante cada iteración. Una actualización del motor requerirá comprobar primero que el proyecto abre, ejecuta las reglas y exporta correctamente.

| Herramienta | Uso en el proyecto |
| --- | --- |
| Godot 4 y editor integrado | Crear escenas 2D, interfaz, colisiones, animaciones y audio; ejecutar y depurar el juego. |
| GDScript y Resources de Godot | Implementar reglas y estados; definir cartas, mesas y objetos como datos reutilizables. |
| API multijugador de Godot | Conectar anfitrión y cliente por LAN y sincronizar el estado autorizado de la partida. |
| Git | Registrar cambios, revisar diferencias, integrar tareas y conservar una versión identificable por incremento. |
| Word y Markdown | Mantener el documento de diseño, el plan de tareas, las decisiones y los registros de pruebas. |
| Recursos gráficos y sonoros | Usar material provisional legible durante el prototipo y registrar autor, origen y licencia del material incorporado. |

El prototipo web permanece como antecedente. Sus pruebas describen blackjack tradicional y no acreditan las reglas actuales de umbrales, patrones, campanadas y palos propios. La implementación activa se construirá y verificará en Godot a partir del diseño vigente.

### Organización técnica y del equipo

Se separarán las reglas de la presentación. Un núcleo común calculará cartas, costes, patrones, puntuaciones y cierres. Las escenas se comunicarán mediante señales; la interfaz mostrará la información permitida y enviará acciones para validar. Campaña y LAN utilizarán ese mismo núcleo.

Las escenas cubrirán mesa, carta, visitante, salas, tienda y menús. Los Resources almacenarán las definiciones compartidas de cartas, objetos y mesas. El estado cambiante se mantendrá por intento, separado de esas definiciones, para que una modificación no afecte a otras instancias o partidas. Fichas, sellos, baraja y objetos se restablecerán al reiniciar; los ajustes se conservarán entre sesiones.

En LAN se utilizará ENet con un anfitrión que valide turno, recursos, remitente y acciones. Los mensajes se dirigirán al participante correspondiente. Los valores ocultos y el orden futuro del mazo no se enviarán al cliente rival. La primera prueba se realizará entre dos computadoras de la misma red, con creación y unión por IP local.

#### Distribución inicial propuesta

| Integrante | Responsabilidad principal | Revisión cruzada |
| --- | --- | --- |
| Ariel Llumiquinga | Núcleo de cartas, patrones y pruebas de puntuación. | Revisar reglas de campaña y resultados de integración. |
| Julio Blacio | Interfaz de cartas, exploración e interacción. | Revisar claridad de reglas, controles y recorrido. |
| Kenned Sigcha | Base común, comandos, costes, estados e integración del primer incremento; posteriormente progresión, objetos y coordinación LAN. | Revisar estados, reinicios y conexión entre sistemas. |

Este reparto es una propuesta para acordar al comenzar. Cada tarea tendrá un responsable y otro integrante que revise el resultado. La integración LAN y las pruebas entre equipos requerirán colaboración; la asignación principal no limita la participación de los demás.

El desarrollo se realizará en la carpeta 2P del repositorio de GitHub [SrJCBM/ESPE-DDV-36869](https://github.com/SrJCBM/ESPE-DDV-36869). Allí se mantendrán el proyecto de Godot, el plan de trabajo y las evidencias de cada iteración. Las entregas calificadas se conservarán como antecedentes y el documento de diseño como especificación vigente.

#### Patrones y material de clase

La primera iteración aplicará State para las fases, Observer mediante señales y Command para las acciones; centralizará la creación de cartas con una fábrica simple. Strategy, Prototype y el posible servicio global de ajustes se incorporarán cuando sus funciones lo requieran. La [guía de arquitectura](ARQUITECTURA_Y_PATRONES.md) explica cómo verificar cada decisión y enlaza los tres PDF de clase con sus páginas relevantes.

### Modelo iterativo incremental y entregas

Se proponen ciclos de una semana como referencia inicial. Antes de fijar fechas, el equipo acordará su disponibilidad y la próxima entrega académica. La capacidad real determinará cuántas tareas entran en cada ciclo. Una funcionalidad grande se dividirá en resultados que puedan probarse y demostrarse.

Al iniciar un ciclo se seleccionará un objetivo jugable y sus criterios de aceptación. Durante el análisis se aclararán las reglas; en el diseño se definirán datos, estados e interfaz; en la implementación se integrarán cambios pequeños; y en las pruebas se comprobarán ejemplos y casos límite. Un fallo podrá llevar a revisar el diseño dentro del mismo ciclo.

El cierre incluirá una demostración, el registro de problemas y una revisión de las prioridades. Una iteración también podrá mejorar balance o comprensión de una función existente. El incremento estará listo cuando lo añadido funcione junto con lo anterior y su revisión no deje defectos que impidan cumplir el objetivo.

| Ciclo | Resultado integrado | Criterio de aceptación |
| --- | --- | --- |
| Preparación | Base documental y entorno acordados. | Versión de Godot registrada, tareas priorizadas y reglas del primer incremento confirmadas. |
| 1 | Mesa local del Custodio con el núcleo actual. | Iniciar, pedir, Llaves, Máscaras, cuatro palos y cinco patrones funcionan; hay cierre de mesa y reinicio. |
| 2 | Primera ronda competitiva por LAN. | Dos computadoras completan una ronda; coinciden puntos y turno, y se conserva la información privada. |
| 3 | Primer recorrido con progresión. | El visitante conversa, entra al Custodio, gana un sello, abre una puerta y realiza una compra válida. |
| 4 | Campaña completa. | Las cuatro mesas, tienda, objetos y cambios de baraja permiten llegar a escape o derrota y reiniciar. |
| 5 | Duelo LAN completo. | Tres rondas con umbrales 17, 21 y 25; sala de espera, recursos, desempates, revancha y salida por desconexión. |
| 6 | Versión revisada para Windows. | Campaña y duelo completos con ayuda, controles, ajustes, audio y exportación comprobados en otro equipo. |

Cada fila requiere una versión demostrable; la preparación es un paso previo y todavía no constituye un incremento jugable. El ciclo 2 valida la red antes de ampliar el escenario y realizar el acabado visual. Los ciclos podrán subdividirse según la capacidad del equipo, manteniendo la secuencia de dependencias.

### Inicio del desarrollo y validación

La preparación comenzará por revisar las diferencias entre la conceptualización inicial y el diseño vigente. Se registrará que las reglas actuales utilizan umbrales y palos propios, con campaña y duelo LAN. Después se acordarán responsables, horas disponibles, versión de Godot y una prueba de ejecución y exportación mínima para Windows.

#### Primer incremento

El primer objetivo será jugar una mesa local del Custodio con recursos provisionales. Se implementarán la baraja de veinticuatro cartas, su descarte, los cuatro palos, los cinco patrones, el umbral 17, la meta 200 y las diez campanadas. La mesa deberá terminar en victoria o derrota y permitir un reinicio consistente. La exploración y la tienda se incorporarán en incrementos posteriores.

| Tarea pendiente | Responsable propuesto | Resultado verificable |
| --- | --- | --- |
| Definir datos y estado de la mano | Ariel | Catálogo y datos por intento; mano, mazo y descarte conservan las 24 cartas sin duplicados. |
| Implementar acciones, costes y fases | Kenned; Ariel revisa | Iniciar y pedir cuestan una campanada; plantarse y devolver una Llave no consumen otra; las acciones inválidas no cambian el estado. |
| Construir la mesa y sus controles | Julio | Orden de cartas, umbral, meta, puntos y campanadas visibles; acciones inválidas deshabilitadas. |
| Verificar visibilidad y puntuación | Kenned y Julio; Ariel revisa cálculos | El controlador oculta las Máscaras, la UI representa la vista permitida y el evaluador produce un desglose correcto al resolver. |
| Integrar el encuentro y reinicio | Kenned | Se comprueba meta antes de declarar derrota con cero campanadas; reiniciar restaura el estado. |
| Revisar la versión integrada | Los tres integrantes | Casos de prueba registrados, demostración local y problemas pendientes priorizados. |

#### Pruebas de aceptación iniciales

Se reproducirá el ejemplo 4 de Llaves, 6 de Relojes y 8 de Máscaras: los valores efectivos 4, 5 y 8 suman 17 y producen 102 puntos mediante Punto exacto y Ascenso. También se comprobarán Quiebra, devolución única de Llaves, agotamiento del mazo y resolución de una mano con cero campanadas. Las pruebas usarán repartos preparados para repetir los mismos resultados.

En los incrementos de objetos se añadirán Lente, Corona y sus interacciones. La campaña comprobará la entrega única de quince fichas del Recaudador al llegar con saldo cero, las retenciones de la Coleccionista y el umbral decreciente del Dueño. La prueba LAN comprobará el bloqueo de acciones fuera de turno, las cartas privadas y la desconexión sin adjudicar un ganador.

Una tarea se considerará terminada cuando cumpla su criterio, esté integrada, haya sido revisada por otro integrante y tenga una evidencia breve: pasos, resultado esperado y resultado observado. Las pruebas automáticas se concentrarán en reglas y estados; la comprensión, la interfaz y el balance se revisarán jugando. Los defectos que bloqueen el recorrido se resolverán antes del cierre del ciclo.

El registro de cada iteración incluirá objetivo, tareas completadas, versión o commit, pruebas, problemas y decisión para el ciclo siguiente. Un cambio de reglas actualizará el documento de trabajo y sus pruebas antes de considerarse aceptado. La documentación inicial, el plan y la implementación deberán describir el mismo comportamiento vigente.

#### Fuentes técnicas de consulta

Godot Engine. Organización de escenas. https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html

Godot Engine. Referencia de Resource. https://docs.godotengine.org/en/stable/classes/class_resource.html

Godot Engine. Multijugador de alto nivel. https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html

Consulta de fuentes técnicas: 9 de noviembre de 2026.
