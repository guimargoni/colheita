extends RefCounted
## Boundary for future authenticated server commands. No client reward authority.

func snapshot() -> Dictionary:
	return {}

func execute(_command: Dictionary) -> Dictionary:
	return {"ok":false,"error":"service_not_configured"}
