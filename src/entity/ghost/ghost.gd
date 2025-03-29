class_name Ghost
extends CharacterBody3D

signal hit
# connected to by states to process target-driven behavior
# i.e. moving through a door
signal target_reached

# TODO: remove when stats implemented across all states
const BASE_SPEED: float = 4.0
# TODO: remove when stats implemented across all states
const ATTACK_DELAY: float = 0.3
# time to tween light visibility when ghost starts/stops moving
const LIGHT_FADE_DURATION: float = 0.3
const LIGHT_ENERGY: float = 0.1

# opacity values set according to player state
const OPACITY_DYING_MODIFIER: float = 0.2
const OPACITY_DEAD_MODIFIER: float = 0.8
const OPACITY_DYING_MODIFIER_NAME: String = "dying"
const OPACITY_DEAD_MODIFIER_NAME: String = "dead"
const OPACITY_FADE_DURATION: float = 1

var movement_boundaries: Rect2
var opacity_tween: Tween
var light_tween: Tween
var light_enabled: bool = false
# set when the light should be permanently visible (e.g. boss events)
var light_enabled_permanent: bool = false

@onready var state_machine: GhostStateMachine = $StateMachine

@onready var stats: GhostStats = GhostStats.new()

@onready var hitbox: Area3D = $Hitbox
# used by state ATTACKING to detect if player in range of stun attack
@onready var attack_range: Area3D = $AttackRange

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var light: OmniLight3D = $OmniLight3D

@onready var speed: float = BASE_SPEED
@onready var current_room: Room = get_parent()
@onready var player_in_room: bool = false
@onready var target_pos: Vector3 = Vector3.ZERO
@onready var at_target: bool = false

# store initial position to return to when calling reset()
@onready var starting_position: Vector3 = position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize state machine
	# pass reference of the ghost to the states
	state_machine.init(self)
	
	# set opacity to 0 and disable self-light
	# left visible in editor for debugging purposes
	sprite.modulate.a = 0
	light.light_energy = 0
	
	# attach signals for updating player_in_room flag
	# states listening for same signals are connected with CONNECT_DEFERRED
	# to ensure this connection always evaluates first when signal emits
	SignalBus.player_entered_room.connect(_on_player_entered_room)
	SignalBus.player_exited_room.connect(_on_player_exited_room)
	# attach signal to update ghost visibility based on player state
	SignalBus.player_state_changed.connect(_on_player_state_changed, CONNECT_DEFERRED)
	
	hit.connect(_on_hit)


func _physics_process(delta: float) -> void:
	# handle state-specific actions (i.e. updating movement target)
	# before handling movement
	state_machine.process_current_state()
	move_to_target(delta)


func reset() -> void:
	# return to starting position and state
	position = starting_position
	state_machine.reset()


func set_target(target_global: Vector3) -> void:
	at_target = false
	# set the target_pos value
	target_pos = target_global
	# flip sprite horizontally according to direction of target
	# with a deadzone margin to prevent oscillating back and forth
	if abs(target_global.x - global_position.x) > 0.5:
		sprite.flip_h = target_global.x > global_position.x
	
	if light_enabled and not light_enabled_permanent:
		# make light visible
		set_light(LIGHT_ENERGY)


func move_to_target(delta: float) -> void:
	var direction: Vector3 = target_pos - global_position
	# force target_pos onto y=1 plane to ensure ghost can "reach" targets
	# at different heights - i.e. player which is at a lower height
	target_pos = Vector3(target_pos.x, 1, target_pos.z)
	var distance_to_target: float = global_position.distance_squared_to(target_pos)
	
	if distance_to_target < stats.speed * delta:
		# set target to ghost position if close enough
		at_target = true
		velocity = Vector3.ZERO
		target_pos = global_position
		target_reached.emit()
		
		if light_enabled and not light_enabled_permanent:
			# make light invisible
			set_light(0)
	else:
		at_target = false
		direction = direction.normalized()
		velocity = direction * stats.speed
		move_and_slide()


func set_opacity() -> void:
	if opacity_tween:
		opacity_tween.kill()
	opacity_tween = create_tween()
	opacity_tween.tween_property(sprite, "modulate:a", stats.opacity, OPACITY_FADE_DURATION)


func set_light(energy: float) -> void:
	if light_tween:
		light_tween.kill()
	light_tween = create_tween()
	light_tween.tween_property(light, "light_energy", energy, LIGHT_FADE_DURATION)


func _on_player_entered_room(room: Node3D) -> void:
	if room == current_room:
		player_in_room = true
	
	# regardless of state, attack the player if they enter the room in DEAD state
	if player_in_room and PlayerHandler.get_player_state() == PlayerStateMachine.States.DEAD:
		# add delay to allow player breathing room when entering the room
		await Utility.delay(stats.attack_delay)
		state_machine.change_state(state_machine.States.ATTACKING)


func _on_player_exited_room(room: Node3D) -> void:
	if room == current_room:
		player_in_room = false


func _on_hit() -> void:
	if state_machine.current_state != state_machine.States.STUNNED:
		state_machine.change_state(state_machine.States.STUNNED)
		$ParticleBurst.emitting = true


func _on_player_state_changed(state: PlayerStateMachine.States) -> void:
	stats.remove_modifier(GhostStats.Stats.OPACITY, "dying")
	stats.remove_modifier(GhostStats.Stats.OPACITY, "dead")
	match state:
		PlayerStateMachine.States.LIVING:
			$Shadow.visible = false
			light_enabled = false
		PlayerStateMachine.States.DYING:
			stats.add_modifier(GhostStats.Stats.OPACITY, OPACITY_DYING_MODIFIER, OPACITY_DYING_MODIFIER_NAME)
			$Shadow.visible = true
			light_enabled = true
		PlayerStateMachine.States.DEAD:
			stats.add_modifier(GhostStats.Stats.OPACITY, OPACITY_DEAD_MODIFIER, OPACITY_DEAD_MODIFIER_NAME)
			$Shadow.visible = true
			light_enabled = false
	
	set_opacity()
