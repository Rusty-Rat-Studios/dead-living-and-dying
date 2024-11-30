class_name Room
extends Node3D

var possessables_available: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Floor/PlayerDetector.body_entered.connect(_on_player_entered_room)
	$Floor/PlayerDetector.body_exited.connect(_on_player_exited_room)


func add_possessable(possessable: Possessable) -> void:
	possessables_available.append(possessable)


func remove_possessable(possessable: Possessable) -> void:
	possessables_available.remove_at(possessables_available.find(possessable))


func _on_player_entered_room(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		SignalBus.emit_signal("player_entered_room", self)


func _on_player_exited_room(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		SignalBus.emit_signal("player_exited_room", self)
