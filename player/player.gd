class_name Player
extends CharacterBody3D

# used to set cooldown timer
const HIT_COOLDOWN: float = 2.0

# for controlling player rotation in a momentum-like fashion
const MAX_ANGULAR_SPEED: float = 3.0
const ANGULAR_ACCELERATION: float = 10.0
const ANGULAR_DECELERATION: float = 40.0
const TARGET_THRESHOLD: float = 0.01
const DECELERATION_THRESHOLD: float = 10 * TARGET_THRESHOLD

var state_machine: Node

# used to continue processing controller input when the stick is held 
# in the same direction - Godot's built-in InputEvent only detects changes
# --- without this, the input is choppy as it only detects 
# --- an input event when the value changes significantly
@onready var joystick_timer: Timer = $JoystickTimer
@onready var joystick_unused_timeout: int = 0

# store the location of the last direction-input (mouse or right-joystick)
@onready var light_target: Vector3 = Vector3.ZERO
# track whether spotlight is currently rotating or not
@onready var is_rotating: bool = false
# used when rotating field of view
@onready var angular_velocity: float = 0.0

@onready var hit_cooldown_active: bool = false
@onready var speed: float = 6.0
@onready var light_omni: OmniLight3D = $OmniLight3D
@onready var light_spot: SpotLight3D = $LightOffset/SpotLight3D
@onready var camera: Camera3D = $RotationOffset/Camera3D

func _ready() -> void:
	light_omni.light_color = Color("GOLDENROD")
	light_spot.light_color = Color("GOLDENROD")
	SignalBus.player_hurt.connect(_on_player_hurt)
	$HitCooldown.timeout.connect(_on_hit_cooldown_timeout)
	$JoystickTimer.timeout.connect(_on_joystick_timer_timeout)


func init(state_machine: Node) -> void:
	self.state_machine = state_machine 


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
		set_light_target_controller()
		# enable detection of non-changing controller input
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


func _on_player_hurt() -> void:
	if not hit_cooldown_active:
		# hit cooldown is inactive, start cooldown
		hit_cooldown_active = true
		SignalBus.emit_signal("player_hurt")
		$HitCooldown.wait_time = HIT_COOLDOWN
		$HitCooldown.start()
	# do nothing if cooldown active


func _on_hit_cooldown_timeout() -> void:
	# deactivate invincibility frames
	hit_cooldown_active = false
	
	# reset cooldown
	$HitCooldown.wait_time = HIT_COOLDOWN


func _on_joystick_timer_timeout() -> void:
	# if the player does not use a controller for a while, 
	# disable the joystick input timer
	if joystick_unused_timeout > 10:
		joystick_timer.stop()
		joystick_unused_timeout = 0
		print(Time.get_time_string_from_system(), ": joystick input polling stopped")
		return
	
	var input_dir: Vector2 = Focus.input_get_vector(
		"joy_right_x_left", "joy_right_x_right", "joy_right_y_up", "joy_right_y_down")
	
	if input_dir != Vector2.ZERO:
		set_light_target_controller()
		# reset count for detecting unused controller input
		joystick_unused_timeout = 0
	else:
		# no controller input - increment unused counter
		joystick_unused_timeout += 1
