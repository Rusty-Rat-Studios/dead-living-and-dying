extends Node

# Map a command definition to a Callable
@onready var commands: Array[Command] = [
	preload("res://ui/commands/command_help.gd").new(),
	preload("res://ui/commands/command_mode.gd").new(),
	preload("res://ui/commands/command_reset.gd").new()
]


func get_command_defs() -> PackedStringArray:
	return []


func find_command(tokens: PackedStringArray) -> Command:
	return null


# Takes a command string, tokenizes it, processes it, runs it, and returns a response
func handle_command(text: String) -> String:
	var tokens: PackedStringArray = _tokenize_command(text)
	return _process_command(tokens)


func _tokenize_command(text: String) -> PackedStringArray:
	return text.split(" ", false)


# Finds a command definition that matches the tokens supplied and runs the command
func _process_command(tokens: PackedStringArray) -> String:
	var matching_command: Command = find_command(tokens)
	if matching_command == null:
		return "Error: Unknown Command"
	var args: PackedStringArray = _extract_args(tokens, matching_command)
	return matching_command.execute(args)


# Precondition: PackedStringArrays are the same size
# Returns true if the 2 arrays are the same (where '%s' for a def_token is a wildcard)
func _do_tokens_match(tokens: PackedStringArray, def_tokens: PackedStringArray) -> bool:
	for i: int in range(tokens.size()):
		if(def_tokens[i] != "%s"):
			if(tokens[i] != def_tokens[i]):
				return false
	return true


# Precondition: PackedStringArrays are the same size
# Returns a PackedStringArray of all the tokens in tokens where there is a '%s' in def_tokens
func _get_args(tokens: PackedStringArray, def_tokens: PackedStringArray) -> PackedStringArray:
	var args: Array[String] = []
	for i: int in range(tokens.size()):
		if(def_tokens[i] == "%s"):
			args.push_back(tokens[i])
	return PackedStringArray(args)
