class_name State
extends Node
"""
States each have a reference to the the state machine and parent node
they belong to. States are defined and accessed as enums by both their 
state machine and inheritors.

State-specific behavior is executed through the process_state() function
called by the state machine' process_current_state(), which is in turn 
called from the parent node's process_physics() function.

_parent.process_physics()
-> _state_machine.process_current_state()
-> -> current_state.process_state()
"""

var _parent: CharacterBody3D
var _state_machine: StateMachine

func init(parent: CharacterBody3D, state_machine: StateMachine) -> void:
	_parent = parent
	_state_machine = state_machine


# abstract function to execute state "initialization" behavior 
# when it becomes the current state
# - called during the state machine's change_state() function
func enter() -> void:
	push_error("Uninitialized state attempting to execute 'enter()' function")


# abstract function to execute state "cleanup" behavior when
# it stops being the current state
# - called during the state machine's change_state() function
func exit() -> void:
	push_error("Uninitialized state attempting to execute 'exit()' function")


# wrapper function to allow states to directly call the change_state() function
func change_state(new_state: int) -> void:
	_state_machine.change_state(new_state)


# abstract function to execute state-specific behavior. 
# Called by state machine process_current_state() function which
# is executed by the parent process_physics() function.
func process_state() -> void:
	push_error("Uninitialized state attempting to execute process")
