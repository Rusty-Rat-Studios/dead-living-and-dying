extends Node3D

@export var full_sprite: Sprite3D
@export var empty_sprite: Sprite3D


func _ready() -> void:
	$PossessableRanged.max_projectiles_shot.connect(_on_max_projectliles_shot)


func _on_max_projectliles_shot() -> void:
	full_sprite.visible = false
	empty_sprite.visible = true
