extends PassiveItemInventory

const LIGHT_MODIFIER: float = 2.0
const NAME: String = "carrot"


func _ready() -> void:
	display_name = "carrot"
	description = "PASSIVE ITEM: Increases your base light radius. Tasty!"
	texture = preload("res://src/entity/items/carrot/carrot.png")
	update()


func update() -> void:
	var player: Node = PlayerHandler.get_player()
	player.player_stats.stat_update_add(PlayerStats.Stats.LIGHT_OMNI_RANGE, LIGHT_MODIFIER, NAME, self.get_instance_id())
	player.player_stats.stat_update_add(PlayerStats.Stats.LIGHT_SPOT_RANGE, LIGHT_MODIFIER, NAME, self.get_instance_id())
