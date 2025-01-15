class_name Command
extends Node


func help() -> String:
	push_error("AbstractMethodError: abstract function Command.help() called")
	return ""


func execute(_args: PackedStringArray) -> String:
	push_error("AbstractMethodError: abstract function Command.execute() called")
	return ""
