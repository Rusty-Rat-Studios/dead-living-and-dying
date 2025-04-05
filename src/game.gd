class_name Game
extends Node3D

@export var key_item_starting_position: Vector3
@export var old_man: OldMan

# state machine node-based design partially sourced from:
# "Starter state machines in Godot 4" by "The Shaggy Dev"
# https://www.youtube.com/watch?v=oqFbZoA2lnU
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var player: Player = $Player
@onready var light_directional: DirectionalLight3D = $DirectionalLight3D

@onready var world_grid: WorldGrid = $WorldGrid


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize player
	# pass reference of state machine to be controlled by player
	player.init(state_machine)
	
	# Initialize state machine
	# pass reference of the player to the states
	state_machine.init(player)
	SignalBus.player_state_changed.connect(_on_player_state_changed)


func reset() -> void:
	# find_children(pattern: String, type: String = "") returns const Array
	# of all nodes in the entire scene with name matching pattern string
	# and type matching type string
		# Note: wildcard '*' used to select any node starting with "NodeName[xyz]"
		# e.g. Ghost* gets GhostLeft1, GhostLeft2, GhostRight1, etc
	
	# reset all ghosts, possessables, shrines, and items
	Utility.call_for_each(find_children("Ghost*", "Ghost"), "reset")
	Utility.call_for_each(find_children("*", "Possessable"), "reset")
	ShrineManager.clear_shrines_list(true)
	Utility.call_for_each(find_children("*Item*", "Item"), "reset")
	
	SpawnerManager.reset()
	
	player.reset_state()
	if old_man:
		old_man.reset()
	
	# Clear the minimap
	for child: Node3D in $MinimapObjects.get_children():
		child.free()
	
	get_tree().call_group("rooms", "reset")
	
	world_grid.reset()
	
	key_item_starting_position = Vector3.ZERO
	
	world_grid.call_deferred("setup_grid")


func _on_player_state_changed(state: PlayerStateMachine.States) -> void:
	print(Time.get_time_string_from_system(), ": State entered: ", PlayerStateMachine.States.keys()[state])
	# enable or disable directional light according to player DEAD state
	match state:
		PlayerStateMachine.States.LIVING:
			light_directional.visible = false
		PlayerStateMachine.States.DEAD:
			light_directional.visible = true
