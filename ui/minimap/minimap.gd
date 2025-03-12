extends Control


@onready var camera: Camera3D = $SubViewportContainer/SubViewport/Camera3D
@onready var player: Player = PlayerHandler.get_player()


func _process(delta: float) -> void:
	camera.global_position = Vector3(player.global_position.x, camera.global_position.y, player.global_position.z)
