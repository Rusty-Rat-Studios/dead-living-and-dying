extends Area3D

const SPEED_MODIFIER: float = 0.8
const LIGHT_MODIFIER: float = 0.5

var _player: Player = PlayerHandler.get_player()

@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	area_entered.connect(_on_enemy_area_entered)


func stun() -> void:
	print("stunned!")


func _on_enemy_area_entered(_body: Node3D) -> void:
	stun()
