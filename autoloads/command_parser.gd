extends Node

# Map a command definition to a Callable
var commands: Array[Command] = [
	
]


# Takes a command string, tokenizes it, processes it, runs it, and returns a response
func handle_command(text: String) -> String:
	var tokens: PackedStringArray = _tokenize_command(text)
	return _process_command(tokens)


func _tokenize_command(text: String) -> PackedStringArray:
	return text.split(" ", false)


# Finds a command definition that matches the tokens supplied and runs the command
func _process_command(tokens: PackedStringArray) -> String:
	var matching_command: Command = null
	for command: Command in commands:
		var def_tokens: PackedStringArray = _tokenize_command(command.COMMAND_DEF)
		if def_tokens.size() == tokens.size():
			if _do_tokens_match(tokens, def_tokens):
				matching_command = command
				break
	if matching_command == null:
		return "Error: Unknown Command"
	var def_tokens: PackedStringArray = _tokenize_command(matching_command.COMMAND_DEF)
	var args: PackedStringArray = _get_args(tokens, def_tokens)
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
