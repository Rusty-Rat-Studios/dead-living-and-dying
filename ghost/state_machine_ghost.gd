extends Node

@export var states: Dictionary = {}
@export var starting_state: Node
var current_state: Node
var parent: Ghost


func init(_parent: Node3D) -> void:
	# initialize states dynamically according to state machine child nodes
	for state: Node in get_children():
		states[state.name] = state
	
	# give each child (state) a reference to parent it belongs to
	# and enter default starting_state
	for child: Node in get_children():
		child.parent = _parent
		child.state_machine = self

	change_state(starting_state)
	
	# listen for player state change
	SignalBus.player_state_changed.connect(_on_player_state_changed)


# allow each state to execute any exit logic before changing state
func change_state(new_state: Node) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	states[current_state.name].enter()


func process_physics(delta: float) -> void:
	# only perform actions for the current state
	current_state.process_physics(delta)


func _on_player_state_changed(state_name: String) -> void:
	match state_name:
		"Dead":
			if get_parent().player_in_room:
				change_state($Attacking)
		"Living":
			change_state($Waiting)
