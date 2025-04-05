extends Window

@onready var button_close: Button = $MarginContainer/CenterContainer/MarginContainer/VBoxContainer/Button


func _ready() -> void:
	button_close.pressed.connect(_on_close_pressed)


func _on_close_pressed() -> void:
	hide()
