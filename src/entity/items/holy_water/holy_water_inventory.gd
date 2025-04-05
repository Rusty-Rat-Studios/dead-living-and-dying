extends ConsumableItemInventory

const BASE_ACTIVE_DURATION: float = 3
const CONSUMABLE_ID: int = 0
const MAX_COUNT: float = 3

var player: Node = PlayerHandler.get_player()
var active: bool = false

func _ready() -> void:
	world_resource = load("res://src/entity/items/holy_water/holy_water_world.tscn")
	display_name = "Holy Water"
	input_event = "use_consumable_item"
	description = ("CONSUMABLE ITEM: Use with " + UIDevice.retrieve_icon_sized(input_event)
		+ " to become invulnerable for a short duration.")
	texture = preload("res://src/entity/items/holy_water/holy_water.png")
	
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
	$ActiveTimer.wait_time = BASE_ACTIVE_DURATION * player.player_stats.duration
	$ActiveTimer.start()
	player.hurtbox.activate_hit_cooldown(true, $ActiveTimer.wait_time)
	active = true
	count -= 1
	item_used.emit()
	if (count <= 0):
		queue_free()


func _on_active_timer_timeout() -> void:
	active = false
