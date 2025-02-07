extends Command


func help() -> String:
	return "Usage: debuglight [0 | 1] - Enables or disables the DebugLight"


func execute(args: PackedStringArray) -> String:
	if args.size() != 1:
		return help()
	if not (args[0] == "1" || args[0] == "0"):
		return help()
	
	var debug_light: DirectionalLight3D = get_node_or_null("/root/Game/DebugLight")
	if debug_light == null:
		return "ERROR: no debug light in scene"
	if args[0] == "0":
		debug_light.visible = false
	elif args[0] == "1":
		debug_light.visible = true
	return "Light updated"
