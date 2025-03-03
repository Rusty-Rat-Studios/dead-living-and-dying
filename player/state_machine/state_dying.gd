extends PlayerState

const SPEED_MODIFIER: float = -2.0

const LIGHT_OMNI_RANGE_MODIFIER: float = -1.5
const LIGHT_SPOT_RANGE_MODIFIER: float = -3


func enter() -> void:
	super()
	# update player stats
	_parent.current_stats.speed += SPEED_MODIFIER
	_parent.current_stats.light_omni_range += LIGHT_OMNI_RANGE_MODIFIER
	_parent.current_stats.light_spot_range += LIGHT_SPOT_RANGE_MODIFIER
	# apply inventory buffs to modified stats
	_parent.inventory_update()
	

func exit() -> void:
	SignalBus.player_hurt.disconnect(_on_player_hurt)
	
	_parent.stunbox.collision_shape.set_deferred("disabled", true)
	# invalidate any stun effects
	_parent.stunbox.restore_instantly()


func _on_player_hurt() -> void:
	# activate i-frames without flash
	_parent.take_damage(false)
	_state_machine.change_state(PlayerStateMachine.States.DEAD)
