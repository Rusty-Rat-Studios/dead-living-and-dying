extends PassiveItemInventory

const SPEED_MODIFIER: float = 4.0


func _ready() -> void:
	update()


func update() -> void:
	var player: Node = PlayerHandler.get_player()
	
	player.current_stats.stat_update_add(PlayerStats.Stats.SPEED, SPEED_MODIFIER, "tea")
