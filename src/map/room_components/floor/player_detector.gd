@tool
extends Area3D

signal values_changed

@export var polygon: PackedVector2Array:
	set(value):
		polygon = value
		values_changed.emit()


func _ready() -> void:
	if Engine.is_editor_hint(): # only run as tool
		values_changed.connect(_on_values_changed)


func _on_values_changed() -> void:
	$CollisionPolygon3D.polygon = polygon
