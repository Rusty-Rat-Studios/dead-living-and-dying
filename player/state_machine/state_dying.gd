extends PlayerState

const DYING_SPEED: float = 4.0

func enter() -> void:
	_parent.speed = DYING_SPEED
	
	
	# DEBUG: modulate color according to state
	_parent.get_node("RotationOffset/AnimatedSprite3D").modulate = Color(1, 0.5, 0.5)
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	SignalBus.player_state_changed.emit("Dying")
	
	# adjust light strength
	_parent.light_omni.omni_range = 4
	_parent.light_omni.light_energy = 0.4
	_parent.light_spot.spot_range = 6
	_parent.light_spot.light_energy = 0.4


func exit() -> void:
	SignalBus.player_hurt.disconnect(_on_player_hurt)


func _on_player_hurt() -> void:
	# activate i-frames without flash
	_parent.take_damage(false)
	_state_machine.change_state(States.DEAD)
