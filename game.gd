extends Node3D

# state machine node-based design partially sourced from:
# "Starter state machines in Godot 4" by "The Shaggy Dev"
# https://www.youtube.com/watch?v=oqFbZoA2lnU
@onready var state_machine: Node = $StateMachine
@onready var player: Player = $Player
@onready var light_directional: DirectionalLight3D = $DirectionalLight3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize player
	# pass reference of state machine to the player
	player.init($StateMachine)
	
	# Initialize state machine
	# pass reference of the player to the states
	state_machine.init($Player)
	SignalBus.player_state_changed.connect(_on_player_state_changed)


func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)


func _physics_process(delta: float) -> void:
	# handle basic movement before passing to state-specific actions
	state_machine.process_physics(delta)


func _process(delta: float) -> void:
	state_machine.process_frame(delta)


func _on_player_state_changed(state_name: String) -> void:
	print("State entered: ", state_name)
	match state_name:
		"Living":
			player.light_omni.visible = true
			player.light_spot.visible = true
			light_directional.visible = false
			$World/RoomCenter/Hurtbox/Label3D.text = "HURTBOX\n\nCome here to\nget hurt ;_ ;"
		"Dying":
			player.light_omni.visible = true
			player.light_spot.visible = true
			light_directional.visible = false
		"Dead":
			player.light_omni.visible = false
			player.light_spot.visible = false
			light_directional.visible = true
			$World/RoomCenter/Hurtbox/Label3D.text = "HURTBOX\n\nDon't worry little ghost,\n\nHurtbox can't hurt you."
	
	# TEMPORARY
	update_ghost_visibility(state_name)


# TEMPORARY function to update ghost visibility based on player state
func update_ghost_visibility(state_name: String) -> void:
	var ghost: Ghost = get_node("World/RoomCenter/Ghost")
	var ghost_mesh_instance: MeshInstance3D = ghost.get_node("MeshInstance3D")
	var ghost_mesh: CapsuleMesh = ghost_mesh_instance.mesh
	var material: Material = ghost_mesh.material
	
	var opacity: float
	match state_name:
		"Living":
			opacity = 0
		"Dying":
			opacity = 0.2
		"Dead":
			opacity = 0.8
	
	material.albedo_color.a = opacity
