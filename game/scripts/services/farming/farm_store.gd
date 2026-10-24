extends RefCounted
## One versioned snapshot transaction: seed, crop, product and receipt together.

var path: String
var error: String = ""

func _init(save_path: String) -> void:
	path = save_path

func read() -> Dictionary:
	error = ""
	if not FileAccess.file_exists(path):
		return {"ok":true,"missing":true}
	var file := FileAccess.open(path,FileAccess.READ)
	if file==null:
		return {"ok":false,"error":"save_read_failed"}
	var parser := JSON.new()
	if parser.parse(file.get_as_text())!=OK or not parser.data is Dictionary:
		return {"ok":false,"error":"save_invalid_json"}
	return {"ok":true,"missing":false,"state":parser.data}

func commit(state: Dictionary, expected_revision: int) -> bool:
	error = ""
	var previous := read()
	if not previous.ok or (not previous.missing and int(previous.state.get("revision",-1))!=expected_revision) or (previous.missing and expected_revision!=-1):
		error = "save_conflict"
		return false
	var temp := path+".tmp"
	var file := FileAccess.open(temp,FileAccess.WRITE)
	if file==null:
		error = "save_write_failed"
		return false
	file.store_string(JSON.stringify(state))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error!=OK or DirAccess.rename_absolute(ProjectSettings.globalize_path(temp),ProjectSettings.globalize_path(path))!=OK:
		error = "save_commit_failed"
		return false
	return true
