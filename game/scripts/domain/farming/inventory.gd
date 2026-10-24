extends RefCounted

static func count(items: Dictionary, id: String) -> int:
	return int(items.get(id,0))

static func consume(items: Dictionary, id: String, quantity: int) -> bool:
	if quantity<=0 or count(items,id)<quantity:
		return false
	items[id] = count(items,id)-quantity
	return true

static func credit(items: Dictionary, id: String, quantity: int) -> void:
	items[id] = count(items,id)+quantity
