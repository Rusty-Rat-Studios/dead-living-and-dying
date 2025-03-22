@tool
class_name Wall
extends Node3D

signal values_changed

const TWEEN_DURATION: float = 1.0

@export var wall_mesh: MeshInstance3D:
	set(value):
		wall_mesh = value
		values_changed.emit()

@export var preview_transparent_material: bool:
	set(value):
		preview_transparent_material = value
		values_changed.emit()

@export var transparent_wall_material: ShaderMaterial:
	set(value):
		transparent_wall_material = value
		values_changed.emit()

@export var wall_material: StandardMaterial3D:
	set(value):
		wall_material = value
		values_changed.emit()

var is_horizontal_wall: bool = false
var is_transparent: bool = false
var intensity: float = 0.0
var transparent_tween: Tween


func _ready() -> void:
	if Engine.is_editor_hint(): # only run as tool
		values_changed.connect(_on_values_changed)
	
	if not Engine.is_editor_hint():
		# Reset mesh material if previously set via tool script
		if wall_material != null:
			wall_mesh.set_surface_override_material(0, wall_material)
		else:
			wall_mesh.set_surface_override_material(0, null)
		
		if fmod(global_rotation_degrees.y, 180) == 0:
			is_horizontal_wall = true


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint(): # only run in engine
		if is_horizontal_wall:
			wall_mesh.set_instance_shader_parameter("intensity", intensity)
			if (PlayerHandler.get_player().global_position.z < global_position.z) and not is_transparent:
				_apply_material_transparent()
			elif (PlayerHandler.get_player().global_position.z > global_position.z) and is_transparent:
				_apply_material_normal()


# Changes material to transparent then tweens transparency intensity to 1
func _apply_material_transparent() -> void:
	is_transparent = true
	wall_mesh.set_surface_override_material(0, transparent_wall_material) 
	transparent_tween = create_tween().set_parallel()
	transparent_tween.tween_property(self, "intensity", 1.0, TWEEN_DURATION)


# Tweens transparency intensity to 0 then changes material to normal
func _apply_material_normal() -> void:
	is_transparent = false
	if transparent_tween:
		transparent_tween.kill()
	wall_mesh.set_surface_override_material(0, wall_material)
	intensity = 0


func _on_values_changed() -> void:
	if wall_mesh != null:
		if preview_transparent_material:
			if transparent_wall_material != null:
				wall_mesh.set_surface_override_material(0, transparent_wall_material)
			else:
				wall_mesh.set_surface_override_material(0, null)
		else:
			if wall_material != null:
				wall_mesh.set_surface_override_material(0, wall_material)
			else:
				wall_mesh.set_surface_override_material(0, null)
