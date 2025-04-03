extends Node3D

@export var shoot_amount: int = 1
@export var with_sword_sprite: Sprite3D
@export var blank_sprite: Sprite3D

var amount: int = 0


func _ready() -> void:
	$PossessableRanged.projectile_shot.connect(_on_projectile_shot)


func _on_projectile_shot() -> void:
	amount += 1
	if amount >= shoot_amount:
		with_sword_sprite.visible = false
		blank_sprite.visible = true
