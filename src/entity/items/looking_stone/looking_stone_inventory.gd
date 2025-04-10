extends ActiveItemInventory

const BASE_COOLDOWN_DURATION: float = 7
const NAME: String = "looking_stone"
const START_RADIUS: float = 0.5
const END_RADIUS: float = 20
const STARTING_ALPHA: float = 0.686
const TWEEN_DURATION: int = 1
const COLLISION_OFFSET: float = 0.002

var cooldown_active: bool = false 
var player: Node = PlayerHandler.get_player()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_resource = load("res://src/entity/items/looking_stone/looking_stone_world.tscn")
	display_name = "Looking Stone"
	input_event = "use_active_item"
	description = ("Active ITEM: Use with " + UIDevice.retrieve_icon_sized(input_event)
		+ " to reveal ghosts in a radius temporarily.")
	texture = preload("res://src/entity/items/looking_stone/looking_stone.png")
	
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
	$Hitbox/CollisionShape3D.shape.radius = START_RADIUS * player.player_stats.area_size + COLLISION_OFFSET
	$Hitbox/MeshInstance3D.mesh.outer_radius = START_RADIUS * player.player_stats.area_size + COLLISION_OFFSET
	$Hitbox/MeshInstance3D.mesh.inner_radius = $Hitbox/MeshInstance3D.mesh.outer_radius - 0.001 + COLLISION_OFFSET
	$Hitbox/MeshInstance3D.mesh.material.albedo_color.a = STARTING_ALPHA + COLLISION_OFFSET
	$Hitbox/CollisionShape3D.disabled = false
	$Hitbox.visible = true
	$CooldownTimer.wait_time = BASE_COOLDOWN_DURATION / player.player_stats.cooldown_reduction
	var mesh_outer_tween: Tween = create_tween()
	var mesh_inner_tween: Tween = create_tween()
	var collision_tween: Tween = create_tween()
	var opacity_tween: Tween = create_tween()
	mesh_inner_tween.finished.connect(_on_tween_finished)
	collision_tween.tween_property($Hitbox/CollisionShape3D.shape, "radius", 
		END_RADIUS * player.player_stats.area_size, TWEEN_DURATION)
	mesh_outer_tween.tween_property($Hitbox/MeshInstance3D.mesh, "inner_radius", 
		END_RADIUS * player.player_stats.area_size - 0.02, TWEEN_DURATION)
	mesh_inner_tween.tween_property($Hitbox/MeshInstance3D.mesh, "outer_radius", 
		END_RADIUS * player.player_stats.area_size, TWEEN_DURATION)
	opacity_tween.tween_property($Hitbox/MeshInstance3D.mesh.material, "albedo_color:a",0, TWEEN_DURATION)
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
