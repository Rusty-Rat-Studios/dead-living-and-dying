class_name Room
extends Node3D

# The base class for all rooms. Stores information about the room, 
# the position on the world grid, and the possessables in the room.
# On init the room moves to its specified grid location and runs init_doors()

signal player_discovered_room

enum RoomType { BASIC, ITEM, SHRINE }

const ICON_MINIMAP: Resource = preload("res://src/ui/minimap/icon_minimap.tscn")
# used to delay making the room invisible after player dies
# needed because visibility is only triggered by doors
const RESPAWN_TIME: float = 2.0

@export var spawn_room: bool = false
@export var room_information: RoomInformation

var grid_location: Vector2
var possessables_available: Array
var doors: HashMap = HashMap.new()
var room_discovered: bool = false

@onready var player_in_room: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Floor/PlayerDetector.body_entered.connect(_on_player_entered_room)
	$Floor/PlayerDetector.body_exited.connect(_on_player_exited_room)
	player_discovered_room.connect(_on_player_discovered_room)
	SignalBus.key_item_dropped.connect(_on_key_item_dropped)
	visible = false


func init() -> void:
	var grid_scale: float = WorldGrid.GRID_SCALE
	var room_location: Vector3 = Vector3(grid_location.x * grid_scale, 0, 
		grid_location.y * grid_scale)
	global_position = room_location
	init_doors()
	print(Time.get_time_string_from_system(), ": Room ", grid_location , " initialized")


func reset() -> void:
	room_discovered = false
	if spawn_room:
		player_discovered_room.emit()


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


func register_door(door: Door) -> void:
	doors.add(door.door_location, door)


func deregister_door(door: Door) -> void:
	var success: bool = doors.remove(door.door_location)
	if not success:
		push_error("ERROR: Room.deregister_door failed")


func get_door_at_location(grid_door_location: DoorLocation) -> Door:
	var door_location: DoorLocation = grid_door_location.translate(-grid_location)
	return doors.retrieve(door_location)


func init_doors() -> void:
	for door: Door in doors.values():
		door.init(grid_location)


func get_room_polygon() -> PackedVector2Array:
	return $Floor/PlayerDetector/CollisionPolygon3D.polygon


func _on_player_entered_room(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		player_in_room = true
		visible = true
		SignalBus.player_entered_room.emit(self)
		if not room_discovered:
			player_discovered_room.emit()


func _on_player_exited_room(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		player_in_room = false
		SignalBus.player_exited_room.emit(self)
	
	# ensure room is invisible only if a player exits it and it has no open doors
	var a_door_is_open: bool = false
	for door: Door in doors.values():
		if door.door_open:
			a_door_is_open = true
			break
	visible = a_door_is_open


func _on_player_discovered_room() -> void:
	room_discovered = true
	
	var minimap_component: Node3D = room_information.minimap_component.instantiate()
	$/root/Game/MinimapObjects.add_child(minimap_component)
	minimap_component.global_position = global_position
	
	if room_information.room_icon != null:
		var room_icon: Node3D = ICON_MINIMAP.instantiate()
		$/root/Game/MinimapObjects.add_child(room_icon)
		room_icon.global_position = global_position
		room_icon.get_child(0).texture = room_information.room_icon


func _on_key_item_dropped() -> void:
	if player_in_room:
		var key_item: KeyItemWorld = KeyItemHandler.get_key_item()
		# add key item as child of the player's current room
		key_item.reparent(self)
		key_item.visible = true
		
		# update key item position to be directly matching the player position
		key_item.global_position = PlayerHandler.get_player().global_position
		key_item.global_position.y = 1
		
		# update key item movement path with world-grid find_shortest_path algorithm
		key_item.movement_path = get_parent().find_shortest_path(self, key_item.starting_room)
