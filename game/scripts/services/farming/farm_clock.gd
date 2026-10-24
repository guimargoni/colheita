extends RefCounted
## Local DEV clock. Neither device time nor the accelerated profile is trusted.

var source: Callable
var rate: float
var profile: String
var source_owner: Object

func _init(provider: Callable = Callable(), multiplier: float = 1.0, name: String = "local.real.v1") -> void:
	source = provider if provider.is_valid() else func() -> float: return Time.get_unix_time_from_system()
	source_owner = provider.get_object() if provider.is_valid() else null
	rate = multiplier
	profile = name

func now_seconds() -> float:
	return float(source.call())*rate
