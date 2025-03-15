class_name Door
extends Node3D

const WALL: Resource = preload("res://map/room_components/wall.tscn")
const DOOR_TEXTURE: Texture = preload("res://map/tileset-dhassa/door1.png")
const DOOR_TEXTURE_OPEN: Texture = preload("res://map/tileset-dhassa/door1_open.png")
const MINIMAP_COMPONENT: Resource = preload("res://map/room_components/door_minimap.tscn")

@export var door_location: DoorLocation

var linked_door: Door = null
var linked_room: Room = null
var door_open: bool = false

@onready var world_grid: WorldGrid = get_node("/root/Game/WorldGrid")
@onready var door_material: Material = $StaticBody3D/MeshInstance3D.mesh.material.duplicate()
@onready var door_collision_shape: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var detector_collision_shape: CollisionShape3D = $PlayerDetector/CollisionShape3D
@onready var interactable: Interactable = $Interactable


func _ready() -> void:
	$StaticBody3D/MeshInstance3D.mesh = $StaticBody3D/MeshInstance3D.mesh.duplicate()
	$StaticBody3D/MeshInstance3D.mesh.material = door_material
	
	$PlayerDetector.body_entered.connect(_on_body_entered)
	$PlayerDetector.body_exited.connect(_on_body_exited)
	# disable door collision and interactable when player is spirit
	SignalBus.player_state_changed.connect(_on_player_state_changed)
	
	var parent_room: Room = get_parent()
	parent_room.player_discovered_room.connect(_on_player_discovered_room)
	parent_room.register_door(self)
	
	interactable.inputs = ["interact"]
	interactable.hide_message()
	interactable.input_detected.connect(_on_interaction)


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
	
	door_collision_shape.set_deferred("disabled", true)


func close_door() -> void:
	door_open = false
	door_material.albedo_texture = DOOR_TEXTURE
	linked_door.door_material.albedo_texture = DOOR_TEXTURE
	
	if not get_parent().player_in_room and not door_open:
		get_parent().visible = false
	
	door_collision_shape.set_deferred("disabled", false)


func _on_body_entered(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	if not door_open:
		interactable.display_message("[E] Open Door")
		interactable.enabled = true


func _on_body_exited(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	interactable.hide_message()
	interactable.enabled = false
	# ensure door does not close until player is outside both door player detector ranges
	if not linked_door.get_node("PlayerDetector").has_overlapping_bodies():
		close_door()
		linked_door.close_door()


func _on_interaction(input_name: String) -> void:
	if input_name == "interact":
		if not door_open:
			open_door()
			linked_door.open_door()
			linked_room.visible = true
			if not linked_room.room_discovered:
				linked_room.player_discovered_room.emit()
			interactable.enabled = false
			interactable.hide_message()


func _on_player_state_changed(state: PlayerStateMachine.States) -> void:
	if state == PlayerStateMachine.States.LIVING:
		door_collision_shape.set_deferred("disabled", false)
		detector_collision_shape.set_deferred("disabled", false)
	elif state == PlayerStateMachine.States.DEAD:
		door_collision_shape.set_deferred("disabled", true)
		detector_collision_shape.set_deferred("disabled", true)


func _on_player_discovered_room() -> void:
	var minimap_component: Node3D = MINIMAP_COMPONENT.instantiate()
	$/root/Game/MinimapObjects.add_child(minimap_component)
	minimap_component.global_position = global_position
	minimap_component.global_rotation = global_rotation
