extends InventorySlot

var _timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	# process is enabled for tracking cooldown timer progress
	set_process(false)


func _process(_delta: float) -> void:
	$ProgressBar.value = _timer.time_left


func _on_item_picked_up(item_inventory: ItemInventory) -> void:
	super(item_inventory)
	
	_item_inventory.item_used.connect(_on_item_used)


func _on_item_used(timer: Timer) -> void:
	_timer = timer
	$ProgressBar.max_value = _timer.wait_time
	
	if not _timer.timeout.is_connected(_on_cooldown_timer_timeout):
		_timer.timeout.connect(_on_cooldown_timer_timeout)
	set_process(true)


func _on_cooldown_timer_timeout() -> void:
	set_process(false)
