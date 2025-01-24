extends Node

enum States {WAITING, POSSESSING, STUNNED, ATTACKING}
@export var starting_state: Node
var current_state: Node
var parent: Ghost

@onready var state_waiting: Node = $Waiting
@onready var state_possessing: Node = $Possessing
@onready var state_stunned: Node = $Stunned
@onready var state_attacking: Node = $Attacking

func init(_parent: Node3D) -> void:
	# give each child (state) a reference to parent it belongs to
	# and enter default starting_state
	for child: Node in get_children():
		child.parent = _parent
		child.state_machine = self
	parent = _parent
	
	change_state(starting_state)
	
	# listen for player state change
	SignalBus.player_state_changed.connect(_on_player_state_changed)


# allow each state to execute any exit logic before changing state
func change_state(new_state: Node) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()


func change_state_enum(new_state: int) -> void:
	if current_state:
		current_state.exit()
	match new_state:
		States.WAITING:
			current_state = state_waiting
		States.POSSESSING:
			current_state = state_possessing
		States.STUNNED:
			current_state = state_stunned
		States.ATTACKING:
			current_state = state_attacking
	
	current_state.enter()


func process_physics(delta: float) -> void:
	# only perform actions for the current state
	current_state.process_physics(delta)


func _on_player_state_changed(state_name: String) -> void:
	match state_name:
		"Dead":
			if parent.player_in_room:
				change_state_enum(States.ATTACKING)
		"Living":
			change_state_enum(States.WAITING)
