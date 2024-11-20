class_name GhostState
extends State

@export var state_waiting: State
@export var state_possessing_waiting: State
@export var state_possessing_attacking: State
@export var state_stunned: State
@export var state_attacking: State

var parent: Ghost

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
