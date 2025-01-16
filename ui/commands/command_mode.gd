extends Command


func help() -> String:
	return "Usage: mode [main | debug] - changes the game mode"


func execute(args: PackedStringArray) -> String:
	if args.size() != 1:
		return help()
	if not (args[0] == "main" || args[0] == "debug"):
		return help()
	
	var debug_light: DirectionalLight3D = get_node_or_null("/root/Game/DebugLight")
	if debug_light == null:
		return "ERROR: no debug light"
	if args[0] == "main":
		debug_light.visible = false
	elif args[0] == "debug":
		debug_light.visible = true
	return "Game mode updated"
