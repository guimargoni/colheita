extends RefCounted
## Geometry/fixture study only. No planting, unlock transaction or progression.

var standard: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/art/visual_standard.json"))

func project(cell: Vector2, height: float = 0) -> Vector2:
	return Vector2((cell.x-cell.y)*16,(cell.x+cell.y)*8-height)

func unproject(point: Vector2) -> Vector2:
	return Vector2(point.x/32+point.y/16,point.y/16-point.x/32)

func fixture(key: String, expanded: bool = false) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var definition: Dictionary = {}
	for entry in standard.fixtures:
		if entry.id==key:
			definition = entry
	if definition.is_empty():
		return result
	for row in range(definition.rows):
		for column in range(definition.columns):
			if definition.avenues and (row%5==4 or column%5==4):
				continue
			# Disposable wedge-shaped access fixture, not an initial product quota.
			var available: bool = expanded or (column+row<4)
			var state := "locked"
			if available:
				state = ["empty","planted","growing","mature"][(column+row)%4]
			result.append({"id":"lab.%d.%d"%[column*2,row*2],"cell":Vector2(column*2,row*2),"state":state,"skin_contract":"cozy.iso.v1"})
	return result

func pick(point: Vector2, plots: Array[Dictionary]) -> int:
	var cell := unproject(point)
	for i in range(plots.size()):
		var offset: Vector2 = cell-plots[i].cell
		# Half-open footprints give every shared edge one stable owner.
		if offset.x>=-1 and offset.y>=-1 and offset.x<1 and offset.y<1:
			return i
	return -1

func bounds(plots: Array[Dictionary]) -> Rect2:
	var result := Rect2(Vector2(-170,-210),Vector2(340,350))
	for plot in plots:
		var point := project(plot.cell)
		result = result.expand(point+Vector2(40,24)).expand(point-Vector2(40,64))
	return result
