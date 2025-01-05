class_name Commands extends Node


# Map a command definition to a Callable
static var command_map: Dictionary = {
	"help": help,
	"help %s": help,
	"mode %s": mode
}

static func unknown_cmd() -> String:
	return "Error: Unknown Command"

# Put command callables below this line


static func help(args: PackedStringArray) -> String:
	if args.size() == 0:
		return "Available commands: help, mode"
	if args[0] == "help":
		return "Usage: help [cmd] - gives usage information on a specific command"
	if args[0] == "mode":
		return "Usage: mode [main | debug] - changes the game mode"
	return "Usage: help [cmd] - gives usage information on a specific command"


static func mode(args: PackedStringArray) -> String:
	if args.size() != 1:
		return "Usage: mode [main | debug] - changes the game mode"
	if not (args[0] == "main" || args[0] == "debug"):
		return "Usage: mode [main | debug] - changes the game mode"
	return "Game mode updated"
