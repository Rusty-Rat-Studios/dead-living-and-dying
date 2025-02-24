extends GhostState

const ATTACK_SPEED: float = 6.0


func enter() -> void:
	# ensure player is in a place/state to be attacked
	if not is_player_attackable():
		change_state(GhostStateMachine.States.WAITING)
		return
	_parent.speed = ATTACK_SPEED
	_parent.sprite.animation = "active"
	# reset at_target flag to handle case where previous state reached target
	# since this flag is used to detect when to exit ATTACKING state
	_parent.at_target = false
	
	# defer connecting this signal to ensure this function executes
	# AFTER this signal updates the player_in_room flag in ghost.gd
	SignalBus.player_exited_room.connect(_on_player_exited_room, CONNECT_DEFERRED)
	SignalBus.player_state_changed.connect(_on_player_state_changed)


func is_player_attackable() -> bool:
	# check if player is in room and DYING or DEAD when entering attack state
	if (_parent.player_in_room
		and (PlayerHandler.get_player_state() == PlayerStateMachine.States.DEAD
			or PlayerHandler.get_player_state() == PlayerStateMachine.States.DYING)):
		return true
	return false


func exit() -> void:
	super()
	_parent.speed = _parent.BASE_SPEED
	
	SignalBus.player_exited_room.disconnect(_on_player_exited_room)
	SignalBus.player_state_changed.disconnect(_on_player_state_changed)


func process_state() -> void:
	_parent.set_target(PlayerHandler.get_player().global_position)
	if _parent.at_target:
		change_state(GhostStateMachine.States.WAITING)


func _on_player_exited_room(room: Node3D) -> void:
	if room == _parent.current_room and not _parent.player_in_room:
		change_state(GhostStateMachine.States.WAITING)


func _on_player_state_changed(state: PlayerStateMachine.States) -> void:
	if (_state_machine.current_state == GhostStateMachine.States.ATTACKING 
		and state == PlayerStateMachine.States.LIVING):
		change_state(GhostStateMachine.States.WAITING)
