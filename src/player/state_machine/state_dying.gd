extends PlayerState

const SPEED_MODIFIER: float = -0.5
const ANIMATION_SPEED_SCALE: float = 1.8

const LIGHT_OMNI_RANGE_MODIFIER: float = -1.5
const LIGHT_SPOT_RANGE_MODIFIER: float = -3
const NAME: String = "dying"

@onready var screen_effect: TextureRect = get_node("/root/Game/UI/DyingScreenEffect")


func enter() -> void:
	super()
	
	_parent.sprite_torso.animation = "dying"
	_parent.sprite_legs.speed_scale = ANIMATION_SPEED_SCALE
	
	# update player stats
	_parent.player_stats.stat_update_add(PlayerStats.Stats.SPEED, SPEED_MODIFIER, NAME)
	_parent.player_stats.stat_update_add(PlayerStats.Stats.LIGHT_OMNI_RANGE, LIGHT_OMNI_RANGE_MODIFIER, NAME)
	_parent.player_stats.stat_update_add(PlayerStats.Stats.LIGHT_SPOT_RANGE, LIGHT_SPOT_RANGE_MODIFIER, NAME)
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	
	# enable and configure stunbox values
	_parent.stunbox.collision_shape.set_deferred("disabled", false)
	
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


func process_state() -> void:
	pass


func _on_player_hurt(_entity: Node3D) -> void:
	# activate i-frames without flash
	_parent.take_damage(false)
	_state_machine.change_state(PlayerStateMachine.States.DEAD)
