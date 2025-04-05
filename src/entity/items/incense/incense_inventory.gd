extends ConsumableItemInventory

const CONSUMABLE_ID: int = 1
const STUN_MODIFER: float = 3
const BASE_ACTIVE_DURATION: float = 6
const MAX_COUNT: float = 3

var active: bool = false

func _ready() -> void:
	world_resource = load("res://src/entity/items/incense/incense_world.tscn")
	display_name = "Incense"
	input_event = "use_consumable_item"
	description = ("CONSUMABLE ITEM: Use with " + UIDevice.retrieve_icon_sized(input_event)
		+ " Stun all ghosts regardless of where they are.")
	texture = preload("res://src/entity/items/incense/incense.png")
	$FireParticles.emitting = false
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
	SignalBus.hit.emit(STUN_MODIFER, display_name)
	$FireParticles.emitting = true
	$ActiveTimer.start()
	active = true
	count -= 1
	item_used.emit()
	if (count <= 0):
		queue_free()


func _on_active_timer_timeout() -> void:
	active = false
	$FireParticles.emitting = false
