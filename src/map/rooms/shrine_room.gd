class_name ShrineRoom
extends Room



func _on_player_entered_room(body: Node3D) -> void:
	super(body)
	
	body.footsteps_sfx.stream = body.footsteps_sfx.FOOTSTEPS_GRASS
	body.footsteps_sfx.play()


func _on_player_exited_room(body: Node3D) -> void:
	super(body)
	
	body.footsteps_sfx.stream = body.footsteps_sfx.FOOTSTEPS_WOOD
	body.footsteps_sfx.play()
