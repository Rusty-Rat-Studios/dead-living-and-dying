class_name Player
extends CharacterBody3D

# used to set cooldown timer
const HIT_COOLDOWN: float = 2.0
# used to flash player sprite while hit cooldown active
const HIT_FLASH_SPEED: float = 0.3
const FLASH_OPACITY: float = 0.2

# player state machine, sibling node under Game node
var state_machine: Node
# used to track previously visited, non-consumed shrines (including default)
# default shrine should be element 0 and never be removed from this array
var active_shrines: Array
# used to track player corpse - handled by states
var corpse: Corpse

@onready var hit_cooldown_active: bool = false
# used to toggle opacity while hit cooldown active
@onready var hit_flash: bool = false
@onready var speed: float = 6.0
@onready var light_omni: OmniLight3D = $OmniLight3D
@onready var light_spot: SpotLight3D = $SpotLight3D
@onready var camera: Camera3D = $RotationOffset/Camera3D
@onready var sprite: Sprite3D = $RotationOffset/Sprite3D

# store initial position to return to when calling reset()
@onready var starting_position: Vector3 = position


func _ready() -> void:
	light_omni.light_color = Color("GOLDENROD")
	
	$HitCooldown.wait_time = HIT_COOLDOWN
	$HitFlash.wait_time = HIT_FLASH_SPEED
	
	$HitCooldown.timeout.connect(_on_hit_cooldown_timeout)
	$HitFlash.timeout.connect(_on_hit_flash_timeout)
	$DamageDetector.area_entered.connect(_on_enemy_area_entered)
	
	SignalBus.activated_shrine.connect(_on_activated_shrine)
	SignalBus.consumed_shrine.connect(_on_consumed_shrine)
	
	SignalBus.item_picked_up.connect(_on_item_picked_up)


func init(state_machine: Node, shrine: Shrine, corpse: Corpse) -> void:
	@warning_ignore("shadowed_variable")
	self.state_machine = state_machine
	# add default shrine to active shrines
	active_shrines.append(shrine)
	# set reference to player corpse
	@warning_ignore("shadowed_variable")
	self.corpse = corpse


func reset() -> void:
	# return to starting position and state
	position = starting_position
	hit_cooldown_active = false
	$HitCooldown.stop()
	$HitFlash.stop()
	
	# store reference to default shrine before clearing list
	var default_shrine: Shrine = active_shrines[0]
	active_shrines.clear()
	# restore default shrine as only element
	active_shrines.append(default_shrine)
	state_machine.change_state(state_machine.starting_state)
	
	camera.reset()
	corpse.reset()


func _physics_process(delta: float) -> void:
	handle_movement(delta) 


func handle_movement(delta: float) -> void:
	if not is_on_floor(): # Add the gravity.
		velocity += get_gravity() * delta
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: Vector3
	
	# check for analog input
	var input_dir: Vector2 = Focus.input_get_vector(
		"joy_left_x_left", "joy_left_x_right", "joy_left_y_up", "joy_left_y_down")
	if input_dir != Vector2.ZERO:
		# analog input
		direction = Vector3(input_dir.x, 0, input_dir.y)
	else: 
		# digital input
		input_dir = Focus.input_get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()


# utility function for activating i-frames, can be called separately
# from hit signal
# e.g. for respawning, to ensure player can't immediately take damage
# optional "flash" argument to disable the flashing animation
func take_damage(flash: bool = true) -> void:
	hit_cooldown_active = true
	# start hit cooldown
	$HitCooldown.start()
	if flash:
		hit_flash = true
		$HitFlash.start()


func _on_enemy_area_entered(_area: Area3D) -> void:
	if not hit_cooldown_active:
		# pass signal for state-specific behavior
		SignalBus.player_hurt.emit()
	# do nothing if cooldown active


func _on_hit_cooldown_timeout() -> void:
	# deactivate invincibility frames
	hit_cooldown_active = false
	# stop flashing animation
	$HitFlash.stop()
	if $DamageDetector.has_overlapping_areas():
		# pass signal for state-specific behavior
		SignalBus.player_hurt.emit()


func _on_hit_flash_timeout() -> void:
	var current_color: Color = sprite.get_modulate()
	if hit_flash:
		sprite.modulate = Color(current_color, FLASH_OPACITY)
	else:
		sprite.modulate = Color(current_color, 1)
	hit_flash = not hit_flash


func _on_activated_shrine(shrine: Shrine) -> void:
	active_shrines.append(shrine)


func _on_consumed_shrine(shrine: Shrine) -> void:
	active_shrines.remove_at(active_shrines.find(shrine))


func _on_item_picked_up(item: Item) -> void:
	# reparent node as a child to player inventory
	item.reparent($Inventory)
	# ensure item position is directly on player
	item.position = Vector3.ZERO
