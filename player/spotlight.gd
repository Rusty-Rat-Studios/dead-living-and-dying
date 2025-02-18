extends SpotLight3D

# for controlling player rotation in a momentum-like fashion
const MAX_ANGULAR_SPEED: float = 4.0
const ANGULAR_ACCELERATION: float = 10.0
const ANGULAR_DECELERATION: float = 30.0
# used to check if spotlight is rotated close enough to the target
const TARGET_THRESHOLD: float = 0.1
# used to begin decelerating rotation when close but not at target
const DECELERATION_THRESHOLD: float = 2 * TARGET_THRESHOLD

# used to skew sprite to emulate "looking" towards spotlight
const SKEW_SCALE: float = 0.9 # smaller value = more skew
const SKEW_ROTATION: float = PI / 7 # smaller denominator = more skew
const SPRITE_ANIMATION_FRONT: String = "front"
const SPRITE_ANIMATION_BACK: String = "back"

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
@onready var sprite: AnimatedSprite3D = get_parent().get_node("RotationOffset/AnimatedSprite3D")
# used to disable skew effect if needed (e.g. in DEAD state)
@onready var skew_enabled: bool = true

func _ready() -> void:
	light_color = Color("GOLDENROD")
	
	SignalBus.player_state_changed.connect(_on_player_state_changed)
	joystick_timer.timeout.connect(_on_joystick_timer_timeout)


func _process(delta: float) -> void:
	if is_rotating:
		rotate_to_target(delta)
		if skew_enabled:
			skew_sprite()


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


func set_light_target_mouse() -> void:
	var mouse_pos_2d: Vector2 = get_viewport().get_mouse_position()
	var player_pos_2d: Vector2 = get_viewport().get_camera_3d().unproject_position(global_position)
	var light_direction: Vector2 = (mouse_pos_2d - player_pos_2d)
	
	light_target = Vector3(light_direction.x, 0, light_direction.y)
	is_rotating = true


func set_light_target_controller() -> void:
	var input_dir: Vector2 = Focus.input_get_vector(
		"joy_right_x_left", "joy_right_x_right", "joy_right_y_up", "joy_right_y_down")
	# from_angle() calculates from x-axis, so must be adjusted
	var current_rotation: Vector2 = Vector2.from_angle(-rotation.y - PI/2)
	# set light_target to slightly beside current rotation so that when
	# the joystick input ceases, the light target is quickly reached.
	# --- avoids continuing to rotate after input stops
	var light_direction: Vector2 = current_rotation.slerp(input_dir, 0.3)
	
	light_target = Vector3(light_direction.x, 0, light_direction.y)
	is_rotating = true


func rotate_to_target(delta: float) -> void:
	var light_target_xz: Vector3 = Vector3(light_target.x, 0, light_target.z).normalized()
	var target_rotation: float = Vector3.FORWARD.signed_angle_to(light_target_xz, Vector3.UP)
	var angle_diff: float = angle_difference(rotation.y, target_rotation)
	
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
	rotation.y += angular_velocity * delta
	
	# stop rotating if close enough to target and slow enough
	# avoids instantly stop/starting rotation if the target swaps rotation directions
	if abs(angle_diff) < TARGET_THRESHOLD and abs(angular_velocity) < TARGET_THRESHOLD:
		angular_velocity = 0
		is_rotating = false


func skew_sprite() -> void:
	# clamp light offset rotation between -PI and PI
	if rotation.y >= PI:
		rotation.y = -PI
	elif rotation.y <= -PI:
		rotation.y = PI
	# skew sprite to make it appear as though it is "looking" in the target direction
	sprite.scale.x = clamp(abs(cos(rotation.y)), SKEW_SCALE, 1)
	
	# flip animation based on rotation amount
	if rotation.y > -PI/2 and rotation.y <= PI/2:
		sprite.animation = SPRITE_ANIMATION_BACK
		sprite.rotation.y = clampf(rotation.y, -SKEW_ROTATION, SKEW_ROTATION)
	else:
		sprite.animation = SPRITE_ANIMATION_FRONT
		
		if rotation.y > 0:
			sprite.rotation.y = clampf(rotation.y, PI - SKEW_ROTATION, PI)
		else:
			sprite.rotation.y = clampf(rotation.y, -PI, SKEW_ROTATION - PI)


func enable_skew() -> void:
	skew_enabled = true
	# set skew immediately after enabling
	skew_sprite()


func disable_skew() -> void:
	skew_enabled = false
	# reset sprite skew
	sprite.rotation.y = 0
	sprite.scale.x = 1
	sprite.animation = SPRITE_ANIMATION_FRONT


func _on_player_state_changed(state: PlayerStateMachine.States) -> void:
	if state == PlayerStateMachine.States.DEAD:
		disable_skew()
	else:
		enable_skew()


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
