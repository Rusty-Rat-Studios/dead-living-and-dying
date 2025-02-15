extends PanelContainer

var _item_inventory: ItemInventory
var _timer: Timer

@onready var texture_rect: TextureRect = $TextureRect

func _ready() -> void:
	# emitted by ItemWorld when player picks up an item
	SignalBus.item_picked_up.connect(_on_item_picked_up)
	
	# process is enabled for tracking cooldown timer progress
	set_process(false)


func _process(_delta: float) -> void:
	$ProgressBar.value = _timer.time_left


func _on_item_picked_up(item_inventory: ItemInventory) -> void:
	_item_inventory = item_inventory
	# update UI image to match item
	texture_rect.texture = _item_inventory.texture
	
	_item_inventory.item_used.connect(_on_item_used)


func _on_item_used(timer: Timer) -> void:
	_timer = timer
	$ProgressBar.max_value = _timer.wait_time
	_timer.timeout.connect(_on_cooldown_timer_timeout)
	set_process(true)


func _on_cooldown_timer_timeout() -> void:
	set_process(false)
