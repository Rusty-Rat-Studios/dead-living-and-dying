extends Node

# Map a command definition to a Callable
@onready var commands: Dictionary = {
	"help": preload("res://ui/commands/command_help.gd").new(),
	"mode": preload("res://ui/commands/command_mode.gd").new(),
	"reset": preload("res://ui/commands/command_reset.gd").new(),
}


func _ready() -> void:
	# load the command nodes into the scene tree as children of CommandParser
	# this allows them to reference the scene tree
	for command: Command in commands.values():
		add_child(command)


func get_command_defs() -> PackedStringArray:
	return commands.keys()


# Takes a command string, tokenizes it, processes it, runs it, and returns a response
func handle_command(text: String) -> String:
	var tokens: PackedStringArray = _tokenize_command(text)
	var matching_command: Command = find_command(tokens)
	if matching_command == null:
		return "Error: Unknown Command"
	return matching_command.execute(tokens.slice(1))


func _tokenize_command(text: String) -> PackedStringArray:
	return text.split(" ", false)


func find_command(tokens: PackedStringArray) -> Command:
	if tokens.size() == 0:
		return null
	for command_def: String in commands.keys():
		if tokens[0] == command_def:
			return commands.get(command_def)
	return null
