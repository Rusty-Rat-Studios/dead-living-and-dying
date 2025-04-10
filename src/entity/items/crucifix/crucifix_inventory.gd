extends DefenseItemInventory

const BASE_COOLDOWN_DURATION: float = 5
const BASE_ACTIVE_DURATION: float = 1.5
const BASE_RADIUS: float = 2
const STUN_MODIFER: float = 0.5

var player: Node = PlayerHandler.get_player()

@onready var particle_material: ParticleProcessMaterial = $GPUParticles3D.process_material
@onready var cooldown_active: bool = false


func _ready() -> void:
	world_resource = load("res://src/entity/items/crucifix/crucifix_world.tscn")
	display_name = "Crucifix"
	input_event = "use_defense_item"
	description = ("DEFENSE ITEM: Use with " + UIDevice.retrieve_icon_sized(input_event)
		+ " to exorcise possessed objects within a limited range.")
	texture = preload("res://src/entity/items/crucifix/crucifix.png")
	
	$GPUParticles3D.emitting = false
	
	$ActiveTimer.wait_time = BASE_ACTIVE_DURATION
	$CooldownTimer.wait_time = BASE_COOLDOWN_DURATION
	$ActiveTimer.timeout.connect(_on_active_timer_timeout)
	$CooldownTimer.timeout.connect(_on_cooldown_timer_timeout)
	
	$Hitbox.body_entered.connect(_on_body_entered)
	$Shield.body_entered.connect(_on_body_entered2)


func _unhandled_input(event: InputEvent) -> void:
	if PlayerHandler.get_player_state() == PlayerStateMachine.States.DEAD:
		return
	if event.is_action_pressed("use_defense_item"):
		use()


func use() -> void:
	if cooldown_active:
		return
	$Hitbox/CollisionShape3D.shape.radius = BASE_RADIUS * player.player_stats.area_size
	$Shield/CollisionShape3D.shape.radius = BASE_RADIUS * player.player_stats.area_size
	particle_material.emission_ring_radius = BASE_RADIUS * player.player_stats.area_size
	particle_material.emission_ring_inner_radius = particle_material.emission_ring_radius - 0.2
	$Hitbox/CollisionShape3D.disabled = false
	$Shield/CollisionShape3D.disabled = false
	$GPUParticles3D.emitting = true
	
	$ActiveTimer.wait_time = BASE_ACTIVE_DURATION * player.player_stats.duration
	$ActiveTimer.start()
	$CooldownTimer.wait_time = BASE_COOLDOWN_DURATION / player.player_stats.cooldown_reduction
	$CooldownTimer.start()
	cooldown_active = true
	item_used.emit($CooldownTimer)


func _on_active_timer_timeout() -> void:
	$GPUParticles3D.emitting = false
	await Utility.delay($GPUParticles3D.lifetime)
	$Hitbox/CollisionShape3D.disabled = true
	$Shield/CollisionShape3D.disabled = true


func _on_cooldown_timer_timeout() -> void:
	cooldown_active = false


func _on_body_entered(body: Node3D) -> void:
	if body is Ghost:
		body.hit.emit(STUN_MODIFER, display_name)


func _on_body_entered2(body: Node3D) -> void:
	var force: Vector3 = body.linear_velocity
	body.linear_velocity = Vector3(0,0,0);
	body.apply_impulse(-force * 0.5)
