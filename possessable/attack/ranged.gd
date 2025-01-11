extends PossessableAttack

@onready var projectile_scene: PackedScene = preload("res://possessable/attack/projectile.tscn")

func attack(target: Node3D) -> void:
	if player_in_range and room.player_in_room:
		# disable player detection
		$AttackRange.collision_mask = 0
		
		# shoot projectile at target
		var projectile: Projectile = projectile_scene.instantiate()
		add_child(projectile)
		projectile.shoot(target.global_position)
