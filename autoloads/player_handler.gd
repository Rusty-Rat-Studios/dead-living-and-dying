extends Node

@onready var player: Player = get_node("/root/Game/Player")


# globally access to Player node
func get_player() -> Player:
	return player
