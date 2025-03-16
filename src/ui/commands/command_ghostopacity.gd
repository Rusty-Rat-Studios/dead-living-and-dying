extends Command


func help() -> String:
	return "Usage: ghostopacity [opacity] - Sets the ghost opacity to opacity or returns the current opacity"


func execute(args: PackedStringArray) -> String:
	if args.size() > 1:
		return help()
		
	var ghosts: Array[Node] = get_tree().get_nodes_in_group("ghosts")
	if ghosts.is_empty():
		return "There are no ghosts in the current scene"
	
	if args.size() == 0:
		var opacity: float = ghosts[0].sprite.modulate.a
		return "The current ghost opacity is %s" % [str(opacity)]
	
	if not args[0].is_valid_float():
		return "Error: argument opacity must be a valid float"
		
	var opacity: float = args[0].to_float()
	if opacity < 0 or opacity > 1:
		return "Error: argument opacity must be 0-1.0 (inclusive)"
	
	for ghost: Ghost in ghosts:
		ghost.sprite.modulate.a = opacity
	return "Ghost opacity updated"
