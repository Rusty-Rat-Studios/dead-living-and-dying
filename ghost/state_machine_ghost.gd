extends Node

enum States {WAITING, POSSESSING, STUNNED, ATTACKING}
var current_state: int
# track node for calling functions of child state nodes
var current_state_node: Node
var parent: Ghost

@onready var state_waiting: Node = $Waiting
@onready var state_possessing: Node = $Possessing
@onready var state_stunned: Node = $Stunned
@onready var state_attacking: Node = $Attacking
@onready var starting_state: int = States.WAITING

func init(parent: Node3D) -> void:
	for state: Node in get_children():
		state.init(parent, self)
	
	change_state(starting_state)
	self.parent = parent


func reset() -> void:
	change_state(starting_state)


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


func change_state(new_state: int) -> void:
	# allow each state to execute any exit logic before changing state
	if current_state_node:
		current_state_node.exit()
	
	current_state = new_state
	current_state_node = get_state_node(new_state)
	current_state_node.enter()


func process_physics(delta: float) -> void:
	# only perform actions for the current state
	current_state_node.process_physics(delta)
