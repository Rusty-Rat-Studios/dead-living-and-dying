extends Node


# Map a command definition to a Callable
var command_map: Dictionary = {
	"help": _help,
	"help %s": _help,
	"mode %s": _mode
}


func _help(args: PackedStringArray) -> String:
	if args.size() == 0:
		return "Available commands: help, mode"
	if args[0] == "help":
		return "Usage: help [cmd] - gives usage information on a specific command"
	if args[0] == "mode":
		return "Usage: mode [main | debug] - changes the game mode"
	return "Usage: help [cmd] - gives usage information on a specific command"


func _mode(args: PackedStringArray) -> String:
	if not (args[0] == "main" || args[0] == "debug"):
		return "Usage: mode [main | debug] - changes the game mode"
	if args[0] == "main":
		(get_node("/root/Game/DebugLight") as DirectionalLight3D).visible = false
	elif args[0] == "debug":
		(get_node("/root/Game/DebugLight") as DirectionalLight3D).visible = true
	return "Game mode updated"
