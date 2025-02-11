extends Control

# time that the game waits before continuing on game over
const GAME_OVER_DELAY: float = 2.0

@export var disable_popup: bool = false

@onready var scene: PackedScene = preload("res://game.tscn")

@onready var buttons: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/VBoxButtons
@onready var message: Label = $PanelContainer/MarginContainer/VBoxContainer/Message

func _ready() -> void:
	buttons.get_node("ButtonContinue").pressed.connect(_on_continue_pressed)
	buttons.get_node("ButtonQuit").pressed.connect(_on_quit_pressed)
	SignalBus.game_over.connect(_on_game_over)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_visible():
			resume()
		else:
			pause()


func resume() -> void:
	hide()
	get_tree().paused = false


func pause() -> void:
	show()
	get_tree().paused = true
	buttons.get_node("ButtonContinue").grab_focus()


func _on_continue_pressed() -> void:
	resume()


func _on_quit_pressed() -> void:
	# close the application
	get_tree().quit()


func _on_game_over() -> void:
	if not disable_popup:
		pause()
		buttons.hide()
		message.show()
		message.text = "Game Over"
		await Utility.delay(GAME_OVER_DELAY)
		buttons.show()
		message.hide()
		message.text = ""
		resume()
	
	get_node("/root/Game").reset()
	
