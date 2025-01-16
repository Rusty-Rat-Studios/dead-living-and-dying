extends Game


func _on_player_state_changed(state_name: String) -> void:
	print(Time.get_time_string_from_system(), ": State entered: ", state_name)
	match state_name:
		"Living":
			player.light_omni.visible = true
			player.light_spot.visible = true
		"Dying":
			player.light_omni.visible = true
			player.light_spot.visible = true
		"Dead":
			player.light_omni.visible = false
			player.light_spot.visible = false
	
	# TEMPORARY
	update_ghost_visibility(state_name)
