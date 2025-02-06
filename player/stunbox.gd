extends Area3D

const SPEED_MODIFIER: float = 0.8
const LIGHT_MODIFIER: float = 0.7
const STUN_DURATION: float = 3.0
const RESTORE_DURATION: float = 2.0

# store pre-stun player attributes
var base_speed: float
var base_light_omni_range: float
var base_light_spot_range: float
var base_light_energy: float
# store tween as variable to allow cancelling it if stunned during restore
var _restore_tween: Tween

# accessed by state_dying.gd to enable/disable stunbox detection
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var _player: Player = PlayerHandler.get_player()


func _ready() -> void:
	$StunTimer.wait_time = STUN_DURATION
	
	area_entered.connect(_on_enemy_area_entered)
	$StunTimer.timeout.connect(_on_stun_timer_timeout)


func set_values(speed: float, omni_range: float, spot_range: float, light_energy: float) -> void:
	# update all "base" player states to return to on restore()
	# called by state_dying.gd/init()
	base_speed = speed
	base_light_omni_range = omni_range
	base_light_spot_range = spot_range
	base_light_energy = light_energy


func stun() -> void:
	# stop restore tween if in progress
	if _restore_tween:
		_restore_tween.kill()
	
	# reduce player attributes
	_player.stat_dict[Player.Stats.SPEED] = base_speed * SPEED_MODIFIER
	_player.light_omni.omni_range = base_light_omni_range * LIGHT_MODIFIER
	_player.light_omni.light_energy = base_light_energy * LIGHT_MODIFIER
	_player.light_spot.spot_range = base_light_spot_range * LIGHT_MODIFIER
	_player.light_spot.light_energy = base_light_energy * LIGHT_MODIFIER
	
	$StunTimer.start()


func restore() -> void:
	# use set_parallel to have all properties tween simultaneously
	_restore_tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT)
	_restore_tween.tween_property(_player, "stat_dict:Player.Stats.SPEED", base_speed, RESTORE_DURATION)
	_restore_tween.tween_property(_player.light_omni, "omni_range", base_light_omni_range, RESTORE_DURATION)
	_restore_tween.tween_property(_player.light_omni, "light_energy", base_light_energy, RESTORE_DURATION)
	_restore_tween.tween_property(_player.light_spot, "spot_range", base_light_spot_range, RESTORE_DURATION)
	_restore_tween.tween_property(_player.light_spot, "light_energy", base_light_energy, RESTORE_DURATION)


func restore_instantly() -> void:
	# called by state_dying.gd/exit() to immediately restore any values
	# before moving to the next state
	$StunTimer.stop()
	if _restore_tween:
		_restore_tween.kill()
	_player.stat_dict[Player.Stats.SPEED] = base_speed
	_player.light_omni.omni_range = base_light_omni_range
	_player.light_omni.light_energy = base_light_energy 
	_player.light_spot.spot_range = base_light_spot_range
	_player.light_spot.light_energy = base_light_energy
	
	$StunTimer.stop()


func _on_enemy_area_entered(_body: Node3D) -> void:
	stun()


func _on_stun_timer_timeout() -> void:
	# check if player still in contact with ghosts
	if has_overlapping_bodies():
		stun()
	else:
		restore()
