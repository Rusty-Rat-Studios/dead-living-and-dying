extends PassiveItemInventory

const AREA_MODIFIER: float = 0.2
const NAME: String = "rosary"


func _ready() -> void:
	display_name = "Rosary"
	description = "PASSIVE ITEM: Increases your item area size."
	texture = preload("res://src/entity/items/rosary/rosary.png")
	update()


func update() -> void:
	var player: Node = PlayerHandler.get_player()
	player.player_stats.stat_update_add(PlayerStats.Stats.AREA_SIZE, AREA_MODIFIER, NAME, self.get_instance_id())
