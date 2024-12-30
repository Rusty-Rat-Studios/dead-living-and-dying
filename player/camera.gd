extends Camera3D
"""
This script simulates a "lag" effect of the camera following
The player so the direction of motion is more obvious and
appears smoother.

It works by lerping the camera position in the opposite direction
of the player's current velocity, given that it inherits its position
from the Player node. Lerping in the opposite direction simulates the
"lagging" feel.
"""


# speed camera follows the player at
const LAG_STRENGTH: float = 4
# max distance camera can lag behind
const MAX_LAG_DISTANCE: float = 1
# time it takes to reset camera to center when disabled
const RESET_TIME: float = 0.2

@onready var player: CharacterBody3D = PlayerHandler.get_player()
@onready var initial_position: Vector3 = position
# rotation value of the parent RotationOffset (Marker3D) node
@onready var rotation_offset: float = get_parent().rotation.x
# global-space camera position offset from player position
@onready var initial_offset: Vector3 = global_position - player.global_position

func _process(delta: float) -> void:
	
	# get vector opposite to player's current direction
	var velocity_offset: Vector3 = -player.velocity.normalized() * MAX_LAG_DISTANCE
	# base target position off of player position and relative camera offset
	var target_position: Vector3 = player.global_position + initial_offset
	
	# adjust camera offset according to existing rotation (60 degrees)
	# player position.z - 1 translates to:
		# camera position.y + 0.866 (sin60)
		# camera position.z - 0.5 (cos60)
	var camera_offset: Vector3 = velocity_offset
	# values are inverted because camera is moving in the opposite direction
	camera_offset.y = -velocity_offset.z * sin(deg_to_rad(rotation_offset))
	camera_offset.z = velocity_offset.z * cos(deg_to_rad(rotation_offset))

	# calculate the lag target in global space
	var lag_target: Vector3 = target_position + camera_offset
	# maintain fixed camera height in global space
	lag_target.y = global_position.y

	# lerp camera position towards the lag target
	global_position = global_position.lerp(lag_target, LAG_STRENGTH * delta)


func enable() -> void:
	# enable process function
	set_process(true)


func disable() -> void:
	# tween to position centered on character
	get_tree().create_tween().tween_property(self, "position", initial_position, RESET_TIME)
	# disable _process function
	set_process(false)
