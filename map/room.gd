class_name Room
extends Node3D

var room_information: RoomInformation
var grid_location: Vector2
var possessables_available: Array

@onready var world_grid: Node3D = get_node("/root/Game/WorldGrid")
@onready var player_in_room: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Floor/PlayerDetector.body_entered.connect(_on_player_entered_room)
	$Floor/PlayerDetector.body_exited.connect(_on_player_exited_room)


func init() -> void:
	var grid_scale: float = WorldGrid.GRID_SCALE
	var room_location: Vector3 = Vector3(grid_location.x * grid_scale, 0, 
		grid_location.y * grid_scale)
	global_translate(room_location)
	generate_walls_and_doors()


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


# Godot doesn't support abstract classes/methods so simulate by throwing an error
func generate_walls_and_doors() -> void:
	push_error("ABSTRACT METHOD ERROR: room_gd.generate_walls_and_doors()")


func _on_player_entered_room(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		player_in_room = true
		SignalBus.player_entered_room.emit(self)


func _on_player_exited_room(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		player_in_room = false
		SignalBus.player_exited_room.emit(self)
