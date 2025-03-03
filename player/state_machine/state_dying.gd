extends PlayerState

const SPEED_MODIFIER: float = -2.0

const LIGHT_OMNI_RANGE_MODIFIER: float = -1.5
const LIGHT_SPOT_RANGE_MODIFIER: float = -3


func enter() -> void:
	super()
	# update player stats
	_parent.stat_update_add(_parent.current_stats.stat_modifier_speed, SPEED_MODIFIER, "dying")
	_parent.stat_update_add(_parent.current_stats.stat_modifier_light_omni_range, LIGHT_OMNI_RANGE_MODIFIER, "dying")
	_parent.stat_update_add(_parent.current_stats.stat_modifier_light_spot_range, LIGHT_SPOT_RANGE_MODIFIER, "dying")
	_parent.stat_update()
	
	# DEBUG: modulate color according to state
	_parent.get_node("RotationOffset/AnimatedSprite3D").modulate = Color(1, 0.5, 0.5)
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	
	# enable and configure stunbox values
	_parent.stunbox.collision_shape.set_deferred("disabled", false)
	_parent.stunbox.set_values(_parent.current_stats.speed, _parent.current_stats.light_omni_range,
		_parent.current_stats.light_spot_range, _parent.current_stats.light_energy)
	

func exit() -> void:
	SignalBus.player_hurt.disconnect(_on_player_hurt)
	
	_parent.stunbox.collision_shape.set_deferred("disabled", true)
	# invalidate any stun effects
	_parent.stunbox.restore_instantly()


func _on_player_hurt() -> void:
	# activate i-frames without flash
	_parent.take_damage(false)
	_state_machine.change_state(PlayerStateMachine.States.DEAD)
