extends GhostState

@onready var player: Player = PlayerHandler.get_player()

func enter() -> void:
	super()
	parent.speed = 8.0


func process_physics(delta: float) -> State:
	parent.target_pos = player.global_position
	parent.move_to_target(delta)
	
	return null # remain in attacking state
