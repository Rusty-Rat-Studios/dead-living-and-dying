extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	visible = false
	deactivate_collision()


func activate_collision() -> void:
	collision_layer = CollisionBit.PLAYER
	collision_mask = CollisionBit.PLAYER


func deactivate_collision() -> void:
	collision_layer = 0
	collision_mask = 0


func _on_body_entered(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		visible = false
		deactivate_collision()
		SignalBus.emit_signal("player_revived", global_position)
