class_name Ghost
extends CharacterBody3D

var movement_boundaries: Rect2

@onready var state_machine: Node = $StateMachine
@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new() # generating wait time and target positions

@onready var speed: float = 4.0
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


func _physics_process(delta: float) -> void:
	# handle basic movement before passing to state-specific actions
	state_machine.process_physics(delta)


func reset() -> void:
	# return to starting position and state
	position = starting_position
	state_machine.change_state(state_machine.starting_state)


func move_to_target(delta: float) -> void:
	var direction: Vector3 = target_pos - global_position
	var distance_to_target: float = global_position.distance_to(target_pos)
	
	if distance_to_target > 0.1:
		direction = direction.normalized()
	
	if distance_to_target < speed * delta:
		# set target to ghost position if close enough
		velocity = Vector3.ZERO
		target_pos = global_position
		at_target = true
	else:
		velocity = direction * speed
		move_and_slide()


func _on_player_entered_room(room: Node3D) -> void:
	if room == current_room:
		player_in_room = true


func _on_player_exited_room(room: Node3D) -> void:
	if room == current_room:
		player_in_room = false
