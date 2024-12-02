class_name Room
extends Node3D

var possessables_available: Array

@onready var player_in_room: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Floor/PlayerDetector.body_entered.connect(_on_player_entered_room)
	$Floor/PlayerDetector.body_exited.connect(_on_player_exited_room)


func add_possessable(possessable: Possessable) -> void:
	possessables_available.append(possessable)


func remove_possessable(possessable: Possessable) -> void:
	var index: int = possessables_available.find(possessable)
	if index != -1:
		# possessable was found in array
		possessables_available.remove_at(index)
	else:
		print(Time.get_time_string_from_system(), 
		": WARNING: Attempted to remove a possessable that is not in ", name, "'s array")


func _on_player_entered_room(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		player_in_room = true
		SignalBus.emit_signal("player_entered_room", self)


func _on_player_exited_room(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		player_in_room = false
		SignalBus.emit_signal("player_exited_room", self)
