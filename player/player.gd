class_name Player
extends CharacterBody3D

# used to set cooldown timer
const HIT_COOLDOWN: float = 2.0

var state_machine: Node
# used to check whether mouse or controller was last used to look around
var last_mouse_pos: Vector2

@onready var hit_cooldown_active: bool = false
@onready var speed: float = 6.0
@onready var light_omni: OmniLight3D = $OmniLight3D
@onready var light_spot: SpotLight3D = $LightOffset/SpotLight3D
@onready var camera: Camera3D = $RotationOffset/Camera3D


func _ready() -> void:
	light_omni.light_color = Color("GOLDENROD")
	light_spot.light_color = Color("GOLDENROD")
	
	$DamageDetector.area_entered.connect(_on_enemy_entered)
	$HitCooldown.timeout.connect(_on_hit_cooldown_timeout)


func init(state_machine: Node) -> void:
	self.state_machine = state_machine 


# gdlint:ignore = unused-argument
func _process(delta: float) -> void:
	point_spotlight()


func _physics_process(delta: float) -> void:
	# handle basic movement before passing to state-specific actions
	handle_movement(delta) 


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


func point_spotlight() -> void:
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
	
	var light_target: Vector3 = Vector3(light_direction.x, 1, light_direction.y)
	# point light, ensuring parallel with floor
	$LightOffset.look_at(light_target)


func hit() -> void:
	hit_cooldown_active = true
	# start hit cooldown
	$HitCooldown.wait_time = HIT_COOLDOWN
	$HitCooldown.start()
	# pass signal for state-specific behavior
	SignalBus.emit_signal("player_hurt")


func _on_enemy_entered(area: Area3D) -> void:
	if not hit_cooldown_active:
		hit()
	# do nothing if cooldown active


func _on_hit_cooldown_timeout() -> void:
	# deactivate invincibility frames
	hit_cooldown_active = false
	if $DamageDetector.has_overlapping_areas():
		hit()
