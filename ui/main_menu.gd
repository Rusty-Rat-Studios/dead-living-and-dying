extends Control

@export var skip_to_game: bool = false

@onready var game_scene: PackedScene = load("res://game.tscn")
@onready var buttons: VBoxContainer = $MarginContainer/MarginContainer/VBoxContainer/VBoxButtons

func _ready() -> void:
	if skip_to_game:
		start_game()
	
	buttons.get_node("ButtonStart").pressed.connect(_on_start_pressed)
	buttons.get_node("ButtonOptions").pressed.connect(_on_options_pressed)
	buttons.get_node("ButtonHow").pressed.connect(_on_how_pressed)
	buttons.get_node("ButtonQuit").pressed.connect(_on_quit_pressed)
	
	# start with "Start" button focused
	buttons.get_node("ButtonStart").grab_focus()


func start_game() -> void:
	get_tree().change_scene_to_packed(game_scene)


func _on_start_pressed() -> void:
	start_game()


func _on_options_pressed() -> void:
	pass


func _on_how_pressed() -> void:
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()
