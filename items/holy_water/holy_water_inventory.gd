extends ConsumableItemInventory

const BASE_ACTIVE_DURATION: float = 3
const CONSUMABLE_ID: int = 0

var player: Node = PlayerHandler.get_player()
var active: bool = false

@onready var cooldown_active: bool = false


func _ready() -> void:
	world_resource = preload("res://items/holy_water/holy_water_world.tscn")
	display_name = "Holy Water"
	description = "CONSUMABLE ITEM: Use with Q to become invulnerable for a short duration."
	texture = preload("res://items/holy_water/holy_water.png")
	count = 1
	
	$ActiveTimer.wait_time = BASE_ACTIVE_DURATION
	$ActiveTimer.timeout.connect(_on_active_timer_timeout)
	


func _unhandled_input(event: InputEvent) -> void:
	if PlayerHandler.get_player_state() == PlayerStateMachine.States.DEAD:
		return
	if event.is_action_pressed("use_consumable_item"):
		use()


func use() -> void:
	if active:
		return
	player.hurtbox.activate_invulnerability($ActiveTimer.wait_time)
	active = true
	count -= 1
	$ActiveTimer.wait_time = BASE_ACTIVE_DURATION * player.player_stats.duration
	$ActiveTimer.start()
	item_used.emit()


func _on_active_timer_timeout() -> void:
	active = false
	if (count <= 0):
		queue_free()
