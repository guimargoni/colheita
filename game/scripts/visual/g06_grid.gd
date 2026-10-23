extends RefCounted
## Shared logical ground coordinates, independent of art, viewport and simulation.

static func project(point: Vector2) -> Vector2:
	return Vector2(16*(point.x-point.y),8*(point.x+point.y))

static func unproject(point: Vector2) -> Vector2:
	return Vector2(point.x/32+point.y/16,point.y/16-point.x/32)

static func cells(center: Vector2i, footprint: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for y in range(footprint.y):
		for x in range(footprint.x):
			result.append(center+Vector2i(x,y))
	return result

static func depth_before(a: Dictionary, b: Dictionary) -> bool:
	var da := float(a.at[0])+float(a.at[1])
	var db := float(b.at[0])+float(b.at[1])
	return str(a.id)<str(b.id) if is_equal_approx(da,db) else da<db

static func vec(value: Array) -> Vector2:
	return Vector2(value[0],value[1])
