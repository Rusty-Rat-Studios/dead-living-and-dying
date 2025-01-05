class_name Commands extends Node


# Map a command definition to a Callable
static var command_map: Dictionary = {
	"help": _help,
	"help %s": _help,
	"mode %s": _mode
}


static func _help(args: PackedStringArray) -> String:
	if args.size() == 0:
		return "Available commands: help, mode"
	if args[0] == "help":
		return "Usage: help [cmd] - gives usage information on a specific command"
	if args[0] == "mode":
		return "Usage: mode [main | debug] - changes the game mode"
	return "Usage: help [cmd] - gives usage information on a specific command"


static func _mode(args: PackedStringArray) -> String:
	if not (args[0] == "main" || args[0] == "debug"):
		return "Usage: mode [main | debug] - changes the game mode"
	return "Game mode updated"
