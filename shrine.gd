extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		SignalBus.emit_signal("player_entered_shrine")
