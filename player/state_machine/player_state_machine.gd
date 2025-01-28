extends StateMachine

enum States { LIVING, DYING, DEAD }


func _ready() -> void:
	_starting_state = States.LIVING


func _input(event: InputEvent) -> void:
	# DEBUG: press tab to cycle state
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			match current_state:
				States.LIVING:
					change_state(States.DYING)
				States.DYING:
					change_state(States.DEAD)
				States.DEAD:
					change_state(States.LIVING)


func get_state_node(state: int) -> State:
	match state:
		States.LIVING:
			return $Living
		States.DYING:
			return $Dying
		States.DEAD:
			return $Dead
	
	push_error("Attempting to access invalid state: " + str(state))
	return null
