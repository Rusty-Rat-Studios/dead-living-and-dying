extends Node3D

@onready var state_machine: Node = $StateMachine
# state machine node-based design partially sourced from:
# "Starter state machines in Godot 4" by "The Shaggy Dev"
# https://www.youtube.com/watch?v=oqFbZoA2lnU


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize state machine
	# pass reference of the player to the states
	state_machine.init($Player)
	state_machine.connect("state_entered", Callable(self, "_on_state_entered"))


func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)


func _physics_process(delta: float) -> void:
	# handle basic movement before passing to state-specific actions
	state_machine.process_physics(delta)


func _process(delta: float) -> void:
	state_machine.process_frame(delta)


func _on_state_entered(state_name: String):
	print("State entered: ", state_name)
