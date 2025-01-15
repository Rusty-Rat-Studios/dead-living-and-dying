class_name Game
extends Node3D

# state machine node-based design partially sourced from:
# "Starter state machines in Godot 4" by "The Shaggy Dev"
# https://www.youtube.com/watch?v=oqFbZoA2lnU
@onready var state_machine: Node = $StateMachine
@onready var player: Player = $Player
@onready var light_directional: DirectionalLight3D = $DirectionalLight3D
@onready var corpse: Area3D = preload("res://player/corpse.tscn").instantiate()
@onready var ghost_resourse: Resource = preload("res://ghost/ghost.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize player
	# pass reference of state machine and corpse to be controlled by player
	player.init($StateMachine, corpse)
	# add corpse to scene as sibling of player
	# corpse deactivates on initialization - invisible with no collision
	add_child(corpse)
	
	# Initialize state machine
	# pass reference of the player to the states
	state_machine.init($Player)
	SignalBus.player_state_changed.connect(_on_player_state_changed)


func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)


func _physics_process(delta: float) -> void:
	# handle basic movement before passing to state-specific actions
	state_machine.process_physics(delta)


func _process(delta: float) -> void:
	state_machine.process_frame(delta)


func reset() -> void:
	# find_children(pattern: String, type: String = "") returns const Array
	# of all nodes in the entire scene with name matching pattern string
	# and type matching type string
		# Note: wildcard '*' used to select any node starting with "NodeName[xyz]"
		# e.g. Ghost* gets GhostLeft1, GhostLeft2, GhostRight1, etc
	
	# reset all ghosts, possessables, shrines, and items
	Utility.call_for_each(find_children("Ghost*", "Ghost"), "reset")
	Utility.call_for_each(find_children("Possessable*", "Possessable"), "reset")
	ShrineManager.reset_shrines()
	Utility.call_for_each(find_children("*Item*", "Item"), "reset")
	# reset player
	player.reset()


func _on_player_state_changed(state_name: String) -> void:
	print(Time.get_time_string_from_system(), ": State entered: ", state_name)
	match state_name:
		"Living":
			player.light_omni.visible = true
			player.light_spot.visible = true
			light_directional.visible = false
		"Dying":
			player.light_omni.visible = true
			player.light_spot.visible = true
			light_directional.visible = false
		"Dead":
			player.light_omni.visible = false
			player.light_spot.visible = false
			light_directional.visible = true
	
	# TEMPORARY
	update_ghost_visibility(state_name)


# TEMPORARY function to update ghost visibility based on player state
func update_ghost_visibility(state_name: String) -> void:
	# for some reason the ghost_mesh_instance is shared among all the ghosts so
	# changing it for this changes it for all
	var ghost: Ghost = ghost_resourse.instantiate()
	var ghost_mesh_instance: MeshInstance3D = ghost.get_node("MeshInstance3D")
	var ghost_mesh: CapsuleMesh = ghost_mesh_instance.mesh
	var material: Material = ghost_mesh.material
	
	var opacity: float
	match state_name:
		"Living":
			opacity = 0
		"Dying":
			opacity = 0.2
		"Dead":
			opacity = 0.8
	
	material.albedo_color.a = opacity
	ghost.queue_free() # delete temp Ghost
