class_name Ghost
extends CharacterBody3D

@onready var state_machine: Node = $StateMachine

@onready var speed: float = 4.0
@onready var current_room: Node3D = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize state machine
	# pass reference of the player to the states
	state_machine.init(self)


func _physics_process(delta: float) -> void:
	# handle basic movement before passing to state-specific actions
	state_machine.process_physics(delta)
