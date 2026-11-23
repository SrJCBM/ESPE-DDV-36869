# Dirección artística de La Última Mesa

Usar esta guía cuando una IA genere arte, sonido, diálogos o pantallas para el casino. La referencia visual es la versión integrada en Godot. Los diseños editables y el atlas de I2 están en [FIGMA.md](FIGMA.md). Para reglas y progresión consultar el [documento de diseño](../../../1P/Diseno_Videojuego/Documento_Diseno_La_Ultima_Mesa_v2_4.docx) y la [iteración vigente](../ITERACION_03.md).

## Identidad visual

Casino sobrenatural de finales del siglo XIX. Grabado de libro antiguo para personajes y objetos, con líneas finas y sombreado por tramado. La arquitectura usa mármol, latón envejecido, vidrio, nogal y terciopelo. Las lámparas cálidas iluminan los puntos de interacción. La oscuridad de las paredes enmarca el suelo transitable.

| Uso | Referencia |
| --- | --- |
| Fondo de mesa | Verde profundo `#0B2119` |
| Superficie de diálogo | Verde oscuro `#10251F` |
| Latón, foco y marcos | `#D5B578` |
| Texto de lectura | Marfil `#F1E4C9` |
| Títulos y cifras grandes | Cormorant Garamond |
| Controles, ayuda y objetivos | DM Sans |

## Salas, personajes y palos

| Espacio | Paleta y motivo | Rasgos que deben repetirse |
| --- | --- | --- |
| Vestíbulo | Mármol verde, reloj monumental y lámparas cálidas | Anfitriona de terciopelo verde con horquilla y aro de llaves |
| Galería | Esmeralda, alfombra granate y seis puertas alineadas | Placas y umbrales visibles |
| Tienda | Nogal, ámbar, vitrinas y estantes | Lente ahumada, corona de latón, sello de cera y moneda mellada |
| Custodio | Verde, campanas y péndulo | Máscara larga de latón, ojo de reloj y halo de campanas |
| Recaudador | Granate, balanza, cajones y libro mayor | Entradas pronunciadas, cabello gris peinado hacia atrás, gafas, libro y ábaco |
| Coleccionista | Violeta, vitrinas y cartas expuestas | Semimáscara clara, guantes y vitrina portátil |
| Dueño | Mármol negro, disco solar y verja del alba | Abrigo oscuro y máscara negra con una franja de luz |

Velas usa cera, llamas y polilla. Llaves usa una llave antigua con jaula. Relojes usa un reloj fracturado. Máscaras usa un rostro doble y terciopelo. Cada palo debe poder reconocerse por silueta y nombre.

## Encargo para cada generación

1. Indicar el personaje, sala o componente y enlazar el recurso canónico del repositorio. Si el encargo modifica una pieza, señalar la parte exacta que cambia y los rasgos que deben conservarse.
2. Pedir una salida según su uso. Fondo de sala individual a **1672 × 941** o equivalente 16:9, con cámara cenital coherente, puerta sur centrada y camino libre. Figura de exploración en pose completa, con transparencia y origen en los pies. Retrato como capa independiente. Objeto o carta con un motivo legible al reducirlo.
3. Reservar textos, valores, placas, atajos y botones para Godot o las capas editables de Figma. Mantener una sola acción dominante. Evitar texto ornamental, marcas de agua y decoración sobre el área de interacción.
4. Comprobar encuadre e interacción en Godot a **1024 × 576** y **1280 × 720**. Alinear las huellas de mobiliario en `casino/exploracion/plano_salas.gd` cuando cambie el fondo. Comparar retrato y figura cenital del mismo personaje.
5. Entregar el archivo fuente y la variante optimizada. Registrar la herramienta, el prompt, el original de referencia, el destino y los cambios al importar. Usar WebP para fondos y PNG o WebP con alfa para figuras.

## Interacción y sonido

El objetivo aparece arriba a la izquierda en una línea con un rombo de latón. El aviso de **E** surge por proximidad. En mesa, el valor y el palo tienen prioridad sobre el adorno; una Máscara oculta muestra su estado sin su cifra. Al resolver, los textos de puntos, Quiebra y avance deben funcionar con el audio silenciado y el movimiento reducido.

Pasos, cerrojos, naipes y campanadas son diegéticos. El fondo del casino es diegético y se mezcla en **Ambiente**. El motivo musical de salón, la confirmación de interfaz y los avisos de resultado son no diegéticos. Emplear un ataque corto y colas discretas. Variar levemente el tono de sonidos repetidos. Mantener las cuatro mezclas disponibles en **Sonido · V**.

## Ejemplo de prompt

> Genera un retrato del Recaudador tomando `personaje_recaudador.webp` y `figura_recaudador.webp` como referencias. Conserva las entradas, los mechones grises peinados hacia atrás, las gafas, el libro y el chaleco granate. Grabado de finales del siglo XIX con tramado marfil y latón. Figura aislada, sin texto ni borde, para montarla en el panel de mesa de La Última Mesa.
