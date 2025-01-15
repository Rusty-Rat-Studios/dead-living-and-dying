extends Command


func help() -> String:
	return "Usage: mode [main | debug] - changes the game mode"


func execute(args: PackedStringArray) -> String:
	if args.size() != 1:
		return help()
	if not (args[0] == "main" || args[0] == "debug"):
		return help()
	if args[0] == "main":
		(get_node("/root/Game/DebugLight") as DirectionalLight3D).visible = false
	elif args[0] == "debug":
		(get_node("/root/Game/DebugLight") as DirectionalLight3D).visible = true
	return "Game mode updated"
