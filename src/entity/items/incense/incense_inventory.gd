extends ConsumableItemInventory

const CONSUMABLE_ID: int = 1
const STUN_MODIFER: float = 3
const MAX_COUNT: float = 3

func _ready() -> void:
	world_resource = load("res://src/entity/items/incense/incense_world.tscn")
	display_name = "Incense"
	input_event = "use_consumable_item"
	description = ("CONSUMABLE ITEM: Use with " + UIDevice.retrieve_icon_sized(input_event)
		+ " Stun all ghosts regardless of where they are.")
	texture = preload("res://src/entity/items/incense/incense.png")


func _unhandled_input(event: InputEvent) -> void:
	if PlayerHandler.get_player_state() == PlayerStateMachine.States.DEAD:
		return
	if event.is_action_pressed("use_consumable_item"):
		use()


func use() -> void:
	SignalBus.hit.emit(STUN_MODIFER, display_name)
	count -= 1
	item_used.emit()
