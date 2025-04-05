extends Control

@export var disable_popup: bool = false
@export var show_how_to_play_on_start: bool = false

@onready var buttons: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/VBoxButtons
@onready var message: Label = $PanelContainer/MarginContainer/VBoxContainer/Message


func _ready() -> void:
	if show_how_to_play_on_start:
		get_tree().paused = true
		$HowToPlay.visible = true
		# resume game when popup window is closed
		$HowToPlay.close_requested.connect(func() -> void: resume(), CONNECT_ONE_SHOT)
	
	buttons.get_node("ButtonContinue").pressed.connect(_on_continue_pressed)
	buttons.get_node("ButtonOptions").pressed.connect(_on_options_pressed)
	buttons.get_node("ButtonHow").pressed.connect(_on_how_pressed)
	buttons.get_node("ButtonQuit").pressed.connect(_on_quit_pressed)
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


func _on_options_pressed() -> void:
	$OptionsMenu.show()


func _on_how_pressed() -> void:
	$HowToPlay.show()


func _on_quit_pressed() -> void:
	# close the application
	get_tree().quit()


func _on_level_complete() -> void:
	print("Level complete!")
