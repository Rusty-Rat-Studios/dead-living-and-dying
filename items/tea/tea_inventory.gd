extends PassiveItemInventory


var speed_modifier: float = 1.3

func _ready() -> void:
	update()


func update() -> void:
	var player: Node = PlayerHandler.get_player()
	player.stat_update(player.Stats.SPEED, speed_modifier)
