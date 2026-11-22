class_name ReglaRecaudador
extends ReglaCrupier
## Entrega fichas de cortesía al sentarse y cobra una por cada carta pedida tras el reparto.

const ENTREGA := 15

func al_sentarse(campana: CampanaCasino) -> void:
	campana.saldo += ENTREGA

func cobra_por_pedir() -> bool:
	return true
