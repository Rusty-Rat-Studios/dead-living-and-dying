class_name Ghost
extends CharacterBody3D

signal hit

const BASE_SPEED: float = 4.0
# time to wait before attacking when player enters room
const ATTACK_DELAY: float = 0.3

# opacity values set according to player state
const OPACITY_DYING: float = 0.2
const OPACITY_DEAD: float = 0.8

var movement_boundaries: Rect2

@onready var state_machine: StateMachine = $StateMachine

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
	
	# attach signals for updating player_in_room flag
	# states listening for same signals are connected with CONNECT_DEFERRED
	# to ensure this connection always evaluates first when signal emits
	SignalBus.player_entered_room.connect(_on_player_entered_room)
	SignalBus.player_exited_room.connect(_on_player_exited_room)
	# attach signal to update ghost visibility based on player state
	SignalBus.player_state_changed.connect(_on_player_state_changed)
	
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


func move_to_target(delta: float) -> void:
	var direction: Vector3 = target_pos - global_position
	var distance_to_target: float = global_position.distance_to(target_pos)
	
	if distance_to_target < speed * delta:
		# set target to ghost position if close enough
		at_target = true
		velocity = Vector3.ZERO
		target_pos = global_position
	else:
		at_target = false
		direction = direction.normalized()
		velocity = direction * speed
		move_and_slide()


func _on_player_entered_room(room: Node3D) -> void:
	if room == current_room:
		player_in_room = true
	
	# regardless of state, attack the player if they enter the room in DEAD state
	if player_in_room and PlayerHandler.get_player_state() == "Dead":
		# add delay to allow player breathing room when entering the room
		await Utility.delay(ATTACK_DELAY)
		state_machine.change_state(state_machine.States.ATTACKING)


func _on_player_exited_room(room: Node3D) -> void:
	if room == current_room:
		player_in_room = false


func _on_hit() -> void:
	if state_machine.current_state != state_machine.States.STUNNED:
		state_machine.change_state(state_machine.States.STUNNED)
		$ParticleBurst.emitting = true


func _on_player_state_changed(state_name: String) -> void:
	var material: Material = $MeshInstance3D.mesh.material
	
	var opacity: float
	match state_name:
		"Living":
			opacity = 0
		"Dying":
			opacity = OPACITY_DYING
		"Dead":
			opacity = OPACITY_DEAD
	
	material.albedo_color.a = opacity
