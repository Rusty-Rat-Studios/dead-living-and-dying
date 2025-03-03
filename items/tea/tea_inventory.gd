extends PassiveItemInventory


var speed_modifier: float = 4.0

func _ready() -> void:
	update()


func update() -> void:
	var player: Node = PlayerHandler.get_player()
	player.stat_update(player.player_stats.Stats.SPEED, speed_modifier)
