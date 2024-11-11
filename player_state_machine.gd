extends Node

@export var starting_state: State
var current_state: State

# DEBUG: modulate sprite color to reflect state
@onready var state_colors = {
	$Dead: Color(0.2, 0.2, 0.2, 0.5), # grey, transparent
	$Living: Color()
}

func init(parent: Player) -> void:
	# give each child (state) a reference to parent (player) it belongs to
	# and enter default starting_state
	for child in get_children():
		child.parent = parent
	
	starting_state = $Living
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
