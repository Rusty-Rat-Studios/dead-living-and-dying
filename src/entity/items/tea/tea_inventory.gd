extends PassiveItemInventory

const SPEED_MODIFIER: float = 0.65
const NAME: String = "tea"


func _ready() -> void:
	display_name = "Tea"
	description = "PASSIVE ITEM: Increases your base speed. Refreshing!"
	texture = preload("res://src/entity/items/tea/tea.png")
	update()


func update() -> void:
	var player: Node = PlayerHandler.get_player()
	player.player_stats.stat_update_add(PlayerStats.Stats.SPEED, SPEED_MODIFIER, NAME, self.get_instance_id())
