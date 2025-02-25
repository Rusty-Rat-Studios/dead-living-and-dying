class_name Wall
extends Node3D

const TWEEN_DURATION: float = 1.0

@export var transparent_wall_material: ShaderMaterial
@export var wall_material: StandardMaterial3D

var is_horizontal_wall: bool = false
var is_transparent: bool = false
var intensity: float = 0.0
var transparent_tween: Tween
var normal_tween: Tween


func _ready() -> void:
	if fmod(global_rotation_degrees.y, 180) == 0:
		is_horizontal_wall = true


func _process(_delta: float) -> void:
	if $WallMesh.get_active_material(0) == transparent_wall_material:
		($WallMesh.get_active_material(0) as ShaderMaterial).set_shader_parameter("intensity", intensity)
	if is_horizontal_wall:
		if (PlayerHandler.get_player().global_position.z < global_position.z 
			and is_visible_in_tree()) and not is_transparent:
			_apply_material_transparent()
		elif (PlayerHandler.get_player().global_position.z > global_position.z 
			or not is_visible_in_tree()) and is_transparent:
			_apply_material_normal()


# Changes material to transparent then tweens transparency intensity to 1
func _apply_material_transparent() -> void:
	is_transparent = true
	if normal_tween:
		normal_tween.kill()
	$WallMesh.set_surface_override_material(0, transparent_wall_material) 
	transparent_tween = create_tween().set_parallel()
	transparent_tween.tween_property(self, "intensity", 1.0, TWEEN_DURATION)


# Tweens transparency intensity to 0 then changes material to normal
func _apply_material_normal() -> void:
	is_transparent = false
	if transparent_tween:
		transparent_tween.kill()
	normal_tween = create_tween().set_parallel()
	normal_tween.tween_property(self, "intensity", 0.0, TWEEN_DURATION)
	normal_tween.connect("finished", func() -> void: $WallMesh.set_surface_override_material(0, wall_material))
