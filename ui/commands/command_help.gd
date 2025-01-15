extends Command

func _ready() -> void:
	command_def = "help"


func help() -> String:
	return "Usage: help [cmd] - gives usage information on a specific command"


func execute(args: PackedStringArray) -> String:
	if args.size() == 0:
		var command_defs: PackedStringArray = CommandParser.get_command_defs()
		return "Available commands: %s" % [", ".join(command_defs)]
	
	var command: Command = CommandParser.find_command(args)
	if command:
		return command.help()
	else:
		return help()
