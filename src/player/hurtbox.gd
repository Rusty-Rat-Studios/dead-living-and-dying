extends Area3D

# used to set cooldown timer
const HIT_COOLDOWN: float = 2.0
# used to flash player sprite while hit cooldown active
const HIT_FLASH_SPEED: float = 0.3
const OPACITY_FLASH: float = 0.2

# flag for tracking whether player can take damage or not
@onready var hit_cooldown_active: bool = false
# used to toggle opacity while hit cooldown active
@onready var hit_flash: bool = false
# used by state machine when updating states
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var sprite_torso: AnimatedSprite3D = get_parent().get_node("RotationOffset/AnimatedSpriteTorso")
@onready var sprite_legs: AnimatedSprite3D = get_parent().get_node("RotationOffset/AnimatedSpriteLegs")

@onready var hurt_sfx: AudioStreamPlayer3D = get_parent().get_node("Sounds/Hurt")


func _ready() -> void:
	$HitCooldown.wait_time = HIT_COOLDOWN
	$HitFlash.wait_time = HIT_FLASH_SPEED
	
	$HitCooldown.timeout.connect(_on_hit_cooldown_timeout)
	$HitFlash.timeout.connect(_on_hit_flash_timeout)
	area_entered.connect(_on_enemy_area_entered)
	area_exited.connect(_on_enemy_area_exited)


func reset() -> void:
	hit_cooldown_active = false
	hit_flash = false
	$HitCooldown.stop()
	$HitFlash.stop()


# utility function for activating i-frames, can be called separately
# from hit signal
# e.g. for respawning, to ensure player can't immediately take damage
# optional "flash" argument to disable the flashing animation
func activate_hit_cooldown(flash: bool = true, duration: float = HIT_COOLDOWN) -> void:
	if hit_cooldown_active:
		return
	hit_cooldown_active = true
	$HitCooldown.wait_time = duration
	$HitCooldown.start()
	if flash:
		hit_flash = true
		$HitFlash.start()
		
		AudioManager.play_modulated(hurt_sfx)


func _on_enemy_area_entered(area: Area3D) -> void:
	if not hit_cooldown_active:
		# pass signal for state-specific behavior
		SignalBus.player_hurt.emit(area.get_parent_node_3d())


func _on_enemy_area_exited(area: Area3D) -> void:
	SignalBus.player_escaped.emit(area.get_parent_node_3d())


func _on_hit_cooldown_timeout() -> void:
	# deactivate invincibility frames
	hit_cooldown_active = false
	# stop flashing animation
	$HitFlash.stop()
	if PlayerHandler.get_player_state() != PlayerStateMachine.States.DEAD:
		sprite_torso.modulate.a = 1
		sprite_legs.modulate.a = 1
	else:
		sprite_torso.modulate.a = get_parent().OPACITY_DEAD
		sprite_legs.modulate.a = get_parent().OPACITY_DEAD
	if has_overlapping_areas():
		# pass signal for state-specific behavior
		SignalBus.player_hurt.emit(get_overlapping_bodies()[0])


func _on_hit_flash_timeout() -> void:
	var current_color: Color = sprite_torso.get_modulate()
	if hit_flash:
		sprite_torso.modulate = Color(current_color, OPACITY_FLASH)
		sprite_legs.modulate = Color(current_color, OPACITY_FLASH)
	else:
		sprite_torso.modulate = Color(current_color, 1)
		sprite_legs.modulate = Color(current_color, 1)
	hit_flash = not hit_flash
