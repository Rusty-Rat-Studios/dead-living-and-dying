extends Node3D

# state machine node-based design partially sourced from:
# "Starter state machines in Godot 4" by "The Shaggy Dev"
# https://www.youtube.com/watch?v=oqFbZoA2lnU
@onready var state_machine: Node = $StateMachine
@onready var player: Player = $Player
@onready var light_omni: OmniLight3D = player.light
@onready var light_directional: DirectionalLight3D = $DirectionalLight3D


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
	match state_name:
		"Living":
			light_omni.visible = true
			light_directional.visible = false
		"Dying":
			player.light.visible = true
			light_directional.visible = false
		"Dead":
			player.light.visible = false
			light_directional.visible = true
