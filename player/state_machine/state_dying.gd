extends PlayerState

const DYING_SPEED: float = 4.0

const DYING_LIGHT_OMNI_RANGE: float = 4.5
const DYING_LIGHT_SPOT_RANGE: float = 7
const DYING_LIGHT_ENERGY: float = 1

@onready var screen_effect: TextureRect = get_node("/root/Game/UI/DyingScreenEffect")


func enter() -> void:
	super()
	# update player stats
	_parent.stat_dict[Player.Stats.SPEED] = DYING_SPEED
	_parent.light_omni.omni_range = DYING_LIGHT_OMNI_RANGE
	_parent.light_omni.light_energy = DYING_LIGHT_ENERGY
	_parent.light_spot.spot_range = DYING_LIGHT_SPOT_RANGE
	_parent.light_spot.light_energy = DYING_LIGHT_ENERGY
	# apply inventory buffs to modified stats
	_parent.inventory_update()
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	
	# enable and configure stunbox values
	_parent.stunbox.collision_shape.set_deferred("disabled", false)
	_parent.stunbox.set_values(_parent.stat_dict[Player.Stats.SPEED], DYING_LIGHT_OMNI_RANGE,
		DYING_LIGHT_SPOT_RANGE, DYING_LIGHT_ENERGY)
	
	# stun the player when they are hit
	_parent.stunbox.stun()
	# enable "dying" screen effect
	screen_effect.enable()


func exit() -> void:
	SignalBus.player_hurt.disconnect(_on_player_hurt)
	
	_parent.stunbox.collision_shape.set_deferred("disabled", true)
	# invalidate any stun effects
	_parent.stunbox.restore_instantly()
	
	screen_effect.disable()


func _on_player_hurt() -> void:
	# activate i-frames without flash
	_parent.take_damage(false)
	_state_machine.change_state(PlayerStateMachine.States.DEAD)
