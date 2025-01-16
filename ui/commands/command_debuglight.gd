extends Command


func help() -> String:
	return "Usage: debuglight [enable | disable] - Enables or disables the DebugLight"


func execute(args: PackedStringArray) -> String:
	if args.size() != 1:
		return help()
	if not (args[0] == "enable" || args[0] == "disable"):
		return help()
	
	var debug_light: DirectionalLight3D = get_node_or_null("/root/Game/DebugLight")
	if debug_light == null:
		return "ERROR: no debug light in scene"
	if args[0] == "disable":
		debug_light.visible = false
	elif args[0] == "enable":
		debug_light.visible = true
	return "Game mode updated"
