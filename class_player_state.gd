class_name PlayerState
extends State

@export var state_dead: State
@export var state_living: State
@export var state_dying: State

@export var speed: float = 6.0

#@export var animation_name: String

# reference to player passed into states to allow state-based control
@onready var parent: Player = $Player

func enter() -> void:
	#parent.animations.play(animation_name)
	pass
