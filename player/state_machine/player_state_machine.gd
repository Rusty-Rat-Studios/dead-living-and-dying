class_name StateMachine
extends Node

@export var starting_state: State
var current_state: State


func init(parent: Node3D) -> void:
	# give each child (state) a reference to parent it belongs to
	# and enter default starting_state
	for child: Node in get_children():
		child.parent = parent
	
	change_state(starting_state)


# allow each state to execute any exit logic before changing state
func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()


func process_physics(delta: float) -> void:
	var new_state: State = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)


func process_input(event: InputEvent) -> void:
	var new_state: State = current_state.process_input(event)
	if new_state:
		change_state(new_state)


func process_frame(delta: float) -> void:
	var new_state: State = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)
