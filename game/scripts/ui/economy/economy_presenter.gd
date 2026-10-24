extends "res://scripts/ui/care/care_presenter.gd"

func error_text() -> String:
	var messages := {"crop_level_locked":"Cultura bloqueada: colha para subir de nível.","no_seeds":"Sem sementes desta cultura. Abra a Loja.","value_limit":"Limite de desenvolvimento atingido. Nenhum recurso foi alterado.","plot_occupied":"Este canteiro já está cultivado.","not_mature":"A planta ainda está crescendo."}
	return tr(messages[last_error]) if messages.has(last_error) else super.error_text()
