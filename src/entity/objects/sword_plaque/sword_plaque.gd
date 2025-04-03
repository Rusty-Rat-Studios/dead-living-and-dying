extends Node3D

@export var with_sword_sprite: Sprite3D
@export var blank_sprite: Sprite3D


func _ready() -> void:
	$PossessableRanged.projectile_shot.connect(_on_projectile_shot)


func _on_projectile_shot() -> void:
	with_sword_sprite.visible = false
	blank_sprite.visible = true
