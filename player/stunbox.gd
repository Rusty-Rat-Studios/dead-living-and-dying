extends Area3D

# magnitude of stat reduction on stun
const SPEED_MODIFIER: float = -0.5
const LIGHT_RANGE_MODIFIER: float = -2
const LIGHT_ENERGY_MODIFIER: float = -0.5
const STUN_DURATION: float = 3.0
const RESTORE_DURATION: float = 2.0
const NAME: String = "stun"

# store tween as variable to allow cancelling it if stunned during restore
var _restore_tween: Tween

# accessed by state_dying.gd to enable/disable stunbox detection
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var _player: Player = get_parent()


func _ready() -> void:
	$StunTimer.wait_time = STUN_DURATION
	
	area_entered.connect(_on_enemy_area_entered)
	$StunTimer.timeout.connect(_on_stun_timer_timeout)


func stun() -> void:
	# stop restore tween if in progress
	if _restore_tween:
		_restore_tween.kill()
	
	# add negative stat modifiers to player
	_player.player_stats.stat_update_add(PlayerStats.Stats.SPEED, SPEED_MODIFIER, NAME)
	_player.player_stats.stat_update_add(PlayerStats.Stats.LIGHT_OMNI_RANGE, LIGHT_RANGE_MODIFIER, NAME)
	_player.player_stats.stat_update_add(PlayerStats.Stats.LIGHT_SPOT_RANGE, LIGHT_RANGE_MODIFIER, NAME)
	_player.player_stats.stat_update_add(PlayerStats.Stats.LIGHT_ENERGY, LIGHT_ENERGY_MODIFIER, NAME)
	
	$StunTimer.start()


func restore() -> void:
	# use a MethodTweener to reduce all stat modifiers from their
	# initial values to zero, removing the modifiers when finished
	_restore_tween = create_tween().set_ease(Tween.EASE_OUT)
	_restore_tween.finished.connect(_on_tween_finished)
	_restore_tween.tween_method(_restore_step, 1.0, 0.0, RESTORE_DURATION)


func _restore_step(value: float) -> void:
	# each stat is multiplied over time from 1 (full value) to 0 to create
	# a "reducing" effect over time
	_player.player_stats.stat_modifier_speed[NAME] = SPEED_MODIFIER * value
	_player.player_stats.stat_modifier_light_omni_range[NAME] = LIGHT_RANGE_MODIFIER * value
	_player.player_stats.stat_modifier_light_spot_range[NAME] = LIGHT_RANGE_MODIFIER * value
	_player.player_stats.stat_modifier_light_energy[NAME] = LIGHT_ENERGY_MODIFIER * value
	_player.player_stats.update_stats()


func restore_instantly() -> void:
	# called by state_dying.gd/exit() to immediately restore any values
	# before moving to the next state
	if _restore_tween:
		_restore_tween.kill()
	
	$StunTimer.stop()
	
	_remove_stun_modifiers()


func _remove_stun_modifiers() -> void:
	_player.player_stats.stat_update_remove(PlayerStats.Stats.SPEED, NAME)
	_player.player_stats.stat_update_remove(PlayerStats.Stats.LIGHT_OMNI_RANGE, NAME)
	_player.player_stats.stat_update_remove(PlayerStats.Stats.LIGHT_SPOT_RANGE, NAME)
	_player.player_stats.stat_update_remove(PlayerStats.Stats.LIGHT_ENERGY, NAME)


func _on_tween_finished() -> void:
	_remove_stun_modifiers()


func _on_enemy_area_entered(_body: Node3D) -> void:
	stun()


func _on_stun_timer_timeout() -> void:
	# check if player still in contact with ghosts
	if has_overlapping_bodies():
		stun()
	else:
		restore()
