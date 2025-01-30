extends PassiveItemInventory


signal speedmod
var speed_modifier: float = 4.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player: Node = PlayerHandler.get_player()
	player.stat_update(speed_modifier, 0)
