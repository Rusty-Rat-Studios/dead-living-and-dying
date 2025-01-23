class_name Corpse
extends Area3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	deactivate()


func reset() -> void:
	deactivate()


func activate() -> void:
	visible = true
	collision_shape.set_deferred("disabled", false)


func deactivate() -> void:
	visible = false
	collision_shape.set_deferred("disabled", true)


func _on_body_entered(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		deactivate()
		SignalBus.player_revived.emit(global_position)
