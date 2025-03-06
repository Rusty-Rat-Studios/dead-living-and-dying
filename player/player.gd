class_name Player
extends CharacterBody3D

# player state machine, sibling node under Game node
var state_machine: Node
# used to track player corpse - handled by states
var corpse: Corpse
# player state machine, sibling node under Game node
var _state_machine: PlayerStateMachine
#declaration of the object that holds all of the players current stats
@onready var player_stats: PlayerStats = PlayerStats.new()
# light variables used by state machine to adjust light strength based on state
@onready var light_omni: OmniLight3D = $OmniLight3D
@onready var light_spot: SpotLight3D = $SpotLight3D
@onready var camera: Camera3D = $RotationOffset/Camera3D
@onready var sprite: AnimatedSprite3D = $RotationOffset/AnimatedSprite3D
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
@onready var _corpse_indicator: GPUParticles3D = $CorpseIndicator


func _ready() -> void:
	light_omni.light_color = Color("GOLDENROD")
	
	SignalBus.item_picked_up.connect(_on_item_picked_up)


func _process(_delta: float) -> void:
	light_omni.omni_range = player_stats.light_omni_range
	light_omni.light_energy = player_stats.light_energy
	light_spot.spot_range = player_stats.light_spot_range
	light_spot.light_energy = player_stats.light_energy


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
	# Set Player position for shaders
	RenderingServer.global_shader_parameter_set("Player", self.global_position)
	_state_machine.process_current_state()


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
		velocity.x = direction.x * player_stats.speed
		velocity.z = direction.z * player_stats.speed
	else:
		velocity.x = move_toward(velocity.x, 0, player_stats.speed)
		velocity.z = move_toward(velocity.z, 0, player_stats.speed)
	
	if abs(velocity.x) > 0.01:
		sprite.flip_h = direction.x < 0
	
	move_and_slide()


func take_damage(flash: bool = true) -> void:
	hurtbox.activate_hit_cooldown(flash)


func _on_item_picked_up(item: ItemInventory) -> void:
	if item is KeyItemInventory:
		SignalBus.key_item_picked_up.emit()
	$Inventory.add_child(item)
	# ensure item position is directly on player
	item.position = Vector3.ZERO


func inventory_update() -> void:
	player_stats.remove_stat_modifiers()
	$Inventory.update_all()
	player_stats.update_stats()
