extends Area3D

# used to set cooldown timer
const HIT_COOLDOWN: float = 2.0
# used to flash player sprite while hit cooldown active
const HIT_FLASH_SPEED: float = 0.3
const FLASH_OPACITY: float = 0.2

# flag for tracking whether player can take damage or not
@onready var hit_cooldown_active: bool = false
# used to toggle opacity while hit cooldown active
@onready var hit_flash: bool = false
# used by state machine when updating states
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var sprite: AnimatedSprite3D = get_parent().get_node("RotationOffset/AnimatedSprite3D")

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
func activate_hit_cooldown(flash: bool = true) -> void:
	if hit_cooldown_active:
		return
	hit_cooldown_active = true
	$HitCooldown.start()
	if flash:
		hit_flash = true
		$HitFlash.start()


func _on_enemy_area_entered(area: Area3D) -> void:
	if not hit_cooldown_active:
		# pass signal for state-specific behavior
		var entity: Node3D = area.get_parent()
		if entity is Ghost:
			SignalBus.player_hurt.emit(entity)
		else:
			SignalBus.player_hurt.emit(null)


func _on_enemy_area_exited(area: Area3D) -> void:
	var entity: Node3D = area.get_parent()
	if entity is Ghost:
		SignalBus.player_escaped.emit(entity)
	else:
		SignalBus.player_escaped.emit(null)


func _on_hit_cooldown_timeout() -> void:
	# deactivate invincibility frames
	hit_cooldown_active = false
	# stop flashing animation
	$HitFlash.stop()
	if has_overlapping_areas():
		# pass signal for state-specific behavior
		SignalBus.player_hurt.emit()


func _on_hit_flash_timeout() -> void:
	var current_color: Color = sprite.get_modulate()
	if hit_flash:
		sprite.modulate = Color(current_color, FLASH_OPACITY)
	else:
		sprite.modulate = Color(current_color, 1)
	hit_flash = not hit_flash
