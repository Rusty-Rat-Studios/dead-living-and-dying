extends Control

# time that the game waits before continuing on game over
const GAME_OVER_DELAY: float = 2.0

@export var disable_start_menu: bool = false

var scene: PackedScene

func _ready() -> void:
	scene = preload("res://game.tscn")
	$VBoxContainer/Start.pressed.connect(_on_start_pressed)
	$VBoxContainer/Quit.pressed.connect(_on_quit_pressed)
	SignalBus.game_over.connect(_on_game_over)
	if not disable_start_menu:
		pause()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_visible():
			resume()
		else:
			pause()


func resume() -> void:
	hide()
	$VBoxContainer/Start.text = "RESUME"
	get_tree().paused = false


func pause() -> void:
	show()
	get_tree().paused = true
	$VBoxContainer/Start.grab_focus()


func _on_start_pressed() -> void:
	resume()


func _on_quit_pressed() -> void:
	# close the application
	get_tree().quit()


func _on_game_over() -> void:
	pause()
	$VBoxContainer.hide()
	$Message.text = "Game Over"
	await Utility.delay(GAME_OVER_DELAY)
	$VBoxContainer.show()
	$Message.text = ""
	$VBoxContainer/Start.text = "START"
	
	get_node("/root/Game").reset()
	
	if disable_start_menu:
		resume()
