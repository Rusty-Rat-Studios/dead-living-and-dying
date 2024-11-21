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


func input_get_vector(x_neg: StringName, x_pos: StringName, 
					y_neg: StringName, y_pos: StringName) -> Vector2:
	if focused:
		return Input.get_vector(x_neg, x_pos, y_neg, y_pos)
	
	return Vector2.ZERO
