@tool
extends Wall

@export var length: float = 16.0:
	set(value):
		length = value
		values_changed.emit()


func _ready() -> void:
	super()
	if Engine.is_editor_hint(): # only run as tool
		values_changed.connect(_on_values_changed)


func _on_values_changed() -> void:
	super()
	if wall_mesh != null:
		wall_mesh.mesh.size = Vector3(length, 5, 0.1)
		$CollisionPolygon3D.polygon = PackedVector2Array([
			Vector2(-length/2, 0),
			Vector2(-length/2, 5),
			Vector2(length/2, 5),
			Vector2(length/2, 0)
		])
