extends Area3D

# magnitude of stat reduction on stun
const SPEED_MODIFIER: float = -0.5
const LIGHT_RANGE_MODIFIER: float = -2
const LIGHT_ENERGY_MODIFIER: float = -0.5
const STUN_DURATION: float = 3.0
const RESTORE_DURATION: float = 2.0

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
	_player.stat_update_add(_player.current_stats.stat_modifier_speed, SPEED_MODIFIER, "stun")
	_player.stat_update_add(_player.current_stats.stat_modifier_light_omni_range, LIGHT_RANGE_MODIFIER, "stun")
	_player.stat_update_add(_player.current_stats.stat_modifier_light_spot_range, LIGHT_RANGE_MODIFIER, "stun")
	_player.stat_update_add(_player.current_stats.stat_modifier_light_energy, LIGHT_ENERGY_MODIFIER, "stun")
	
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
	_player.current_stats.stat_modifier_speed["stun"] = SPEED_MODIFIER * value
	_player.current_stats.stat_modifier_light_omni_range["stun"] = LIGHT_RANGE_MODIFIER * value
	_player.current_stats.stat_modifier_light_spot_range["stun"] = LIGHT_RANGE_MODIFIER * value
	_player.current_stats.stat_modifier_light_energy["stun"] = LIGHT_ENERGY_MODIFIER * value
	_player.stat_update()


func restore_instantly() -> void:
	# called by state_dying.gd/exit() to immediately restore any values
	# before moving to the next state
	if _restore_tween:
		_restore_tween.kill()
	
	$StunTimer.stop()
	
	remove_stun_modifiers()


func remove_stun_modifiers() -> void:
	_player.stat_update_remove(_player.current_stats.stat_modifier_speed, "stun")
	_player.stat_update_remove(_player.current_stats.stat_modifier_light_omni_range, "stun")
	_player.stat_update_remove(_player.current_stats.stat_modifier_light_spot_range, "stun")
	_player.stat_update_remove(_player.current_stats.stat_modifier_light_energy, "stun")


func _on_tween_finished() -> void:
	remove_stun_modifiers()


func _on_enemy_area_entered(_body: Node3D) -> void:
	stun()


func _on_stun_timer_timeout() -> void:
	# check if player still in contact with ghosts
	if has_overlapping_bodies():
		stun()
	else:
		restore()
