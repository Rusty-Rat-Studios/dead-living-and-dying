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

@export var monitor_for_transparency: bool = false

var is_transparent: bool = false
var intensity: float = 0.0
var transparent_tween: Tween
var normal_tween: Tween

var is_vertical: bool = false
var mesh_point1: Vector3 # mesh_point with higher z value
var mesh_point2: Vector3 # mesh_point with lower z value


func _ready() -> void:
	if Engine.is_editor_hint(): # only run as tool
		values_changed.connect(_on_values_changed)
	
	if not Engine.is_editor_hint():
		# Reset mesh material if previously set via tool script
		wall_mesh.set_surface_override_material(0, wall_material)
		
		if abs(fmod(self.global_rotation_degrees.y, 180)) >= 85 and abs(fmod(self.global_rotation_degrees.y, 180)) <= 95:
			is_vertical = true
		
		var aabb: AABB = wall_mesh.get_aabb() # Bounding box around mesh
		if wall_mesh.to_global(aabb.position).z >= wall_mesh.to_global(aabb.end).z:
			mesh_point1 = aabb.position
			mesh_point2 = aabb.end
		else:
			mesh_point1 = aabb.end
			mesh_point2 = aabb.position


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint(): # only run in engine
		if monitor_for_transparency:
			wall_mesh.set_instance_shader_parameter("intensity", intensity)
			if _can_enable_transparency():
				_apply_material_transparent()
			elif _can_disable_transparency():
				_apply_material_normal()


func _can_enable_transparency() -> bool:
	if is_transparent: # If already transparent
		return false
	
	return _is_player_above_wall()


func _can_disable_transparency() -> bool:
	if not is_transparent: # If already not transparent
		return false
	
	return not _is_player_above_wall()


func _is_player_above_wall() -> bool:
	var player_pos: Vector3 = PlayerHandler.get_player().global_position
	
	if is_vertical:
		return player_pos.z <= wall_mesh.to_global(mesh_point2).z
	
	return player_pos.z <= wall_mesh.to_global(mesh_point1).z


# Changes material to transparent then tweens transparency intensity to 1
func _apply_material_transparent() -> void:
	is_transparent = true
	if normal_tween:
		normal_tween.kill()
	wall_mesh.set_surface_override_material(0, transparent_wall_material) 
	transparent_tween = create_tween().set_parallel()
	transparent_tween.tween_property(self, "intensity", 1.0, TWEEN_DURATION)


# Tweens transparency intensity to 0 then changes material to normal
func _apply_material_normal() -> void:
	is_transparent = false
	if transparent_tween:
		transparent_tween.kill()
	normal_tween = create_tween().set_parallel()
	normal_tween.tween_property(self, "intensity", 0.0, TWEEN_DURATION)
	normal_tween.finished.connect(func() -> void: wall_mesh.set_surface_override_material(0, wall_material))


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
