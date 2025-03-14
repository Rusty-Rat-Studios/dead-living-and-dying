extends MarginContainer

const LIFETIME: float = 8

const COLOR_BG: Color = Color(0.13, 0.13, 0.13, 1)
const COLOR_BG_HOVER: Color = Color(0.2, 0.2, 0.2, 1)

@onready var image: TextureRect = $MarginContainer/HBoxContainer/TextureRect
@onready var title: Label = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/Title
@onready var description: Label = $MarginContainer/HBoxContainer/VBoxContainer/Description

@onready var _timer: Timer = $Timer
@onready var _progress: ProgressBar = $NinePatchRect/MarginContainer/ProgressBar


func _ready() -> void:
	visible = false
	
	_progress.max_value = LIFETIME
	_timer.wait_time = LIFETIME
	_timer.timeout.connect(_on_lifetime_expired)
	
	SignalBus.item_picked_up.connect(_on_item_picked_up)
	
	# mouse hovering/exit pause and resume timer
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _process(_delta: float) -> void:
	_progress.value = _timer.time_left


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_item()


func show_item(item: ItemInventory) -> void:
	visible = true
	image.texture = item.texture
	title.text = item.display_name
	description.text = item.description


func hide_item() -> void:
	visible = false


func _on_lifetime_expired() -> void:
	hide_item()


func _on_item_picked_up(item: ItemInventory, current_consumable: bool = false) -> void:
	show_item(item)
	_timer.start()


func _on_mouse_entered() -> void:
	_timer.paused = true
	$ColorRect.color = COLOR_BG_HOVER


func _on_mouse_exited() -> void:
	_timer.paused = false
	$ColorRect.color = COLOR_BG
