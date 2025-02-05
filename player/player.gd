class_name Player
extends CharacterBody3D

const BASE_SPEED: float = 6.0

# base values used for light range and strength
const LIGHT_OMNI_RANGE: float = 6
const LIGHT_SPOT_RANGE: float = 10
const LIGHT_ENERGY: float = 1

# player state machine, sibling node under Game node
var _state_machine: PlayerStateMachine

@onready var speed: float = BASE_SPEED
# light variables used by state machine to adjust light strength based on state
@onready var light_omni: OmniLight3D = $OmniLight3D
@onready var light_spot: SpotLight3D = $SpotLight3D
@onready var camera: Camera3D = $RotationOffset/Camera3D
# updated by state machine when changing states
@onready var hurtbox: Area3D = $Hurtbox
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
# enabled/disabled by state DYING to allow ghost stun-attacks to hit
@onready var stunbox: Area3D = $Stunbox

# store initial position to return to when calling reset()
@onready var starting_position: Vector3 = position
# used to track player corpse - handled by states
# corpse set as child of Node to intentionally not inherit parent position
@onready var _corpse: Corpse = $CorpseContainer/Corpse


func _ready() -> void:
	light_omni.light_color = Color("GOLDENROD")
	
	SignalBus.item_picked_up.connect(_on_item_picked_up)


func init(state_machine: Node) -> void:
	_state_machine = state_machine


func reset() -> void:
	# return to starting position and state
	position = starting_position
	hurtbox.reset()
	_state_machine.reset()
	camera.reset()
	_corpse.reset()


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


func take_damage(flash: bool = true) -> void:
	hurtbox.activate_hit_cooldown(flash)


func _on_item_picked_up(item: ItemInventory) -> void:
	$Inventory.add_child(item)
	# ensure item position is directly on player
	item.position = Vector3.ZERO
