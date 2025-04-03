class_name PossessableRanged
extends PossessableAttack

@export var projectile_scene: PackedScene

func attack(target: Node3D, _attack_windup: float) -> void:
	if player_in_range and room.player_in_room:
		# disable player detection
		$AttackRange.collision_mask = 0
		
		# shoot projectile at target
		var projectile: Projectile = projectile_scene.instantiate()
		add_child(projectile)
		projectile.shoot(target.global_position)
