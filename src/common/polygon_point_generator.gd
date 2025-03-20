# Adapted from kleonc & zendarva at https://www.reddit.com/r/godot/comments/mqp29g/comment/hddil1b/?utm_source=share&utm_medium=web2x&context=3

class_name PolygonPointGenerator


var _polygon: PackedVector2Array
var _triangles: PackedInt32Array
var _cumulated_triangle_areas: Array

var _rand: RandomNumberGenerator


func _init(rand: RandomNumberGenerator, polygon: PackedVector2Array) -> void:
	_polygon = polygon
	_triangles = Geometry2D.triangulate_polygon(_polygon)
	_rand = rand

	var triangle_count: int = _triangles.size() / 3
	assert(triangle_count > 0)
	_cumulated_triangle_areas.resize(triangle_count)
	_cumulated_triangle_areas[-1] = 0
	for i: int in range(triangle_count):
		var a: Vector2 = _polygon[_triangles[3 * i + 0]]
		var b: Vector2 = _polygon[_triangles[3 * i + 1]]
		var c: Vector2 = _polygon[_triangles[3 * i + 2]]
		_cumulated_triangle_areas[i] = _cumulated_triangle_areas[i - 1] + triangle_area(a, b, c)


func get_random_point() -> Vector2:
	var total_area: float = _cumulated_triangle_areas[-1]
	var choosen_triangle_index: int = _cumulated_triangle_areas.bsearch(_rand.randf() * total_area)
	var a: Vector2 = _polygon[_triangles[3 * choosen_triangle_index + 0]]
	var b: Vector2 = _polygon[_triangles[3 * choosen_triangle_index + 1]]
	var c: Vector2 = _polygon[_triangles[3 * choosen_triangle_index + 2]]
	return _random_triangle_point(a, b, c)


func _random_triangle_point(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
	return a + sqrt(randf()) * (-a + b + _rand.randf() * (c - b))


static func triangle_area(a: Vector2, b: Vector2, c: Vector2) -> float:
	return 0.5 * abs((c.x - a.x) * (b.y - a.y) - (b.x - a.x) * (c.y - a.y))


# Only works if polygon is convex and non-intersecting
static func add_margin_to_convex_polygon(polygon: PackedVector2Array, margin: float) -> PackedVector2Array:
	assert(polygon.size() >= 3)
	var newPolygon: PackedVector2Array = []
	for i: int in range(polygon.size()):
		var prev: Vector2 = polygon[polygon.size()-1] if i == 0 else polygon[i-1]
		var current: Vector2 = polygon[i]
		var next: Vector2 = polygon[0] if i == polygon.size()-1 else polygon[i+1]
		var u: Vector2 = next - current
		var v: Vector2 = prev - current
		var bysector_dir: Vector2 = -(u.length() * v + v.length() * u).normalized() # TODO: This might break with convex shapes
		var newVector: Vector2 = current - (bysector_dir * margin)
		newPolygon.append(newVector)
	return newPolygon
