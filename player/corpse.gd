class_name Corpse
extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	deactivate()


func reset() -> void:
	deactivate()


func activate() -> void:
	visible = true
	collision_layer = CollisionBit.PLAYER
	collision_mask = CollisionBit.PLAYER


func deactivate() -> void:
	visible = false
	collision_layer = 0
	collision_mask = 0


func _on_body_entered(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		deactivate()
		SignalBus.emit_signal("player_revived", global_position)
