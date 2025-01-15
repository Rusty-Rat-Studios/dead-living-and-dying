class_name Command
extends Node

const COMMAND_DEF: String = ""


func help() -> String:
	push_error("AbstractMethodError: abstract function Command.help() called")
	return ""


func execute(_args: PackedStringArray) -> String:
	push_error("AbstractMethodError: abstract function Command.execute() called")
	return ""
