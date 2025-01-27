class_name PlayerState
extends State

@export var state_dead: State
@export var state_living: State
@export var state_dying: State

@export var speed: float = 6.0

# reference to player passed into states to allow state-based control
var parent: Player

func enter() -> void:
	pass


func process_input(_event: InputEvent) -> State:
	return null
