extends SceneTree
## Dependency-free integration harness: composition root + boot scene.

var failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)


func _run() -> void:
	var app := root.get_node_or_null("App")
	check(app != null, "App autoload missing")
	if app != null:
		check(app.environment == "local", "Clean configuration must be local")
		check(app.content.status() == {"schema_version": 1, "loaded": false}, "Content contract")
	var scene: PackedScene = load("res://scenes/boot/boot.tscn")
	check(scene != null, "Boot resource must load")
	if scene != null:
		var boot := scene.instantiate()
		root.add_child(boot)
		check(boot.get_node("Center/Stack/Status").text.begins_with("Foundation ready"), "Boot readiness")
		boot.queue_free()
	print("Foundation tests: ", "PASS" if failures == 0 else "FAIL")
	quit(0 if failures == 0 else 1)
