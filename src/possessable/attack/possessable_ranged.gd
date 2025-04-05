class_name PossessableRanged
extends PossessableAttack

signal max_projectiles_shot

@export var projectile_scene: PackedScene
@export var max_attack_amount: int = -1

var attack_amount: int = 0

@onready var shoot_sfx: AudioStreamMultiple = $Shoot


func _ready() -> void:
	super()


func attack(target: Node3D, _attack_windup: float) -> void:
	if player_in_range and room.player_in_room:
		_on_projectile_shot()
		
		var projectile: Projectile = projectile_scene.instantiate()
		
		# ensure projectile cannot collide with its spawner
		projectile.add_collision_exception_with(self)
		
		room.add_child(projectile)
		
		projectile.global_position = global_position
		projectile.shoot(target.global_position) # shoot projectile at target
		
		shoot_sfx.play_random_sound()
		
	depossess(true)


func _on_projectile_shot() -> void:
	attack_amount += 1
	if max_attack_amount != -1 and attack_amount >= max_attack_amount:
		max_projectiles_shot.emit()
		room.call_deferred("remove_possessable", self)
