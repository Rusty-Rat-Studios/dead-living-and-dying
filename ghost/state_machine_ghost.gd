extends StateMachine


func init(parent: Node3D) -> void:
	super(parent)
	
	# listen for player state change
	SignalBus.player_state_changed.connect(_on_player_state_changed)


func _on_player_state_changed(state_name: String) -> void:
	match state_name:
		"Dead":
			if get_parent().player_in_room:
				change_state($Attacking)
		"Living":
			change_state($Waiting)
