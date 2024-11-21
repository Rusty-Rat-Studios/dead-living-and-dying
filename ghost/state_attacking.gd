extends GhostState

@onready var player: Player = PlayerHandler.get_player()

func _ready() -> void:
	SignalBus.player_exited_room.connect(_on_player_exited_room)


func enter() -> void:
	super()
	parent.speed = 8.0


func process_physics(delta: float) -> State:
	parent.target_pos = player.global_position
	parent.move_to_target(delta)
	
	return null # remain in attacking state


func _on_player_exited_room(room: Node3D) -> void:
	if room == parent.current_room:
		parent.state_machine.change_state(state_waiting)
