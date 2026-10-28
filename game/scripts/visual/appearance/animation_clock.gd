extends RefCounted
## Shared seconds-based clips. Cosmetic events never execute domain commands.
static func frame(durations: Array,seconds: float,identity: String) -> int:
	var total: float = 0
	for duration in durations: total += float(duration)
	var cursor: float = fposmod(seconds+float(abs(identity.hash())%997)/997.0*total,total)
	for i in range(durations.size()):
		cursor -= float(durations[i])
		if cursor<0: return i
	return 0
static func reaction(age: float,duration: float) -> float:
	return maxf(0,1-age/duration)
