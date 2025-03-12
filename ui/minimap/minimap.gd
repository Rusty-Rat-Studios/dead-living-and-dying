extends Control


@onready var camera: Camera3D = $SubViewportContainer/SubViewport/Camera3D
@onready var player: Player = PlayerHandler.get_player()


func _process(delta: float) -> void:
	camera.global_position = Vector3(player.global_position.x, camera.global_position.y, player.global_position.z)


func _draw() -> void:
	var size: Vector2 = get_parent_area_size()
	draw_rect(Rect2(Vector2(0, 0), Vector2(500, 500)), Color.WHITE)
