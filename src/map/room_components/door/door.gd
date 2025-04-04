class_name Door
extends Node3D

const DOOR_TEXTURE: Texture = preload("res://src/map/tileset-dhassa/door1.png")
const DOOR_TEXTURE_OPEN: Texture = preload("res://src/map/tileset-dhassa/door1_open.png")
# energy of fire light; used to tween in/out
const LIGHT_ENERGY: float = 2.0
const TWEEN_DURATION: float = 0.6
const MINIMAP_COMPONENT: Resource = preload("res://src/map/room_components/door/door_minimap.tscn")

const SFX_OPEN: AudioStream = preload("res://src/sound/sfx/door_open.mp3")
const SFX_CLOSE: AudioStream = preload("res://src/sound/sfx/door_close.mp3")
const SFX_LOCKED: AudioStream = preload("res://src/sound/sfx/door_locked.mp3")

@export var wall_with_doorway: Wall
@export var wall_scene: PackedScene
@export var door_location: DoorLocation

var linked_door: Door = null
var linked_room: Room = null
var door_open: bool = false
var door_locked: bool = false
# needed to handle asynchronous collision shape handling
# e.g. dying during ghost event
var player_dead: bool = false
# used to fade in fire light
var light_tween: Tween

@onready var world_grid: WorldGrid = get_node("/root/Game/WorldGrid")
@onready var door_material: Material = $StaticBody3D/MeshInstance3D.mesh.material.duplicate()
@onready var door_collision_shape: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var detector_collision_shape: CollisionShape3D = $PlayerDetector/CollisionShape3D
@onready var interactable: Interactable = $Interactable
@onready var door_sfx: AudioStreamPlayer3D = $AudioStreamPlayer3D


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
	interactable.hide()
	interactable.input_detected.connect(_on_interaction)
	
	deactivate_effects(true)


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
	var wall: Wall = wall_scene.instantiate()
	wall.position = self.position
	wall.rotation = self.rotation
	wall.monitor_for_transparency = wall_with_doorway.monitor_for_transparency
	add_sibling(wall)
	queue_free()


func open_door() -> void:
	door_open = true
	door_material.albedo_texture = DOOR_TEXTURE_OPEN
	
	door_collision_shape.set_deferred("disabled", true)
	
	door_sfx.stream = SFX_OPEN
	if not linked_door.door_sfx.playing:
		AudioManager.play_modulated(door_sfx)


func close_door() -> void:
	door_open = false
	door_material.albedo_texture = DOOR_TEXTURE
	
	if not get_parent().player_in_room and not door_open:
		get_parent().visible = false
	
	if not player_dead:
		door_collision_shape.set_deferred("disabled", false)
	
	door_sfx.stream = SFX_CLOSE
	if not linked_door.door_sfx.playing:
		AudioManager.play_modulated(door_sfx)


func lock() -> void:
	door_locked = true
	if door_open:
		close_door()
	interactable.hide()
	activate_effects()


func unlock() -> void:
	door_locked = false
	if $PlayerDetector.overlaps_body(PlayerHandler.get_player()):
		interactable.show()
		interactable.enabled = true
	deactivate_effects()


func activate_effects(instant: bool = false) -> void:
	$FireParticles.emitting = true
	if light_tween:
		light_tween.kill()
	if not instant:
		light_tween = create_tween()
		light_tween.tween_property($FireParticles/SpotLight3D, "light_energy", LIGHT_ENERGY, TWEEN_DURATION)
	else:
		$FireParticles/SpotLight3D.light_energy = LIGHT_ENERGY


func deactivate_effects(instant: bool = false) -> void:
	$FireParticles.emitting = false
	if light_tween:
		light_tween.kill()
	if not instant:
		light_tween = create_tween()
		light_tween.tween_property($FireParticles/SpotLight3D, "light_energy", 0, TWEEN_DURATION)
	else:
		$FireParticles/SpotLight3D.light_energy = 0


func _on_body_entered(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	if not door_open and not door_locked:
		interactable.show()
	
	# always allow interaction even if locked -> do not show prompt if locked
	interactable.enabled = true


func _on_body_exited(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	interactable.hide()
	interactable.enabled = false
	# ensure door does not close until player is outside both door player detector ranges
	if not linked_door.get_node("PlayerDetector").has_overlapping_bodies():
		if door_open:
			close_door()
		if linked_door.door_open:
			linked_door.close_door()


func _on_interaction(input_name: String) -> void:
	if input_name == "interact":
		if not (door_open or door_locked):
			open_door()
			linked_door.open_door()
			linked_room.visible = true
			if not linked_room.room_discovered:
				linked_room.player_discovered_room.emit()
			interactable.hide()
		else:
			if door_sfx.stream != SFX_LOCKED:
				door_sfx.stream = SFX_LOCKED
			if not door_sfx.playing:
				AudioManager.play_modulated(door_sfx)


func _on_player_state_changed(state: PlayerStateMachine.States) -> void:
	if state == PlayerStateMachine.States.LIVING:
		door_collision_shape.set_deferred("disabled", false)
		detector_collision_shape.set_deferred("disabled", false)
		player_dead = false
	elif state == PlayerStateMachine.States.DEAD:
		door_collision_shape.set_deferred("disabled", true)
		detector_collision_shape.set_deferred("disabled", true)
		player_dead = true


func _on_player_discovered_room() -> void:
	var minimap_component: Node3D = MINIMAP_COMPONENT.instantiate()
	$/root/Game/MinimapObjects.add_child(minimap_component)
	minimap_component.global_position = global_position
	minimap_component.global_rotation = global_rotation
