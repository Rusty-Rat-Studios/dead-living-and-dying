class_name Game
extends Node3D

# state machine node-based design partially sourced from:
# "Starter state machines in Godot 4" by "The Shaggy Dev"
# https://www.youtube.com/watch?v=oqFbZoA2lnU
@onready var state_machine: StateMachine = $StateMachine
@onready var player: Player = $Player
@onready var light_directional: DirectionalLight3D = $DirectionalLight3D
@onready var corpse: Area3D = preload("res://player/corpse.tscn").instantiate()
@onready var ghost_resource: Resource = preload("res://ghost/ghost.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize player
	# pass reference of state machine and corpse to be controlled by player
	player.init(state_machine, corpse)
	# add corpse to scene as sibling of player
	# corpse deactivates on initialization - invisible with no collision
	add_child(corpse)
	
	# Initialize state machine
	# pass reference of the player to the states
	state_machine.init($Player)
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
	ShrineManager.reset_shrines()
	Utility.call_for_each(find_children("*Item*", "Item"), "reset")
	# reset player
	player.reset()


func _on_player_state_changed(state: PlayerState.States) -> void:
	print(Time.get_time_string_from_system(), ": State entered: ", PlayerState.States.keys()[state])
	# enable or disable directional light according to player DEAD state
	match state:
		PlayerState.States.LIVING:
			light_directional.visible = false
		PlayerState.States.DEAD:
			light_directional.visible = true
