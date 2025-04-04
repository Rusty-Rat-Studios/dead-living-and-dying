class_name Player
extends CharacterBody3D

const OPACITY_DEAD: float = 0.3

# player state machine, sibling node under Game node
var _state_machine: PlayerStateMachine
#declaration of the object that holds all of the players current stats
@onready var player_stats: PlayerStats = PlayerStats.new()
# light variables used by state machine to adjust light strength based on state
@onready var light_omni: OmniLight3D = $OmniLight3D
@onready var light_spot: SpotLight3D = $SpotLight3D
@onready var camera: Camera3D = $RotationOffset/Camera3D
@onready var sprite_torso: AnimatedSprite3D = $RotationOffset/AnimatedSpriteTorso
@onready var sprite_legs: AnimatedSprite3D = $RotationOffset/AnimatedSpriteLegs
# updated by state machine when changing states
@onready var hurtbox: Area3D = $Hurtbox
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
# enabled/disabled by state DYING to allow ghost stun-attacks to hit
@onready var stunbox: Area3D = $Stunbox

# store initial position to return to when calling reset()
@onready var starting_position: Vector3 = position
# used to track player corpse - handled by DEAD state
@onready var _corpse: Corpse = $Corpse
@onready var _corpse_indicator: GPUParticles3D = $CorpseIndicator


func _ready() -> void:
	PlayerHandler.register_player(self)
	
	light_omni.light_color = Color("GOLDENROD")
	
	SignalBus.item_picked_up.connect(_on_item_picked_up)
	SignalBus.key_item_dropped.connect(_on_key_item_dropped)
	SignalBus.key_item_picked_up.connect(_on_key_item_picked_up)


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
		sprite_torso.flip_h = direction.x < 0
		sprite_legs.flip_h = direction.x < 0
	
	if velocity.length() > 0.01:
		sprite_legs.play()
	else:
		sprite_legs.pause()
	
	move_and_slide()


func take_damage(flash: bool = true) -> void:
	hurtbox.activate_hit_cooldown(flash)


func inventory_update() -> void:
	player_stats.remove_stat_modifiers()
	$Inventory.update_all()
	player_stats.update_stats()


func modulate_color(c: Color) -> void:
	get_node("RotationOffset/AnimatedSprite3D").modulate = c


func get_key_item_or_null() -> KeyItemInventory:
	for inventory_item: Node3D in get_node("Inventory").get_children():
		if inventory_item is KeyItemInventory:
			return inventory_item
	return null


func _on_item_picked_up(item: ItemInventory, current_consumable: bool = false, passed_count:int = 0) -> void:
	if item is KeyItemInventory:
		SignalBus.key_item_picked_up.emit()
		print("player detected key item pickup")
	if current_consumable == false:
		$Inventory.add_child(item)
		if item is ConsumableItemInventory:
			item.count = passed_count
	# ensure item position is directly on player
	item.position = Vector3.ZERO


func _on_key_item_picked_up() -> void:
	player_stats.stat_update_add(PlayerStats.Stats.LIGHT_OMNI_RANGE, -1.0, "key_item")
	player_stats.stat_update_add(PlayerStats.Stats.LIGHT_ENERGY, -0.2, "key_item")


func _on_key_item_dropped() -> void:
	player_stats.stat_update_remove(PlayerStats.Stats.LIGHT_OMNI_RANGE, "key_item")
	player_stats.stat_update_remove(PlayerStats.Stats.LIGHT_ENERGY, "key_item")
