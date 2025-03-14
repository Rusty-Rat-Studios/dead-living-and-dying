extends Control

# time that the game waits before continuing on game over
const GAME_OVER_DELAY: float = 2.0

@export var disable_popup: bool = false
@export var show_how_to_play_on_start: bool = false

@onready var buttons: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/VBoxButtons
@onready var message: Label = $PanelContainer/MarginContainer/VBoxContainer/Message

func _ready() -> void:
	if show_how_to_play_on_start:
		get_tree().paused = true
		$HowToPlay.visible = true
		# resume game when popup window is closed
		# needed because it can be closed by clicking "Exit" or clicking outside the window
		$HowToPlay.button_exit.pressed.connect(func() -> void: resume(), CONNECT_ONE_SHOT)
	
	buttons.get_node("ButtonContinue").pressed.connect(_on_continue_pressed)
	buttons.get_node("ButtonHow").pressed.connect(_on_how_pressed)
	buttons.get_node("ButtonQuit").pressed.connect(_on_quit_pressed)
	SignalBus.game_over.connect(_on_game_over)
	SignalBus.level_complete.connect(_on_level_complete)


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


func _on_how_pressed() -> void:
	$HowToPlay.show()


func _on_quit_pressed() -> void:
	# close the application
	get_tree().quit()


func _on_game_over() -> void:
	if not disable_popup:
		pause()
		buttons.hide()
		message.text = "Game Over"
		message.show()
		await Utility.delay(GAME_OVER_DELAY)
		message.hide()
		message.text = ""
		buttons.show()
		resume()
	
	get_node("/root/Game").reset()


func _on_level_complete() -> void:
	if not disable_popup:
		pause()
		buttons.hide()
		message.text = "Level Complete!"
		message.show()
		await Utility.delay(GAME_OVER_DELAY)
		message.hide()
		message.text = ""
		buttons.show()
		resume()
	
	get_node("/root/Game").reset()
