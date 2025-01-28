extends PlayerState

const DYING_SPEED: float = 4.0
const LIGHT_REDUCTION : float = 0.7

func enter() -> void:
	super()
	_parent.speed = DYING_SPEED
	
	# DEBUG: modulate color according to state
	_parent.get_node("RotationOffset/AnimatedSprite3D").modulate = Color(1, 0.5, 0.5)
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	
	# reduce light strength
	_parent.light_omni.omni_range *= LIGHT_REDUCTION
	_parent.light_omni.light_energy *= LIGHT_REDUCTION
	_parent.light_spot.spot_range *= LIGHT_REDUCTION
	_parent.light_spot.light_energy *= LIGHT_REDUCTION


func exit() -> void:
	SignalBus.player_hurt.disconnect(_on_player_hurt)


func _on_player_hurt() -> void:
	# activate i-frames without flash
	_parent.take_damage(false)
	_state_machine.change_state(States.DEAD)
