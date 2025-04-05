extends Control

const SCENE_SWITCH_DELAY: float = 2
const FADE_IN_TIME: float = 2

var fade_in: Tween

@onready var scene_switch_timer: Timer = Timer.new()
@onready var main_menu_scene: PackedScene = load("res://src/ui/menus/main_menu.tscn")


func _ready() -> void:
	visible = false
	modulate.a = 0
	
	scene_switch_timer.wait_time = SCENE_SWITCH_DELAY
	add_child(scene_switch_timer)
	scene_switch_timer.timeout.connect(_on_scene_switch_timeout)
	
	SignalBus.game_over.connect(_on_game_over)


func _on_game_over() -> void:
	visible = true
	fade_in = create_tween()
	fade_in.tween_property(self, "modulate:a", 1, FADE_IN_TIME)
	await fade_in.finished
	scene_switch_timer.start()


func _on_scene_switch_timeout() -> void:
	SpawnerManager.reset()
	ShrineManager.clear_shrines_list(true)
	get_tree().call_deferred("change_scene_to_packed", main_menu_scene)
