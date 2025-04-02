class_name CooldownSlot
extends InventorySlot

var _cooldown_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	# process is enabled for tracking cooldown timer progress
	set_process(false)


func _process(_delta: float) -> void:
	if is_instance_valid(_cooldown_timer):
		$ProgressBar.value = _cooldown_timer.time_left
	else:
		refresh()


func _on_item_used(timer: Timer) -> void:
	_cooldown_timer = timer
	$ProgressBar.max_value = _cooldown_timer.wait_time
	
	if not _cooldown_timer.timeout.is_connected(_on_cooldown_timer_timeout):
		_cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	set_process(true)


func refresh() -> void:
	set_process(false)
	$ProgressBar.value = $ProgressBar.min_value


func _on_cooldown_timer_timeout() -> void:
	set_process(false)
