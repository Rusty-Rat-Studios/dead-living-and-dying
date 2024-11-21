class_name Ghost
extends CharacterBody3D

@onready var state_machine: Node = $StateMachine

@onready var speed: float = 4.0
@onready var current_room: Node3D = get_parent()
@onready var target_pos: Vector3 = Vector3.ZERO
@onready var at_target: bool = false

var movement_boundaries: Rect2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize state machine
	# pass reference of the player to the states
	state_machine.init(self)


func _physics_process(delta: float) -> void:
	# handle basic movement before passing to state-specific actions
	state_machine.process_physics(delta)


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
