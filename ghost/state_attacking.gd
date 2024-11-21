extends GhostState

@onready var player = PlayerHandler.get_player()

func enter() -> void:
	super()
	
	parent.speed = 8.0
	
	# DEBUG
	print("ghost entered Attacking")


func process_physics(delta: float) -> State:
	parent.target_pos = player.global_position
	print("target pos: ", parent.target_pos,
	"\nghost pos :" , parent.position, 
	"\nplayer pos: ", player.global_position)
	parent.move_to_target(delta)
	
	return null # remain in attacking state


# create area3D that is the size of the movement boundaries
# if dead:
# on player enter area:
	# if dead, enter attack state
# on player exit area:
	# enter waiting state
