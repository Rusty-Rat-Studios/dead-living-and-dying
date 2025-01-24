extends GhostState

@onready var player: Player = PlayerHandler.get_player()

func _ready() -> void:
	# defer connecting this signal to ensure this function executes
	# AFTER this signal updates the player_in_room flag in ghost.gd
	SignalBus.player_exited_room.connect(_on_player_exited_room, CONNECT_DEFERRED)


func enter() -> void:
	# guard to ensure player is in room and DEAD when entering attack state
	if not (parent.player_in_room and PlayerHandler.get_player_state() == "Dead"):
		parent.state_machine.change_state(state_waiting)
		return
	parent.speed = 7.0


func process_physics(delta: float) -> State:
	parent.target_pos = player.global_position
	parent.move_to_target(delta)
	
	return null # remain in attacking state


func _on_player_exited_room(room: Node3D) -> void:
	if room == parent.current_room and not parent.player_in_room:
		parent.state_machine.change_state(state_waiting)
