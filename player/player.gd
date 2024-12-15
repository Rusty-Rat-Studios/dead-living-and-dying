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
# used to check whether mouse or controller was last used to look around
var last_mouse_pos: Vector2

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


func init(state_machine: Node) -> void:
	self.state_machine = state_machine 


func _process(delta: float) -> void:
	if is_rotating:
		rotate_to_target2(delta)


func _physics_process(delta: float) -> void:
	handle_movement(delta) 


func _input(event: InputEvent) -> void:
	# check for mouse or joystick-right input
	if event is InputEventMouseMotion:
		set_light_target_mouse()
	elif (event.is_action_pressed("joy_right_x_left") or
		event.is_action_pressed("joy_right_x_right") or
		event.is_action_pressed("joy_right_y_up") or
		event.is_action_pressed("joy_right_y_down")):
		set_light_target_controller()


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
		direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
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

"""
func set_light_target() -> void:
	var light_direction: Vector2
	# check for analog input
	var input_dir: Vector2 = Focus.input_get_vector(
		"joy_right_x_left", "joy_right_x_right", "joy_right_y_up", "joy_right_y_down"
	)
	if input_dir != Vector2.ZERO:
		# analog input
		# scale input to handle tiny analog inputs
		light_direction = input_dir.normalized() * 100
		# base target off of player position
		light_direction += Vector2(position.x, position.z) 
	else:
		# check for digital input
		# prevent mouse from regaining control if it hasn't moved
		var mouse_pos_2d: Vector2 = get_viewport().get_mouse_position()
		if mouse_pos_2d != last_mouse_pos: 
			# player has moved mouse
			last_mouse_pos = mouse_pos_2d
			var player_pos_2d: Vector2 = camera.unproject_position(position)
			light_direction = (mouse_pos_2d - player_pos_2d)
		else: 
			# no input, do not move light
			return
	
	light_target = Vector3(light_direction.x, 1, light_direction.y)
	is_rotating = true
"""

func set_light_target_mouse() -> void:
	var light_direction: Vector2
	# check for digital input
	# prevent mouse from regaining control if it hasn't moved
	var mouse_pos_2d: Vector2 = get_viewport().get_mouse_position()
	var player_pos_2d: Vector2 = camera.unproject_position(position)
	light_direction = (mouse_pos_2d - player_pos_2d)
	
	light_target = Vector3(light_direction.x, 1, light_direction.y)
	is_rotating = true


func set_light_target_controller() -> void:
	var a: MeshInstance3D = $MeshInstance3D
	var light_direction: Vector2
	var input_dir: Vector2 = Focus.input_get_vector(
		"joy_right_x_left", "joy_right_x_right", "joy_right_y_up", "joy_right_y_down")
	# set light_target to edge of field of view
	#var current_rotation: Vector2 = Vector2.from_angle($LightOffset.rotation.y)
	var current_rot: float = $LightOffset.rotation.y
	var current_rotation: Vector2 = Vector2.from_angle(current_rot)
	a.position = Vector3(current_rotation.x, 1, current_rotation.y).normalized()
	light_direction = current_rotation.lerp(input_dir, 0.3)
	# base target off of player position
	light_direction += Vector2(position.x, position.z)
	
	light_target = Vector3(light_direction.x, 1, light_direction.y)
	print("input dir: ", input_dir)
	print("current rotation: ", current_rotation)
	print("light direction: ", light_direction)
	print("light_target: ", light_target)

	is_rotating = true


func rotate_to_target2(delta: float) -> void:
	var light_target_xz: Vector3 = Vector3(light_target.x, 0, light_target.z).normalized()
	var target_rotation: float = Vector3.FORWARD.signed_angle_to(light_target_xz, Vector3.UP)
	var current_rotation: float = $LightOffset.rotation.y
	var angle_diff: float = angle_difference(current_rotation, target_rotation)
	
	if abs(angle_diff) > TARGET_THRESHOLD:
		var max_velocity: float = clamp(abs(angle_diff) * 10.0, 0, MAX_ANGULAR_SPEED)
		
		# accelerate up to maximum angular speed
		#angular_velocity += ANGULAR_ACCELERATION * delta * sign(angle_diff)
		#angular_velocity = clampf(angular_velocity, -MAX_ANGULAR_SPEED, MAX_ANGULAR_SPEED)
		
		# dynamically adjust deceleration as target is approached
		if abs(angle_diff) < DECELERATION_THRESHOLD:
			#var weighted_distance: float = 1.0 - abs(angle_diff) / DECELERATION_THRESHOLD
			#angular_velocity = move_toward(angular_velocity, 0.0, delta * weighted_distance)
			angular_velocity = move_toward(angular_velocity, sign(angle_diff) * max_velocity, delta * ANGULAR_DECELERATION)
		else:
			angular_velocity += ANGULAR_ACCELERATION * delta * sign(angle_diff)
			angular_velocity = clamp(angular_velocity, -MAX_ANGULAR_SPEED, MAX_ANGULAR_SPEED)
	else:
		# decelerate when close enough to the target
		angular_velocity = move_toward(angular_velocity, 0, delta * ANGULAR_DECELERATION)
	
	current_rotation += angular_velocity * delta
	
	# stop rotating if close enough to target and slow enough
	if abs(angle_diff) < TARGET_THRESHOLD and abs(angular_velocity) < TARGET_THRESHOLD:
		current_rotation = target_rotation
		angular_velocity = 0
		is_rotating = false
	
	$LightOffset.rotation.y = current_rotation


func rotate_to_target1(delta: float) -> void:
	var light_target_xz: Vector3 = Vector3(light_target.x, 0, light_target.z).normalized()
	var current_rotation: float = $LightOffset.rotation.y
	var target_rotation: float = Vector3.FORWARD.signed_angle_to(light_target_xz, Vector3.UP)
	
	# interpolate the rotation angle from current to target
	var new_rotation: float = lerp_angle(current_rotation, target_rotation, MAX_ANGULAR_SPEED * delta)
	$LightOffset.rotation.y = new_rotation
	
	# stop rotating when close enough
	if abs(new_rotation - target_rotation) < 0.01:
		$LightOffset.rotation.y = target_rotation
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
