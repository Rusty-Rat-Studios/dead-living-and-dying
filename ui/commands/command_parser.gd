class_name CommandParser extends Node


# Takes a command string, tokenizes it, processes it, runs it, and returns a response
static func handle_command(text: String) -> String:
	var tokens: PackedStringArray = _tokenize_command(text)
	return _process_command(tokens)


static func _tokenize_command(text: String) -> PackedStringArray:
	return text.split(" ", false)


# Finds a command definition that matches the tokens supplied and runs the command
static func _process_command(tokens: PackedStringArray) -> String:
	var matching_def: String = ""
	for command_definition: String in Commands.command_map:
		var def_tokens: PackedStringArray = _tokenize_command(command_definition)
		if def_tokens.size() == tokens.size():
			if _do_tokens_match(tokens, def_tokens):
				matching_def = command_definition
				break
	if matching_def == "":
		return "Error: Unknown Command"
	var def_tokens: PackedStringArray = _tokenize_command(matching_def)
	var args: PackedStringArray = _get_args(tokens, def_tokens)
	return Commands.command_map.get(matching_def).call(args)


# Precondition: PackedStringArrays are the same size
# Returns true if the 2 arrays are the same (where '%s' for a def_token is a wildcard)
static func _do_tokens_match(tokens: PackedStringArray, def_tokens: PackedStringArray) -> bool:
	for i: int in range(tokens.size()):
		if(def_tokens[i] != "%s"):
			if(tokens[i] != def_tokens[i]):
				return false
	return true


# Precondition: PackedStringArrays are the same size
# Returns a PackedStringArray of all the tokens in tokens where there is a '%s' in def_tokens
static func _get_args(tokens: PackedStringArray, def_tokens: PackedStringArray) -> PackedStringArray:
	var args: Array[String] = []
	for i: int in range(tokens.size()):
		if(def_tokens[i] == "%s"):
			args.push_back(tokens[i])
	return PackedStringArray(args)
