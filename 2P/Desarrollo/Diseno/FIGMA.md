# La Última Mesa · diseño de la primera iteración

**Estado:** prototipo de interacción completado y utilizado como referencia de la implementación Godot 0.1.0. La mesa, cartas, ayuda y controles ya están implementados; la aceptación del equipo y las pruebas con usuarios siguen pendientes. [Revisión del juego](../REVISION_I1.md).

**Figma, cuenta Julio ESPE, equipo Education Videojuegos:** [Mesa del Custodio](https://www.figma.com/design/FtJBoUubQ3lC4jlsZ9RxNq?node-id=13-103). [Baraja revisada](https://www.figma.com/design/FtJBoUubQ3lC4jlsZ9RxNq?node-id=20-482).

**Repositorio:** [SrJCBM/ESPE-DDV-36869](https://github.com/SrJCBM/ESPE-DDV-36869).

## Dirección visual

Casino sobrenatural con cartas de grabado, latón envejecido, marfil y verde profundo. El Custodio tiene una máscara alargada, un ojo de reloj y un halo de campanas. Los cuatro palos tienen ilustraciones originales: cera y polilla, llave con jaula, reloj fracturado y doble máscara con terciopelo. Las orlas, el sello de la Máscara oculta y el reverso siguen siendo vectores editables. Las acciones usan placas biseladas y el objetivo es un boleto troquelado de la casa.

La interfaz es editable por capas: textos, cartas, controles, vectores, estilos y variables. La ilustración del personaje es un recurso raster separado; las pantallas completas no están aplanadas.

- Tipografía de títulos y cifras: Cormorant Garamond SemiBold.
- Tipografía de lectura y acciones: DM Sans Regular/Bold.
- Fondo: `#0B2119`; panel: `#16362A`; marfil: `#EBDDBF`.
- Texto claro: `#F1E4C9`; latón: `#D5B578`; aviso: `#F2B1A3`.
- Marcos de referencia: 1440 × 810, relación 16:9. Godot adapta el lienzo y se revisó en 1024×576, 1280×720 y 1920×1080. El archivo Figma conserva su tamaño de referencia.

## Recorridos preparados

Hay **37 estados de pantalla, 27 cuadros de reglas, puntuación y confirmación, y 13 cuadros para ampliar las cartas**. El reglamento se organiza en cuatro capítulos: mesa, palos, puntuación y Llaves/riesgo. Los cuatro puntos de inicio están disponibles en Presentar:

| Recorrido | Contenido |
| --- | --- |
| 01 · Mesa del Custodio | Tres manos conectadas: 102 puntos, Quiebra y 119 puntos; victoria con 221 acumulados |
| 02 · Decisiones y devolución de Llave | Plantarse antes, pedir, confirmar o cancelar devolución y revisar sus resultados |
| 03 · Terminar sin campanadas | Último reparto; pedir deshabilitado, plantarse gratis y derrota al no alcanzar la meta |
| 04 · Victoria con cero campanadas | Plantarse con 17; sumar 119 y comprobar victoria con 221 antes de declarar derrota |

La devolución de la Llave en la tercera mano tiene dos victorias alternativas: conservar las Velas 2, 4 y 8 produce `14 × 8 = 112`, para 214 acumulados; pedir la Vela 1 produce `15 × 7 = 105`, para 207 acumulados.

Las cartas se pueden ampliar sin cambiar recursos. Los cuadros se cierran con su botón o Escape. Hay atajos configurados para pedir/iniciar (P), plantarse/puntuación (S), Llave (L), ayuda (H) y reinicio (R). El reinicio desde una salida alternativa solicita confirmación.

Los repartos son preparados. Las salidas alternativas terminan en su resultado y permiten reiniciar; no simulan todas las manos futuras ni una baraja aleatoria. Es un prototipo de diseño, no el juego completo. La guía sobre el lienzo explica estos límites.

## Comprobaciones realizadas

- Enlaces y estados de los 185 controles principales, destinos de las pantallas y cierre de diálogos.
- Correspondencia de costes, puntuación y conservación de las 24 cartas en los 37 estados preparados.
- Valor desconocido de las Máscaras en mesa y ampliación; no se muestra su rango real.
- Catálogo de producción con los 24 valores del GDD, incluyendo el mínimo efectivo de los Relojes.
- Capturas de baraja, mesa, manos de cinco cartas, puntuación, confirmaciones y detalles ampliados. Se corrigieron el contraste de confirmación y la separación de la unidad de puntos.
- Tipografía de las cartas vinculada a los estilos compartidos del archivo.
- Familias LUM consolidadas: seis variantes de cartas y ocho de acciones, con texto configurable, puntero, foco y deshabilitado. Los controles del prototipo utilizan instancias de esta biblioteca.
- Reglamento ilustrado por capítulos, con navegación, cierre sin consumir recursos y el nombre **Al filo** utilizado por el DOCX.

La auditoría estructural no encontró problemas. No sustituye una prueba manual en el reproductor con usuarios, ni acredita navegación por Tab o compatibilidad con lectores de pantalla.

## Baraja inicial y cargas preparadas

El GDD define 24 cartas iniciales, seis por palo. No define compra ni desbloqueo de cartas adicionales. Durante un intento se pueden eliminar cartas hasta conservar al menos doce y ajustar valores entre uno y diez; las retenciones de la Coleccionista son temporales. Amuletos y consumibles son objetos independientes. En LAN cada participante recibe su propia baraja de 24 por ronda.

Las fuentes de esta revisión están en `figma-src/`. `preparar_cargas.py` concatena los helpers y cada fase, incorpora los IDs registrados, comprueba el límite de entrada y valida la sintaxis con Node sin enviar peticiones a Figma. Deja cuatro cargas en `figma-src/cargas_preparadas/`; las fases de creación tienen guardas para no duplicar trabajo aplicado. La sintaxis local no sustituye la validación visual y de relaciones en Figma.

Las cargas generadas se excluyen de Git. Para regenerarlas desde la raíz del repositorio, ejecutar `python 2P/Desarrollo/Diseno/figma-src/preparar_cargas.py`; esta utilidad necesita Python y Node, y solo se usa para mantener el diseño.

[Abrir el reglamento](https://www.figma.com/design/FtJBoUubQ3lC4jlsZ9RxNq?node-id=21-7212) · [Ver LUM](https://www.figma.com/design/FtJBoUubQ3lC4jlsZ9RxNq?node-id=7-87).

## Recursos y procedencia

`recursos/custodio-grabado.png`: ilustración original generada con la herramienta de imágenes para este proyecto, PNG RGBA de 1024 × 1536. La misma imagen de resolución completa está colocada en Figma.

Dirección utilizada para la generación: retrato vertical de un crupier sobrenatural llamado El Custodio; máscara de latón envejecido con un ojo de reloj; halo de campanas; vestimenta de terciopelo oscuro y guantes sosteniendo una carta de marfil sin texto; grabado antiguo con tramado fino, marfil y latón; fondo transparente. Sin interfaz, números, marcas de agua ni personajes de otras obras. Esta descripción conserva la dirección artística y no pretende ser una transcripción literal del prompt.

`recursos/carta-velas-grabado.png`, `carta-llaves-grabado.png`, `carta-relojes-grabado.png` y `carta-mascaras-grabado.png`: cuatro ilustraciones generadas con la herramienta integrada `image_gen`, PNG RGBA de 1024 × 1536, incorporadas a las cartas de Figma. Los prompts exactos se conservan en [cartas-prompts.json](recursos/cartas-prompts.json). Valores, nombres, efectos y geometría de las cartas permanecen editables.

## Revisión de diseño y aceptación

- Verificar con Ariel la correspondencia entre reglas, costes, valores efectivos y puntuación.
- Comprobar que ninguna etiqueta o interacción revela el valor de una Máscara oculta.
- Probar con tres personas si identifican meta, umbral, coste de pedir y consecuencia de plantarse.
- Revisar contraste, tamaño de lectura, foco de teclado y estados deshabilitados; la revisión visual no sustituye estas pruebas.
- Los atajos y el foco/Tab están implementados y comprobados técnicamente en Godot, incluida la confirmación de Llave; falta la revisión humana del equipo.
- En Godot, conservar textos, controles y contenedores nativos. Usar la ilustración como recurso independiente y no exportar la mesa completa como una sola imagen.

I1-01 e I1-05 quedan Por revisar: la interfaz está implementada y conectada al dominio. La aceptación humana y el piloto I1-07 siguen pendientes.
