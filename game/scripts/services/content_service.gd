extends RefCounted
## Minimal content boundary. No gameplay catalog is loaded during G0.

const SCHEMA_VERSION: int = 1


func status() -> Dictionary:
	return {"schema_version": SCHEMA_VERSION, "loaded": false}
