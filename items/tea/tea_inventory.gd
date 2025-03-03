extends PassiveItemInventory


var speed_modifier: float = 4.0

func _ready() -> void:
	update()


func update() -> void:
	var player: Node = PlayerHandler.get_player()
	player.stat_update_add(player.current_stats.stat_modifier_speed, speed_modifier, "tea")
