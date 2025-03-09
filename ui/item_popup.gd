extends MarginContainer

const LIFETIME: float = 5

@onready var image: TextureRect = $MarginContainer/MarginContainer/HBoxContainer/TextureRect
@onready var title: Label = $MarginContainer/MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/Title
@onready var description: Label = $MarginContainer/MarginContainer/HBoxContainer/VBoxContainer/Description

@onready var _timer: Timer = $Timer
@onready var _progress: ProgressBar = $ProgressBar


func _ready() -> void:
	visible = false
	
	$ProgressBar.max_value = LIFETIME
	_timer.wait_time = LIFETIME
	_timer.timeout.connect(_on_lifetime_expired)
	
	SignalBus.item_picked_up.connect(_on_item_picked_up)
	
	# mouse hovering/exit pause and resume timer
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _process(_delta: float) -> void:
	_progress.value = _timer.time_left


func _input(event: InputEvent) -> void:
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


func _on_item_picked_up(item: ItemInventory) -> void:
	show_item(item)
	_timer.start()


func _on_mouse_entered() -> void:
	_timer.paused = true


func _on_mouse_exited() -> void:
	_timer.paused = false
