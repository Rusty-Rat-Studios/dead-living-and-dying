extends Control

@export var skip_to_game: bool = false

@onready var how_to_scene: PackedScene = load("res://src/ui/menus/how_to_play.tscn")
@onready var buttons: VBoxContainer = $MarginContainer/MarginContainer/VBoxContainer/VBoxButtons

func _ready() -> void:
	# main menu border clips if squished too small left-right
	# disallow resizing window under a given limit
	DisplayServer.window_set_min_size(Vector2i(800, 600))
	
	if skip_to_game:
		# use call deferred to wait until scene tree finishes constructing to avoid error
		call_deferred("start_game")
		return
	
	buttons.get_node("ButtonStart").pressed.connect(_on_start_pressed)
	buttons.get_node("ButtonOptions").pressed.connect(_on_options_pressed)
	buttons.get_node("ButtonHow").pressed.connect(_on_how_pressed)
	buttons.get_node("ButtonQuit").pressed.connect(_on_quit_pressed)
	
	# start with "Start" button focused
	buttons.get_node("ButtonStart").grab_focus()


func start_game() -> void:
	get_tree().change_scene_to_packed(load("res://test/grid_test.tscn"))


func _on_start_pressed() -> void:
	start_game()


func _on_options_pressed() -> void:
	$OptionsMenu.show()


func _on_how_pressed() -> void:
	$HowToPlay.show()


func _on_quit_pressed() -> void:
	get_tree().quit()
