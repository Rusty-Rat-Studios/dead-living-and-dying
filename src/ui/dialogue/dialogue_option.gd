class_name DialogueOption
extends Button


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)


func _on_mouse_entered() -> void:
	grab_focus()
