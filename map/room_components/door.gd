class_name Door
extends Node3D

signal player_received(player: Player)

const WALL: Resource = preload("res://map/room_components/wall.tscn")

@export var door_location: DoorLocation

var linked_door: Door = null

@onready var world_grid: WorldGrid = get_node("/root/Game/WorldGrid")


func _ready() -> void:
	$Spawn.visible = false # Make debug mesh invisible
	$Area3D.body_entered.connect(_on_body_entered)
	player_received.connect(_on_player_received)
	(get_parent() as Room).register_door(self)


func init(room_grid_location: Vector2) -> void:
	var linked_door_location: DoorLocation = door_location.translate(room_grid_location).invert()
	var linked_room: Room = world_grid.get_room_at_location(linked_door_location.location)
	if linked_room == null:
		_convert_to_wall()
		return
	linked_door = linked_room.get_door_at_location(linked_door_location)
	if linked_door == null:
		_convert_to_wall()


func _convert_to_wall() -> void:
	(get_parent() as Room).deregister_door(self)
	var wall: Node3D = WALL.instantiate()
	wall.position = self.position
	wall.rotation = self.rotation
	add_sibling(wall)
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		if linked_door == null:
			return push_error("ERROR: Door.linked_door is null")
		print(Time.get_time_string_from_system(), ": ", body.name, " entered door ", self.door_location.string())
		linked_door.player_received.emit(body as Player)


func _on_player_received(player: Player) -> void:
	player.position.x = $Spawn.global_position.x
	player.position.z = $Spawn.global_position.z
