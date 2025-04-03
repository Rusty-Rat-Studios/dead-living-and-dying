class_name PossessableRanged
extends PossessableAttack

signal projectile_shot

@export var projectile_scene: PackedScene
@export var attack_once: bool = false

var has_attacked: bool = false

func attack(target: Node3D, _attack_windup: float) -> void:
	if player_in_range and room.player_in_room and (not attack_once or not has_attacked):
		# disable player detection
		$AttackRange.collision_mask = 0
		
		projectile_shot.emit()
		has_attacked = true
		
		# shoot projectile at target
		var projectile: Projectile = projectile_scene.instantiate()
		add_child(projectile)
		projectile.shoot(target.global_position)
