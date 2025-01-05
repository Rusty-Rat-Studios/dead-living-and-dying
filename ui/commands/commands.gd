class_name Commands extends Node


# map a command definition to a Callable
static var command_map: Dictionary = {
	"help": help,
	"help %s": help,
	"mode %s": mode
}

static func unknown_cmd() -> String:
	return "Error: Unknown Command"

# Put command callables below this line


static func help(args: PackedStringArray) -> String:
	return ""


static func mode(args: PackedStringArray) -> String:
	return ""
