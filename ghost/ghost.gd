class_name Ghost
extends CharacterBody3D

@onready var state_machine: Node = $StateMachine

@onready var speed: float = 4.0
@onready var current_room: Node3D = get_parent()
@onready var target_pos: Vector3 = Vector3.ZERO
@onready var at_target: bool = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize state machine
	# pass reference of the player to the states
	state_machine.init(self)


func _physics_process(delta: float) -> void:
	# handle basic movement before passing to state-specific actions
	state_machine.process_physics(delta)



func move_to_target(delta: float) -> void:
	var direction: Vector3 = (target_pos - position).normalized()
	var distance_to_target: float = position.distance_to(target_pos)
	
	if distance_to_target < speed * delta:
		# set target to ghost position if close enough
		target_pos = position
		at_target = true
	else:
		velocity = direction * speed
		move_and_slide()
