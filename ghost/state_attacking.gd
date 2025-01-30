extends GhostState

const ATTACK_SPEED: float = 7.0

@onready var player: Player = PlayerHandler.get_player()

func _ready() -> void:
	# defer connecting this signal to ensure this function executes
	# AFTER this signal updates the player_in_room flag in ghost.gd
	SignalBus.player_exited_room.connect(_on_player_exited_room, CONNECT_DEFERRED)
	SignalBus.player_state_changed.connect(_on_player_state_changed)


func enter() -> void:
	# guard to ensure player is in room and DEAD when entering attack state
	if not (_parent.player_in_room and PlayerHandler.get_player_state() == PlayerStateMachine.States.DEAD):
		change_state(GhostStateMachine.States.WAITING)
		return
	_parent.speed = ATTACK_SPEED


func exit() -> void:
	super()
	_parent.speed = _parent.BASE_SPEED


func process_state() -> void:
	_parent.target_pos = player.global_position


func _on_player_exited_room(room: Node3D) -> void:
	if room == _parent.current_room and not _parent.player_in_room:
		change_state(GhostStateMachine.States.WAITING)


func _on_player_state_changed(state: PlayerStateMachine.States) -> void:
	if (_state_machine.current_state == GhostStateMachine.States.ATTACKING 
		and state == PlayerStateMachine.States.LIVING):
		change_state(GhostStateMachine.States.WAITING)
