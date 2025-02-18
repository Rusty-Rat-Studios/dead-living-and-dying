class_name Wall
extends Node3D

const WALL_MATERIAL: StandardMaterial3D = preload("res://map/room/wall_material.tres")
const TRANSPARENT_WALL_MATERIAL: ShaderMaterial = preload("res://map/room/transparent_wall_material.tres")

const TWEEN_DURATION: float = 1.0

var horizontal_wall: bool = false
var transparent: bool = false
var intensity: float = 0.0
var transparent_tween: Tween
var normal_tween: Tween


func _ready() -> void:
	if fmod(rotation.y, 180) == 0:
		horizontal_wall = true


func _process(delta: float) -> void:
	if $WallMesh.get_active_material(0) == TRANSPARENT_WALL_MATERIAL:
		($WallMesh.get_active_material(0) as ShaderMaterial).set_shader_parameter("intensity", intensity)
	if horizontal_wall:
		if (PlayerHandler.get_player().global_position.z < global_position.z 
			and is_visible_in_tree()) and not transparent:
			_apply_material_transparent()
		elif (PlayerHandler.get_player().global_position.z > global_position.z 
			or not is_visible_in_tree()) and transparent:
			_apply_material_normal()


func _apply_material_transparent() -> void:
	transparent = true
	if normal_tween:
		normal_tween.kill()
	$WallMesh.set_surface_override_material(0, TRANSPARENT_WALL_MATERIAL) 
	transparent_tween = create_tween().set_parallel()
	transparent_tween.tween_property(self, "intensity", 1.0, TWEEN_DURATION)


func _apply_material_normal() -> void:
	transparent = false
	if transparent_tween:
		transparent_tween.kill()
	normal_tween = create_tween().set_parallel()
	normal_tween.tween_property(self, "intensity", 0.0, TWEEN_DURATION)
	normal_tween.connect("finished", func() -> void: $WallMesh.set_surface_override_material(0, WALL_MATERIAL))
