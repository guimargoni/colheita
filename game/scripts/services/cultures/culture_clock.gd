extends "res://scripts/services/farming/farm_clock.gd"

func calendar_seconds() -> float:
	return float(source.call())
