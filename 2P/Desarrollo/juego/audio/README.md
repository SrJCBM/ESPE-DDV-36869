# Audio de La Última Mesa

Los WAV incluidos se sintetizaron para el proyecto con ondas sinusoidales, envolventes y ruido filtrado por amplitud. El motivo instrumental dura 12 segundos y el ambiente 8. Las pistas se muestrearon a 22.050 Hz en mono. El ajuste de canal se abre con **V** y se conserva entre sesiones.

| Sonido | Canal | Evento |
| --- | --- | --- |
| Salón sin ventanas | Música | Motivo instrumental de exploración |
| Aire del casino | Ambiente | Bucle que representa el entorno sonoro de las salas |
| Pasillos de los jefes | Ambiente | Péndulo del Custodio, ábaco del Recaudador, cristal de la Coleccionista y aire de la verja del Dueño |
| Temas de mesa | Música | Campanas y contrabajo, piano seco, timbre de cristal y cuerdas graves, respectivamente |
| Paso, puerta, campana y naipe | Efectos | Desplazamiento efectivo, transición de sala, inicio de mano y movimiento o revelación de cartas |
| Sello y Quiebra | Efectos | Avisos no diegéticos de victoria, Punto exacto y Quiebra |
| Porcelana | Efectos | Chasquido seco y breve durante la transformación de Klein al perder |
| Interfaz | Interfaz | Confirmación y muestra del volumen |

El audio pertenece a la presentación. `AudioCasino` convierte eventos aceptados en sonidos y `ControlesSonido` comparte la vista de volumen entre exploración y mesa. Los pasos y naipes varían levemente de tono para evitar repeticiones idénticas. Cada evento de juego tiene una indicación visual.

Los ocho bucles originales de I5 se sintetizaron para el proyecto. Se guardan en `recursos/ambientes_i5/` como WAV PCM mono de 16 bits a 22.050 Hz. Los pasillos duran 24 s y las mesas 96 s. Al entrar en el sector se funde el ambiente en 0,7 s. Sentarse añade el tema de la mesa y levantarse devuelve el motivo de exploración. [Documento de diseño 2.5](../../Diseno/Version_2_5/Documento_Diseno_La_Ultima_Mesa_v2_5.docx).
