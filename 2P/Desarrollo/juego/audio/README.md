# Audio de La Última Mesa

Los WAV incluidos se sintetizaron para el proyecto con ondas sinusoidales, envolventes y ruido filtrado por amplitud. El motivo instrumental dura 12 segundos y el ambiente 8. Las pistas se muestrearon a 22.050 Hz en mono. El ajuste de canal se abre con **V** y se conserva entre sesiones.

| Sonido | Canal | Evento |
| --- | --- | --- |
| Salón sin ventanas | Música | Bucle instrumental no diegético durante la campaña |
| Aire del casino | Ambiente | Bucle que representa el entorno sonoro de las salas |
| Paso, puerta, campana y naipe | Efectos | Desplazamiento efectivo, transición de sala, inicio de mano y movimiento o revelación de cartas |
| Sello y Quiebra | Efectos | Avisos no diegéticos de victoria, Punto exacto y Quiebra |
| Interfaz | Interfaz | Confirmación y muestra del volumen |

El audio pertenece a la presentación. `AudioCasino` convierte eventos aceptados en sonidos y `ControlesSonido` comparte la vista de volumen entre exploración y mesa. Los pasos y naipes varían levemente de tono para evitar repeticiones idénticas. Cada evento de juego tiene una indicación visual.
