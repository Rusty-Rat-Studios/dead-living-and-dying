class_name StateMachine
extends Node

enum States {LIVING, DYING, DEAD}
var current_state: int
# track node for calling functions of child state nodes
var _current_state_node: Node

@onready var _starting_state: int = States.LIVING

func init(parent: Node3D) -> void:
	# initialize all child states with reference to parent and state machine
	for state: Node in get_children():
		state.init(parent, self)
	
	change_state(_starting_state)


func reset() -> void:
	change_state(_starting_state)


func get_state_node(state: int) -> Node:
	match state:
		States.LIVING:
			return $Living
		States.DYING:
			return $Dying
		States.DEAD:
			return $Dead
	
	push_error("Attempting to access invalid state: " + str(state))
	return null


func change_state(new_state: int) -> void:
	# allow each state to execute any exit logic before changing state
	if _current_state_node:
		_current_state_node.exit()
	
	current_state = new_state
	_current_state_node = get_state_node(new_state)
	_current_state_node.enter()


#func process_input(event: InputEvent) -> void:
	#var new_state: PlayerState = _current_state_node.process_input(event)
	#if new_state:
		#change_state(new_state)
