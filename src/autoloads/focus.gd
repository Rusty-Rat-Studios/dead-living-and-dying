extends Node

var focused: bool = true

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			focused = false
		NOTIFICATION_APPLICATION_FOCUS_IN:
			focused = true


func input_is_action_pressed(action: StringName) -> bool:
	if focused:
		return Input.is_action_pressed(action)
	
	return false


func event_is_action_pressed(event: InputEvent, action: StringName) -> bool:
	if focused:
		return event.is_action_pressed(action)
	
	return false


func input_get_vector(left: StringName, right: StringName, 
					up: StringName, down: StringName) -> Vector2:
	if focused:
		return Input.get_vector(left, right, up, down)
	
	return Vector2.ZERO
