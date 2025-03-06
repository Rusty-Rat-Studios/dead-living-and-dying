class_name StateMachine
extends Node
"""
State machines have several child states, each with a reference to the
state machine and the parent node the state machine belongs to. The state
machine also tracks the node of the current state to execute function calls
for that state. Each state has an enter() and exit() function which are 
called when a state changes to allow for state-specific readying and cleanup. 
- e.g. enabling or disabling timers

The state machine operates frame-by-frame by having a single active state 
operating through calls from the parent _process_physics() function, which
calls the state machine's process_current_state() function, which in turn
calls the current state's process_state() function.
- This technically means ALL state actions happen during the physics step.

_parent.process_physics()
-> _state_machine.process_current_state()
-> -> current_state.process_state()
"""
# to be initialized with _ready() by inheritors or in the editor
@export var _starting_state: int

var current_state: int
# track node for calling functions of child state nodes
var _current_state_node: Node


func init(parent: Node3D) -> void:
	# initialize all child states with reference to parent and state machine
	for state: State in get_children():
		state.init(parent, self)
	
	change_state(_starting_state)


func reset() -> void:
	change_state(_starting_state)


# abstract function to return a reference to the node representing the current state
# when given an enum representing a state (e.g. States.LIVING for player)
func get_state_node(_state: int) -> State:
	push_error("Uninitialized state machine attempting to access child state node")
	return null


# called by state machine during parent process_physics() step to execute 
# frame-by-frame behavior according to currently active state 
# - e.g. ghost updating target
func process_current_state() -> void:
	_current_state_node.process_state()


func change_state(new_state: int) -> void:
	# allow each state to execute any exit logic before changing state
	if _current_state_node:
		_current_state_node.exit()
	
	current_state = new_state
	_current_state_node = get_state_node(new_state)
	_current_state_node.enter()
