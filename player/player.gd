class_name Player
extends CharacterBody3D

signal speedChange

# player state machine, sibling node under Game node
var state_machine: Node
# used to track player corpse - handled by states
var corpse: Corpse

@onready var speed: float = 6.0
# light variables used by state machine to adjust light strength based on state
@onready var light_omni: OmniLight3D = $OmniLight3D
@onready var light_spot: SpotLight3D = $SpotLight3D
@onready var camera: Camera3D = $RotationOffset/Camera3D
# updated by state machine when changing states
@onready var hurtbox: Area3D = $Hurtbox
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# store initial position to return to when calling reset()
@onready var starting_position: Vector3 = position

func _ready() -> void:
	light_omni.light_color = Color("GOLDENROD")
	speedChange.connect(_on_speedChange)
	
	SignalBus.item_picked_up.connect(_on_item_picked_up)


func init(_state_machine: Node, _corpse: Corpse) -> void:
	self.state_machine = _state_machine
	# set reference to player corpse
	self.corpse = _corpse


func reset() -> void:
	# return to starting position and state
	position = starting_position
	hurtbox.reset()
	
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


func take_damage(flash: bool = true) -> void:
	hurtbox.activate_hit_cooldown(flash)


func _on_item_picked_up(item: ItemInventory) -> void:
	$Inventory.add_child(item)
	# ensure item position is directly on player
	item.position = Vector3.ZERO

func _on_speedChange(speed_modifier: float) -> void:
	speed += speed_modifier
