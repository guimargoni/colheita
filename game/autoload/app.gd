extends Node
## Composition root. Add services only when an authorized gate needs them.

const ContentServiceScript = preload("res://scripts/services/content_service.gd")

var content: RefCounted = ContentServiceScript.new()
var environment: String = "local"


func _ready() -> void:
	var config := ConfigFile.new()
	if config.load("res://config/local.cfg") == OK:
		var configured: String = str(config.get_value("application", "environment", "local"))
		if configured in ["local", "dev", "staging", "production"]:
			environment = configured
