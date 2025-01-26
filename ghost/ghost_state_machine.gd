extends Node
"""
This state machine has several child states, each with a reference to the
parent Ghost node the state machine belongs to. Each state has an enter() 
and exit() functions which are called when a state changes to allow for
state-specific readying and cleaup (e.g. enabling or disabling timers).

The state machine operates frame-by-frame by having a single active state 
operating through the process_state() function called by the parent (Ghost)
_process_physics() functions.
- This technically means ALL state actions happen during the physics step.
"""

enum States {WAITING, POSSESSING, STUNNED, ATTACKING}
var current_state: int
# track node for calling functions of child state nodes
var current_state_node: Node
var parent: Ghost

@onready var starting_state: int = States.WAITING

func init(parent: Node3D) -> void:
	# initialize all child states with reference to parent and state machine
	for state: Node in get_children():
		state.init(parent, self)
	
	change_state(starting_state)
	self.parent = parent


func reset() -> void:
	change_state(starting_state)


func get_state_node(state: int) -> Node:
	match state:
		States.WAITING:
			return $Waiting
		States.POSSESSING:
			return $Possessing
		States.STUNNED:
			return $Stunned
		States.ATTACKING:
			return $Attacking
	
	push_error("Attempting to access invalid state: " + str(state))
	return null


func change_state(new_state: int) -> void:
	# allow each state to execute any exit logic before changing state
	if current_state_node:
		current_state_node.exit()
	
	current_state = new_state
	current_state_node = get_state_node(new_state)
	current_state_node.enter()


func process_state() -> void:
	# only perform actions for the current state
	current_state_node.process_state()
