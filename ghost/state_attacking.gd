extends GhostState

@onready var player: Player = PlayerHandler.get_player()

func _ready() -> void:
	# defer connecting this signal to ensure this function executes
	# AFTER this signal updates the player_in_room flag in ghost.gd
	SignalBus.player_exited_room.connect(_on_player_exited_room, CONNECT_DEFERRED)
	SignalBus.player_state_changed.connect(_on_player_state_changed)


func enter() -> void:
	# guard to ensure player is in room and DEAD when entering attack state
	if not (parent.player_in_room and PlayerHandler.get_player_state() == "Dead"):
		change_state(States.WAITING)
		return
	parent.speed = 7.0


func process_physics(_delta: float) -> void:
	parent.target_pos = player.global_position


func _on_player_exited_room(room: Node3D) -> void:
	if room == parent.current_room and not parent.player_in_room:
		change_state(States.WAITING)


func _on_player_state_changed(state_name: String) -> void:
	if state_machine.current_state == States.ATTACKING and state_name == "Living":
		change_state(States.WAITING)
