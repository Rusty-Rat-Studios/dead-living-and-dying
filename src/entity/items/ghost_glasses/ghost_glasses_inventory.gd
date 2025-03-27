extends ActiveItemInventory

const BASE_COOLDOWN_DURATION: float = 10
const NAME: String = "ghost_glasses"
const START_RADIUS: float = 0.5

var cooldown_active: bool = false 
var player: Node = PlayerHandler.get_player()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_resource = preload("res://src/entity/items/ghost_glasses/ghost_glasses_world.tscn")
	display_name = "Ghost Glasses"
	input_event = "use_active_item"
	description = ("Active ITEM: Use with " + UIDevice.retrieve_icon_sized(input_event)
		+ " to reveal ghosts in a radius temporarily.")
	texture = preload("res://src/entity/items/lamp_oil/lamp_oil.png")
	
	$CooldownTimer.wait_time = BASE_COOLDOWN_DURATION
	$CooldownTimer.timeout.connect(_on_cooldown_timer_timeout)
	
	$Hitbox.body_entered.connect(_on_body_entered)


func _input(event: InputEvent) -> void:
	if PlayerHandler.get_player_state() == PlayerStateMachine.States.DEAD:
		return
	if event.is_action_pressed("use_active_item"):
		use()


func use() -> void:
	if cooldown_active:
		return
	$Hitbox/CollisionShape3D.shape.radius = START_RADIUS * player.player_stats.area_size
	$Hitbox/MeshInstance3D.mesh.outer_radius = START_RADIUS * player.player_stats.area_size
	$Hitbox/MeshInstance3D.mesh.inner_radius = $Hitbox/MeshInstance3D.mesh.outer_radius - 0.2
	$Hitbox/CollisionShape3D.disabled = false
	$Hitbox.visible = true
	$CooldownTimer.wait_time = BASE_COOLDOWN_DURATION / player.player_stats.cooldown_reduction
	var mesh_outer_tween: Tween = create_tween()
	var mesh_inner_tween: Tween = create_tween()
	var collision_tween: Tween = create_tween()
	mesh_inner_tween.finished.connect(_on_tween_finished)
	collision_tween.tween_property($Hitbox/CollisionShape3D.shape, "radius", 20, 0.5)
	mesh_outer_tween.tween_property($Hitbox/MeshInstance3D.mesh, "inner_radius", 19.8, 0.5)
	mesh_inner_tween.tween_property($Hitbox/MeshInstance3D.mesh, "outer_radius", 20, 0.5)
	$CooldownTimer.start()
	cooldown_active = true
	
	item_used.emit($CooldownTimer)


func _on_cooldown_timer_timeout() -> void:
	cooldown_active = false


func _on_body_entered(body: Node3D) -> void:
	if body is Ghost:
		body.reveal.emit()


func _on_tween_finished() -> void:
		$Hitbox/CollisionShape3D.disabled = true
		$Hitbox.visible = false
