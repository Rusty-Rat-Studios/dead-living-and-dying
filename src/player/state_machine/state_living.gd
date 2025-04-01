extends PlayerState


func enter() -> void:
	super()
	
	_parent.sprite.animation = "living"

	# apply inventory buffs to modified stats
	_parent.inventory_update()
	
	SignalBus.player_hurt.connect(_on_player_hurt)


func exit() -> void:
	SignalBus.player_hurt.disconnect(_on_player_hurt)


func process_state() -> void:
	pass


func _on_player_hurt(_entity: Node3D) -> void:
	_parent.take_damage()
	_state_machine.change_state(PlayerStateMachine.States.DYING)
