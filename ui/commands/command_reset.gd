extends Command

func _ready() -> void:
	command_def = "reset"


func help() -> String:
	return "Usage: reset - Resets the game by calling Game.reset()"


func execute(args: PackedStringArray) -> String:
	if args.size() > 0:
		return help()
	get_node("/root/Game").reset()
	return "Game Reset"
