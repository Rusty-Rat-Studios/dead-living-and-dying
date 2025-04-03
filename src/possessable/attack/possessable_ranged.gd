class_name PossessableRanged
extends PossessableAttack

signal projectile_shot

@export var projectile_scene: PackedScene
@export var attack_once: bool = false


func _ready() -> void:
	super()
	projectile_shot.connect(_on_projectile_shot)


func attack(target: Node3D, _attack_windup: float) -> void:
	if player_in_range and room.player_in_room:
		projectile_shot.emit()
		
		var projectile: Projectile = projectile_scene.instantiate()
		
		# ensure projectile cannot collide with its spawner
		projectile.add_collision_exception_with(self)
		
		room.add_child(projectile)
		
		projectile.global_position = global_position
		projectile.shoot(target.global_position) # shoot projectile at target
		
	depossess(true)


func _on_projectile_shot() -> void:
	if attack_once:
		room.call_deferred("remove_possessable", self)
