extends Node

enum States {WAITING, POSSESSING, STUNNED, ATTACKING}
var current_state: Node
var parent: Ghost

@onready var state_waiting: Node = $Waiting
@onready var state_possessing: Node = $Possessing
@onready var state_stunned: Node = $Stunned
@onready var state_attacking: Node = $Attacking
@onready var starting_state: Node = state_waiting
@onready var starting_state_enum: int = States.WAITING

func init(parent: Node3D) -> void:
	for state: Node in get_children():
		state.init(parent, self)
	
	change_state_enum(starting_state_enum)
	self.parent = parent


func reset() -> void:
	change_state_enum(starting_state_enum)


func get_state_node(state: int) -> Node:
	match state:
		States.WAITING:
			return state_waiting
		States.POSSESSING:
			return state_possessing
		States.STUNNED:
			return state_stunned
		States.ATTACKING:
			return state_attacking
	
	push_error("Attempting to access invalid state: " + str(state))
	return null


# allow each state to execute any exit logic before changing state
func change_state(new_state: Node) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()


func change_state_enum(new_state: int) -> void:
	if current_state:
		current_state.exit()
	
	current_state = get_state_node(new_state)
	current_state.enter()


func process_physics(delta: float) -> void:
	# only perform actions for the current state
	current_state.process_physics(delta)
