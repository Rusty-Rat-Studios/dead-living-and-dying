class_name Player
extends CharacterBody3D

enum Stats {
	SPEED
}

const BASE_SPEED: float = 6.0

# base values used for light range and strength
const LIGHT_OMNI_RANGE: float = 6
const LIGHT_SPOT_RANGE: float = 10
const LIGHT_ENERGY: float = 1

var stat_dict: Dictionary = {
	Stats.SPEED : 6.0
}
# player state machine, sibling node under Game node
var state_machine: Node
# used to track player corpse - handled by states
var corpse: Corpse
# player state machine, sibling node under Game node
var _state_machine: PlayerStateMachine

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
		velocity.x = direction.x * stat_dict[Stats.SPEED]
		velocity.z = direction.z * stat_dict[Stats.SPEED]
	else:
		velocity.x = move_toward(velocity.x, 0, stat_dict[Stats.SPEED])
		velocity.z = move_toward(velocity.z, 0, stat_dict[Stats.SPEED])
	move_and_slide()


func take_damage(flash: bool = true) -> void:
	hurtbox.activate_hit_cooldown(flash)


func _on_item_picked_up(item: ItemInventory) -> void:
	if item is KeyItemInventory:
		SignalBus.key_item_picked_up.emit()
	$Inventory.add_child(item)
	# ensure item position is directly on player
	item.position = Vector3.ZERO


func stat_update( stat: Stats, stat_modifier: float) -> void:
	if stat_dict.has(stat):
		stat_dict[stat] += stat_modifier


func inventory_update() -> void:
	$Inventory.update_all()
