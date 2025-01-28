extends StateMachine

enum States {WAITING, POSSESSING, STUNNED, ATTACKING}


func _ready() -> void:
	_starting_state = States.WAITING


func get_state_node(state: int) -> State:
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
