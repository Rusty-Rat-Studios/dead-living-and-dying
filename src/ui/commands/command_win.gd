extends Command


func help() -> String:
	return "Usage: win - Send win signal"


func execute(args: PackedStringArray) -> String:
	if args.size() != 0:
		return help()
	SignalBus.level_complete.emit()
	return "Win signal sent"
