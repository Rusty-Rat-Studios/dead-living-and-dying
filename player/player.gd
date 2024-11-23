class_name Player
extends CharacterBody3D

# used to set cooldown timer
const HIT_COOLDOWN: float = 2.0

# base turning speed; can be modified to add acceleration, etc
const ROTATION_SPEED: float = 2

var state_machine: Node
# used to check whether mouse or controller was last used to look around
var last_mouse_pos: Vector2

# store the location of the last direction-input (mouse or right-joystick)
@onready var light_target: Vector3 = Vector3.ZERO
# track whether spotlight is currently rotating or not
@onready var is_rotating: bool = false

@onready var hit_cooldown_active: bool = false
@onready var speed: float = 6.0
# track whether player is moving or not
@onready var is_moving: bool = false
@onready var light_omni: OmniLight3D = $OmniLight3D
@onready var light_spot: SpotLight3D = $LightOffset/SpotLight3D
@onready var camera: Camera3D = $RotationOffset/Camera3D

@onready var ticks: int = 0

func _ready() -> void:
	light_omni.light_color = Color("GOLDENROD")
	light_spot.light_color = Color("GOLDENROD")
	SignalBus.player_hurt.connect(_on_player_hurt)
	$HitCooldown.timeout.connect(_on_hit_cooldown_timeout)


func init(state_machine: Node) -> void:
	self.state_machine = state_machine 


# gdlint:ignore = unused-argument
func _process(delta: float) -> void:
	if is_rotating:
		rotate_to_target(delta)


func _physics_process(delta: float) -> void:
	# handle basic movement before passing to state-specific actions
	handle_movement(delta) 


func _input(event: InputEvent) -> void:
	# check for mouse or joystick-right input
	if (event is InputEventMouseMotion or
		event.is_action_pressed("joy_right_x_left") or
		event.is_action_pressed("joy_right_x_right") or
		event.is_action_pressed("joy_right_x_up") or
		event.is_action_pressed("joy_right_x_down")
		):
			set_light_target()


func handle_movement(delta: float) -> void:
	if not is_on_floor(): # Add the gravity.
		velocity += get_gravity() * delta
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: Vector3
	
	# check for analog input
	var input_dir: Vector2 = Focus.input_get_vector(
		"joy_left_x_left", "joy_left_x_right", "joy_left_y_up", "joy_left_y_down"
	)
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


func rotate_to_target(delta: float) -> void:
	var light_target_xz: Vector3 = Vector3(light_target.x, 0, light_target.z).normalized()
	var current_rotation: float = $LightOffset.rotation.y
	var target_rotation: float = Vector3.FORWARD.signed_angle_to(light_target_xz, Vector3.UP)
	
	# interpolate the rotation angle from current to target
	var new_rotation: float = lerp_angle(current_rotation, target_rotation, ROTATION_SPEED * delta)
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
