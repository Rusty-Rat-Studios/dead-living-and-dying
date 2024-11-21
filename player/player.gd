class_name Player
extends CharacterBody3D

@onready var speed: float = 6.0
@onready var light_omni: OmniLight3D = $OmniLight3D
@onready var light_spot: SpotLight3D = $LightOffset/SpotLight3D
@onready var camera: Camera3D = $RotationOffset/Camera3D

func _ready() -> void:
	light_omni.light_color = Color("GOLDENROD")
	light_spot.light_color = Color("GOLDENROD")


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
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()


func point_spotlight() -> void:
	var mouse_pos_2d: Vector2 = get_viewport().get_mouse_position()
	var player_pos_2d: Vector2 = camera.unproject_position(position)
	var light_direction: Vector2 = (mouse_pos_2d - player_pos_2d)
	var light_target: Vector3 = Vector3(light_direction.x, 1, light_direction.y)
	
	# point light at mouse, ensuring parallel with floor
	$LightOffset.look_at(light_target)
