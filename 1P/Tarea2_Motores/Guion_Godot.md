# Guion de exposición: motores y La Última Mesa

Curso: 36869-DESARROLLO DE VIDEO JUEGOS

Integrantes: Ariel Llumiquinga, Julio Blacio y Kenned Sigcha

## Organización y tiempo

Duración orientativa: 13 minutos y 20 segundos más preguntas. Ajustar mediante ensayo al tiempo que indique el docente.

- Ariel Llumiquinga: diapositivas 1–4, 3 min 40 s.
- Julio Blacio: diapositivas 5–9, 5 min 05 s.
- Kenned Sigcha: diapositivas 10–14, 4 min 35 s.
- Diapositivas 15–16: fuentes de apoyo, sin lectura completa.

La Última Mesa es el proyecto documentado del equipo. Los objetivos de la versión completa y el reparto de desarrollo son propuestas. Godot es el motor elegido y GDScript será el lenguaje. El prototipo web anterior está descartado como base. Solo se revisarán referencias y recursos reutilizables.

## Diapositiva 1. Motores de videojuegos

Ariel Llumiquinga · 35 segundos

Buenas tardes. Somos Ariel Llumiquinga, Julio Blacio y Kenned Sigcha, del curso 36869-DESARROLLO DE VIDEO JUEGOS. Compararemos Unity, Unreal Engine, Godot y GameMaker. Vamos a explicar cómo se trabaja con cada motor, sus ventajas y limitaciones y los videojuegos para los que resultan más adecuados. Finalmente, justificaremos una elección para un proyecto académico concreto.

## Diapositiva 2. Criterios de comparación

Ariel Llumiquinga · 45 segundos

Un motor integra herramientas para construir un videojuego, por ejemplo gráficos, entrada del jugador, audio y física. Eso evita comenzar todos esos sistemas desde cero. Para comparar usamos los mismos criterios: flujo de trabajo, programación, capacidades 2D y 3D, aprendizaje, exportación y licencia. La capacidad máxima del motor no basta para decidir. También debemos preguntar cuánto trabajo requiere aprovecharla y si sirve al proyecto que queremos entregar. Las valoraciones de facilidad y adecuación son nuestro análisis, no resultados de un benchmark.

## Diapositiva 3. Unity

Ariel Llumiquinga · 70 segundos

Unity organiza los juegos mediante GameObjects, que contienen componentes. Un personaje puede tener un componente de movimiento, otro de colisión y otro de representación. La programación principal se realiza en C#. Sus herramientas permiten trabajar tanto en 2D como en 3D, y el ecosistema de paquetes y Asset Store puede reducir el trabajo de crear ciertos recursos. Lo elegiríamos para juegos móviles, proyectos multiplataforma o un juego 3D estilizado. La contrapartida es que debemos configurar los paquetes y controlar su compatibilidad. Un recurso descargado no garantiza rendimiento ni mantenimiento. También hay que comprobar qué plan corresponde al equipo. Su versatilidad aporta valor cuando realmente necesitamos varias plataformas o capacidades distintas.

## Diapositiva 4. Unreal Engine

Ariel Llumiquinga · 70 segundos

Unreal combina C++ con Blueprints, un sistema de programación visual. Eso permite probar comportamientos sin escribir toda la lógica en código, aunque sigue siendo necesario comprender variables, eventos y depuración. Nanite gestiona geometría compleja y Lumen proporciona iluminación global y reflejos dinámicos. Estas herramientas ayudan cuando la calidad visual 3D es un requisito central. Las recomendaríamos para acción 3D, aventuras y mundos detallados. A cambio, aumenta la complejidad y hay que revisar los requisitos de hardware de las funciones utilizadas. Unreal también permite juegos 2D mediante Paper 2D. Nuestra crítica es que su orientación y carga de trabajo pueden ser desproporcionadas para un prototipo 2D pequeño. Julio continuará con Godot y GameMaker.

## Diapositiva 5. Godot

Julio Blacio · 70 segundos

Godot utiliza escenas y nodos. Podemos construir una escena de personaje y reutilizarla en varios niveles. Las señales permiten comunicar eventos, por ejemplo cuando el personaje recibe daño. Ofrece GDScript y C#, un sistema 2D dedicado y herramientas 3D. Su licencia MIT permite uso comercial y modificación del motor sin regalías, conservando los avisos legales requeridos. Esto es atractivo para juegos independientes y aprendizaje. Entre sus límites, el ecosistema de soluciones comerciales es menor que el de Unity y las consolas requieren procesos autorizados, SDK propietarios o proveedores especializados. También conviene revisar las restricciones de C# para la plataforma de exportación elegida. Para un juego 2D o un 3D moderado, es una opción sólida si el equipo acepta aprender su arquitectura.

## Diapositiva 6. GameMaker

Julio Blacio · 70 segundos

GameMaker es nuestro cuarto motor. Está especializado en 2D y ofrece GML Code y GML Visual. Podemos programar con texto o con bloques de acciones. El trabajo se organiza en objetos, instancias y eventos, como creación, actualización y colisión. Sus editores de habitaciones, sprites y tilesets permiten preparar niveles con menos herramientas externas. Por eso encaja en plataformas, puzles y juegos con vista superior. Sus límites aparecen cuando necesitamos un 3D complejo o queremos trasladar directamente la lógica a otro motor, porque GML pertenece a este entorno. Crear un juego 2D grande también exige estructura y depuración. La facilidad inicial no elimina esas tareas. Para vender un juego hay que contar con la licencia comercial correspondiente.

## Diapositiva 7. Tabla comparativa técnica

Julio Blacio · 55 segundos

En esta tabla aplicamos los mismos criterios a todos los motores. La organización cambia: Unity usa componentes, Unreal actores, Godot escenas y nodos y GameMaker objetos y eventos. Todos permiten producir videojuegos, pero no ofrecen el mismo camino de trabajo. Unreal destaca por su orientación al 3D avanzado y GameMaker por el 2D. La fila de aprendizaje es una valoración del equipo, porque la dificultad depende de los conocimientos previos. Los destinos tampoco equivalen a exportar con un solo clic. En móvil, web y consolas hay restricciones de versión, licencias, SDK y autorizaciones que debemos verificar.

## Diapositiva 8. Ventajas y desventajas comparadas

Julio Blacio · 55 segundos

Las ventajas tienen que compensar una limitación concreta. En Unity, el ecosistema aporta valor si vamos a aprovecharlo y podemos mantener sus dependencias. En Unreal, la complejidad se justifica cuando necesitamos la producción visual 3D. En Godot, el control del código y la licencia son importantes si buscamos autonomía, aceptando sus límites de ecosistema y consolas. En GameMaker, la especialización acelera la organización de un 2D, pero deja de ser tan ventajosa al exigir un 3D complejo. Por tanto, nuestra comparación relaciona capacidades con costes de trabajo. No afirmamos que un motor produzca siempre más cuadros por segundo que otro.

## Diapositiva 9. Licencias y publicación

Julio Blacio · 55 segundos

La licencia también afecta a la elección. Unity Personal es gratuito dentro de su límite de ingresos y financiación y Unity canceló el Runtime Fee. Unreal aplica una regalía estándar sobre ingresos elegibles que superan un millón de dólares por producto, con exclusiones y posibles descuentos. Godot usa MIT y no cobra regalías del motor, aunque hay que conservar sus avisos legales. GameMaker es gratuito para uso no comercial y ofrece una licencia Professional de pago único para comercializar en plataformas que no son consolas. Las consolas requieren otros permisos y condiciones. Estos términos son un resumen consultado el once de octubre de dos mil veintiséis. Kenned explicará cómo influyen en nuestro caso.

## Diapositiva 10. Proyecto específico: La Última Mesa

Kenned Sigcha · 60 segundos

Nuestro proyecto es La Última Mesa, un videojuego individual de blackjack y estrategia 2D inspirado en las combinaciones de efectos y la progresión de Balatro. El protagonista debe escapar de un casino sobrenatural, ganar fichas y combinar amuletos con consumibles. El alcance contempla una mesa reutilizable, una tienda y tres encuentros. El motor elegido es Godot y el lenguaje será GDScript. El prototipo web anterior está descartado como base. Podremos revisar sus reglas y casos de prueba como referencias, pero construiremos y validaremos una implementación nueva. La meta es una partida completa de diez a veinte minutos con reglas correctas, efectos comprensibles y una condición de victoria o derrota. Todavía no presentamos esa versión Godot como terminada.

## Diapositiva 11. Adecuación a La Última Mesa

Kenned Sigcha · 55 segundos

Esta tabla relaciona los requisitos de La Última Mesa con los cuatro motores. Lo central es representar cartas, responder a controles y resolver turnos y efectos. Unity dispone de componentes y C#. Unreal ofrece interfaz y Blueprints, aunque la producción gráfica 3D avanzada aporta poco a este alcance. GameMaker también permite organizar cartas como objetos y acciones como eventos. Godot reúne nodos Control y contenedores para la interfaz, escenas reutilizables y señales para comunicar acciones. La implementación será nueva en GDScript. La decisión ya es Godot y la comparación explica por qué encaja. Las reglas del prototipo descartado podrán orientar casos, pero no se trasladará su implementación web ni se asumirán sus pruebas como resultados de Godot.

## Diapositiva 12. Motor elegido: Godot

Kenned Sigcha · 65 segundos

Elegimos Godot para implementar La Última Mesa. Los nodos Control y contenedores permiten organizar cartas, botones y mensajes. Las escenas pueden reutilizar la mesa y presentar distintos encuentros. Las señales comunican una acción, como pedir una carta, con la lógica que modifica el estado. GDScript resolverá puntuación, turnos y pagos, mientras que Resources permitirá definir objetos y encuentros como datos. Además, la licencia MIT no exige regalías del motor, conservando sus avisos legales. La elección no garantiza que el juego funcione: debemos implementar y probar sus reglas. Del prototipo descartado solo revisaremos posibles referencias de comportamiento, casos y recursos cuya licencia sea adecuada. Así mantenemos las decisiones útiles sin tratar la demo web como la base del proyecto.

## Diapositiva 13. Plan de trabajo colaborativo

Kenned Sigcha · 50 segundos

Proponemos organizar el trabajo alrededor de los sistemas Godot. Ariel implementaría las reglas y los turnos en GDScript y comprobaría ases, puntuación, exceso y resultados. Julio construiría las escenas de mesa y cartas, los botones y sus señales. Yo definiría los Resources de objetos y encuentros y trabajaría en su integración. Primero completaríamos una mano funcional en Godot. Después conectaríamos encuentros y añadiríamos objetos de forma gradual. Todos revisaríamos el recorrido completo y los cambios mediante Git. Los casos del prototipo descartado pueden ayudarnos a recordar situaciones importantes, pero se ejecutarán nuevas verificaciones sobre la implementación Godot. Estos roles son una propuesta de reparto, no tareas que ya estén terminadas.

## Diapositiva 14. La elección cambia con el proyecto

Kenned Sigcha · 45 segundos

El motor debe responder al proyecto. Unreal tiene sentido cuando necesitamos una producción visual 3D exigente y Unity puede aportar valor para móvil o varias plataformas. GameMaker también es una alternativa para juegos 2D. En La Última Mesa hemos elegido Godot por su sistema de interfaz, escenas reutilizables, comunicación mediante señales y licencia MIT. La nueva implementación utilizará GDScript y su funcionamiento tendrá que comprobarse con reglas y partidas completas. El prototipo web anterior está descartado como base. Conservaremos únicamente referencias o recursos que resulten útiles después de revisarlos. Esta conclusión coincide con la decisión real del equipo y con la documentación actualizada. Con esto cerramos la exposición y quedamos atentos a sus preguntas.

## Diapositiva 15. Fuentes oficiales: Unity y Unreal

Equipo

Estas son las fuentes oficiales que respaldan la información técnica y de licencias de Unity y Unreal. Las valoraciones de dificultad y adecuación pertenecen al equipo. Podemos abrir los enlaces de las notas si se requiere verificar algún punto.

## Diapositiva 16. Fuentes oficiales: Godot y GameMaker

Equipo

Estas fuentes permiten verificar las capacidades de Godot y GameMaker y sus condiciones de publicación. La rúbrica del docente define los cuatro criterios que organizan el trabajo. La imagen de portada es una ilustración generada con IA y no representa capturas reales de los motores.

## Preguntas para preparar la defensa

### ¿Por qué Godot y no GameMaker para este caso?

Godot reúne un sistema de interfaz con Control y contenedores, escenas reutilizables, señales y Resources para organizar los objetos. Además, su licencia MIT permite usar el motor sin regalías. GameMaker también serviría para el 2D, pero el equipo ha elegido Godot como motor del proyecto.

### ¿Cuál es el motor y lenguaje del proyecto?

Godot 4 con GDScript. No se implementará con otro motor ni con frameworks web. Una eventual versión web tendría que exportarse desde Godot.

### ¿El prototipo anterior sigue siendo la base?

No. Está descartado como implementación. Podemos revisar reglas, casos de prueba, criterios de interfaz y recursos con licencia válida. La lógica nueva se implementará y probará en GDScript.

### ¿Cómo se diferencian los amuletos de los consumibles?

Los amuletos producen efectos persistentes durante la partida. Los consumibles desaparecen después de usarlos. El jugador combina ambos para decidir cómo gestionar el riesgo.

### ¿Qué significa inspirado en Balatro?

La inspiración se centra en combinar efectos y avanzar entre rondas. La Última Mesa usa blackjack y propone narrativa, personajes y arte propios.

### ¿Qué está implementado en Godot?

No se presenta todavía una versión Godot del videojuego como terminada. El prototipo web se conserva solo como antecedente descartado y sus verificaciones no prueban la nueva implementación.

### ¿Unreal puede hacer este juego?

Sí. Puede representar interfaz y cartas y resolver la lógica. Su capacidad 3D avanzada aporta poco a este alcance, por lo que valoramos otras herramientas más centradas en 2D.

### ¿GML Visual elimina la programación?

No. Los bloques representan lógica. Es necesario comprender eventos, variables, condiciones y depuración.

### ¿Cuál es el motor más rápido?

No realizamos un benchmark. El rendimiento depende del juego, recursos, configuración y hardware. La decisión aquí se basa en adecuación de herramientas y coste de trabajo.

### ¿GameMaker es completamente gratuito?

El uso no comercial es gratuito. Vender un juego requiere la licencia comercial adecuada. Las consolas tienen condiciones adicionales.

### ¿Cómo comprobarían el nuevo juego?

Probaríamos las reglas de ases, naturales, pagos y turnos sobre GDScript. También comprobaríamos señales, orden de efectos, tienda, reinicio y una partida completa. Los casos anteriores serán referencias y no resultados heredados.

### ¿Qué exige la licencia MIT?

Conservar el aviso de copyright y el texto de la licencia al distribuir el motor. No exige publicar el código del juego ni pagar regalías al motor. Los recursos externos mantienen sus propias licencias.

## Preparación grupal

Ensayar con cronómetro y practicar las preguntas. Todos deben conocer la comparación y explicar la elección de Godot y la reutilización selectiva del prototipo descartado. En las tablas, señalar los criterios relevantes sin leer cada celda. El guion de las diapositivas 10–14 también figura en las notas del PowerPoint.

## Correspondencia con la rúbrica de 20 puntos

- Descripción clara (4 puntos): diapositivas 3–6.
- Análisis comparativo (6 puntos): diapositivas 7–9 y 11.
- Argumentación del motor ideal (6 puntos): diapositivas 10–12 y 14, con requisitos, alternativas y validación de la nueva implementación.
- Exposición y organización (4 puntos): portada, reparto oral, tabla comparativa, propuesta de colaboración y fuentes. El dominio oral requiere ensayo.

## Fuentes consultadas

Fuentes oficiales de la comparación original: consulta del 11 de octubre de 2026. Funciones de interfaz y eventos revisadas el 12 de octubre de 2026.

- https://docs.unity3d.com/Manual/GameObjects.html
- https://unity.com/products/unity-engine
- https://unity.com/products/pricing-updates
- https://dev.epicgames.com/documentation/en-us/unreal-engine/blueprints-visual-scripting-in-unreal-engine
- https://dev.epicgames.com/documentation/en-us/unreal-engine/nanite-virtualized-geometry-in-unreal-engine
- https://dev.epicgames.com/documentation/en-us/unreal-engine/lumen-global-illumination-and-reflections-in-unreal-engine
- https://dev.epicgames.com/documentation/unreal-engine/paper-2d-in-unreal-engine?application_version=5.2
- https://godotengine.org/features/
- https://godotengine.org/license/
- https://godotengine.org/consoles/
- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- https://gamemaker.io/en/features
- https://manual.gamemaker.io/lts/en/GameMaker_Language.htm
- https://gamemaker.io/en/help/articles/gamemaker-faq
- https://www.unrealengine.com/license
- https://unity.com/blog/terms-update-runtime-fee-cancellation
- https://gamemaker.io/en/help/articles/how-to-upgrade-your-gamemaker-licence
- https://docs.godotengine.org/en/stable/classes/class_control.html

## Documentación del proyecto

C:\Users\jcbla\Desktop\ESPE\Septimo Semestre\Videojuegos\1P\Tarea 1\DECISION_GODOT.md

C:\Users\jcbla\Desktop\ESPE\Septimo Semestre\Videojuegos\1P\Tarea 1\README.md

Rúbrica: Rubrica-Tarea2.pdf, Unidad 1, Ing. Paul Pinto.
