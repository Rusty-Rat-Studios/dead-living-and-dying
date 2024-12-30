class_name Player
extends CharacterBody3D

# used to set cooldown timer
const HIT_COOLDOWN: float = 2.0
# used to flash player sprite while hit cooldown active
const HIT_FLASH_SPEED: float = 0.3
const FLASH_OPACITY: float = 0.2

# for controlling player rotation in a momentum-like fashion
const MAX_ANGULAR_SPEED: float = 3.0
const ANGULAR_ACCELERATION: float = 10.0
const ANGULAR_DECELERATION: float = 40.0
# used to check if spotlight is rotated close enough to the target
const TARGET_THRESHOLD: float = 0.01
# used to begin decelerating rotation when close but not at target
const DECELERATION_THRESHOLD: float = 5 * TARGET_THRESHOLD

# player state machine, sibling node under Game node
var state_machine: Node
# used to track previously visited, non-consumed shrines (including default)
# default shrine should be element 0 and never be removed from this array
var active_shrines: Array
# used to track player corpse - handled by states
var corpse: Corpse

# used to continue processing controller input when the stick is held 
# in the same direction - Godot's built-in InputEvent only detects changes
# --- without this, the input is choppy as it only detects 
# --- an input event when the value changes significantly
@onready var joystick_timer: Timer = $JoystickTimer

# store the location of the last direction-input (mouse or right-joystick)
@onready var light_target: Vector3 = Vector3.ZERO
# track whether spotlight is currently rotating or not
@onready var is_rotating: bool = false
# used when rotating field of view
@onready var angular_velocity: float = 0.0

@onready var hit_cooldown_active: bool = false
# used to toggle opacity while hit cooldown active
@onready var hit_flash: bool = false
@onready var speed: float = 6.0
@onready var light_omni: OmniLight3D = $OmniLight3D
@onready var light_spot: SpotLight3D = $LightOffset/SpotLight3D
@onready var camera: Camera3D = $RotationOffset/Camera3D
@onready var sprite: Sprite3D = $RotationOffset/Sprite3D

# store initial position to return to when calling reset()
@onready var starting_position: Vector3 = position


func _ready() -> void:
	light_omni.light_color = Color("GOLDENROD")
	light_spot.light_color = Color("GOLDENROD")
	
	$HitCooldown.wait_time = HIT_COOLDOWN
	$HitFlash.wait_time = HIT_FLASH_SPEED
	
	$HitCooldown.timeout.connect(_on_hit_cooldown_timeout)
	$HitFlash.timeout.connect(_on_hit_flash_timeout)
	$DamageDetector.area_entered.connect(_on_enemy_area_entered)
	
	SignalBus.activated_shrine.connect(_on_activated_shrine)
	SignalBus.consumed_shrine.connect(_on_consumed_shrine)

	joystick_timer.timeout.connect(_on_joystick_timer_timeout)


# 'p_' prefix used to avoid "shadowing" warnings about matching variable names 
func init(p_state_machine: Node, shrine: Shrine, p_corpse: Corpse) -> void:
	self.state_machine = p_state_machine
	# add default shrine to active shrines
	active_shrines.append(shrine)
	# set reference to player corpse
	self.corpse = p_corpse


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


func _process(delta: float) -> void:
	if is_rotating:
		rotate_to_target(delta)


func _physics_process(delta: float) -> void:
	handle_movement(delta) 


func _input(event: InputEvent) -> void:
	# check for mouse or joystick-right input
	if event is InputEventMouseMotion:
		set_light_target_mouse()
	elif (event.is_action_pressed("joy_right_x_left")
		or event.is_action_pressed("joy_right_x_right")
		or event.is_action_pressed("joy_right_y_up")
		or event.is_action_pressed("joy_right_y_down")):
		# enable detection of non-changing controller input
		if joystick_timer.is_stopped():
			joystick_timer.start()


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


func set_light_target_mouse() -> void:
	var mouse_pos_2d: Vector2 = get_viewport().get_mouse_position()
	var player_pos_2d: Vector2 = camera.unproject_position(position)
	var light_direction: Vector2 = (mouse_pos_2d - player_pos_2d)
	
	light_target = Vector3(light_direction.x, 1, light_direction.y)
	is_rotating = true


func set_light_target_controller() -> void:
	var input_dir: Vector2 = Focus.input_get_vector(
		"joy_right_x_left", "joy_right_x_right", "joy_right_y_up", "joy_right_y_down")
	# from_angle() calculates from x-axis, so must be adjusted
	var current_rotation: Vector2 = Vector2.from_angle(-$LightOffset.rotation.y - PI/2)
	# set light_target to slightly beside current rotation so that when
	# the joystick input ceases, the light target is quickly reached.
	# --- avoids continuing to rotate after input stops
	var light_direction: Vector2 = current_rotation.lerp(input_dir, 0.3)
	
	light_target = Vector3(light_direction.x, 1, light_direction.y)
	is_rotating = true


func rotate_to_target(delta: float) -> void:
	var light_target_xz: Vector3 = Vector3(light_target.x, 0, light_target.z).normalized()
	var target_rotation: float = Vector3.FORWARD.signed_angle_to(light_target_xz, Vector3.UP)
	var angle_diff: float = angle_difference($LightOffset.rotation.y, target_rotation)
	
	# check whether we are near the target
	if abs(angle_diff) > TARGET_THRESHOLD:
		# cap turning speed at maximum angular velocity
		var max_velocity: float = clamp(abs(angle_diff) * 10.0, 0, MAX_ANGULAR_SPEED)
		# apply acceleration or deceleration based on distance to target
		# accelerate if target is far; decelerate if target is close
		var accel: float
		if abs(angle_diff) >= DECELERATION_THRESHOLD:
			accel = ANGULAR_ACCELERATION
		else:
			accel = ANGULAR_DECELERATION
		# update angular velocity with acceleration/deceleration
		angular_velocity = move_toward(angular_velocity, sign(angle_diff) * max_velocity, delta * accel)
	else:
		# always decelerate when close enough to the target
		angular_velocity = move_toward(angular_velocity, 0, delta * ANGULAR_DECELERATION)
	
	# add calculated speed to spotlight rotation
	$LightOffset.rotation.y += angular_velocity * delta
	
	# stop rotating if close enough to target and slow enough
	# avoids instantly stop/starting rotation if the target swaps rotation directions
	if abs(angle_diff) < TARGET_THRESHOLD and abs(angular_velocity) < TARGET_THRESHOLD:
		$LightOffset.rotation.y = target_rotation
		angular_velocity = 0
		is_rotating = false


func hit() -> void:
	# pass signal for state-specific behavior
	SignalBus.emit_signal("player_hurt")


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
		hit()
	# do nothing if cooldown active


func _on_hit_cooldown_timeout() -> void:
	# deactivate invincibility frames
	hit_cooldown_active = false
	# stop flashing animation
	$HitFlash.stop()
	if $DamageDetector.has_overlapping_areas():
		hit()


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


func _on_joystick_timer_timeout() -> void:
	# get joystick input
	var input_dir: Vector2 = Focus.input_get_vector(
		"joy_right_x_left", "joy_right_x_right", "joy_right_y_up", "joy_right_y_down")
	
	if input_dir != Vector2.ZERO:
		# stick is held down, rotate to target direction
		set_light_target_controller()
	else:
		# if the player releases the joystick, stop polling
		joystick_timer.stop()
