extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PlayerDetector.body_entered.connect(_on_player_entered_room)
	$PlayerDetector.body_exited.connect(_on_player_exited_room)


func _on_player_entered_room(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		SignalBus.emit_signal("player_entered_room", self)


func _on_player_exited_room(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		SignalBus.emit_signal("player_exited_room", self)
