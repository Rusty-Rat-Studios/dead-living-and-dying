class_name Door
extends Node3D

signal player_received(player: Player)

const WALL: Resource = preload("res://map/room_components/wall.tscn")
const DOOR_TEXTURE: Texture = preload("res://map/tileset-dhassa/door1.png")
const DOOR_TEXTURE_OPEN: Texture = preload("res://map/tileset-dhassa/door1_open.png")

@export var door_location: DoorLocation

var linked_door: Door = null
var linked_room: Room = null
var door_open: bool = false

@onready var world_grid: WorldGrid = get_node("/root/Game/WorldGrid")
@onready var door_material: Material = $StaticBody3D/MeshInstance3D.mesh.material.duplicate()


func _ready() -> void:
	$StaticBody3D/MeshInstance3D.mesh = $StaticBody3D/MeshInstance3D.mesh.duplicate()
	$StaticBody3D/MeshInstance3D.mesh.material = door_material
	
	$Spawn.visible = false # Make debug mesh invisible
	$PlayerDetector.body_entered.connect(_on_body_entered)
	$PlayerDetector.body_exited.connect(_on_body_exited)
	#player_received.connect(_on_player_received)
	(get_parent() as Room).register_door(self)
	
	$Interactable.inputs = ["interact"]
	$Interactable.hide_message()
	$Interactable.input_detected.connect(_on_interaction)


func init(room_grid_location: Vector2) -> void:
	var linked_door_location: DoorLocation = door_location.translate(room_grid_location).invert()
	linked_room = world_grid.get_room_at_location(linked_door_location.location)
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


func open_door() -> void:
	door_open = true
	door_material.albedo_texture = DOOR_TEXTURE_OPEN
	linked_door.door_material.albedo_texture = DOOR_TEXTURE_OPEN
	linked_room.visible = true


func close_door() -> void:
	door_open = false
	door_material.albedo_texture = DOOR_TEXTURE
	linked_door.door_material.albedo_texture = DOOR_TEXTURE
	
	if not get_parent().player_in_room:
		get_parent().visible = false
	elif not linked_room.player_in_room:
		linked_room.visible = false


func _on_body_entered(body: Node3D) -> void:
	# TODO: if check may not be necessary
	if body is Player and PlayerHandler.get_player_state() != PlayerStateMachine.States.DEAD:
		if linked_door == null:
			return push_error("ERROR: Door.linked_door is null")
		print(Time.get_time_string_from_system(), ": ", body.name, " entered door ", self.door_location.string())
		#linked_door.player_received.emit(body as Player)
		
		$Interactable.display_message("[E] Open Door")
		$Interactable.enabled = true


func _on_body_exited(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	$Interactable.hide_message()
	$Interactable.enabled = false
	close_door()


func _on_interaction(input_name: String) -> void:
	if input_name == "interact":
		if door_open:
			close_door()
			$Interactable.display_message("[E] Open Door")
		else:
			open_door()
			$Interactable.display_message("[E] Close Door")


func _on_player_received(player: Player) -> void:
	player.position.x = $Spawn.global_position.x
	player.position.z = $Spawn.global_position.z
