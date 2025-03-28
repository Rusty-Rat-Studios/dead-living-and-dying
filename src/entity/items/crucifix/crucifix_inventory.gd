extends DefenseItemInventory

const BASE_COOLDOWN_DURATION: float = 5
const BASE_ACTIVE_DURATION: float = 2
const BASE_RADIUS: float = 2

var player: Node = PlayerHandler.get_player()

@onready var cooldown_active: bool = false


func _ready() -> void:
	world_resource = load("res://src/entity/items/crucifix/crucifix_inventory.tscn")
	display_name = "Crucifix"
	input_event = "use_defense_item"
	description = ("DEFENSE ITEM: Use with " + UIDevice.retrieve_icon_sized(input_event)
		+ " to exorcise possessed objects within a limited range.")
	texture = preload("res://src/entity/items/crucifix/crucifix.png")
	
	$ActiveTimer.wait_time = BASE_ACTIVE_DURATION
	$CooldownTimer.wait_time = BASE_COOLDOWN_DURATION
	$ActiveTimer.timeout.connect(_on_active_timer_timeout)
	$CooldownTimer.timeout.connect(_on_cooldown_timer_timeout)
	
	$Hitbox.body_entered.connect(_on_body_entered)


func _unhandled_input(event: InputEvent) -> void:
	if PlayerHandler.get_player_state() == PlayerStateMachine.States.DEAD:
		return
	if event.is_action_pressed("use_defense_item"):
		use()


func use() -> void:
	if cooldown_active:
		return
	$Hitbox/CollisionShape3D.shape.radius = BASE_RADIUS * player.player_stats.area_size
	$Hitbox/MeshInstance3D.mesh.outer_radius = BASE_RADIUS * player.player_stats.area_size
	$Hitbox/MeshInstance3D.mesh.inner_radius = $Hitbox/MeshInstance3D.mesh.outer_radius - 0.2
	$Hitbox/CollisionShape3D.disabled = false
	$Hitbox.visible = true
	$ActiveTimer.wait_time = BASE_ACTIVE_DURATION * player.player_stats.duration
	$ActiveTimer.start()
	$CooldownTimer.wait_time = BASE_COOLDOWN_DURATION / player.player_stats.cooldown_reduction
	$CooldownTimer.start()
	cooldown_active = true
	
	item_used.emit($CooldownTimer)


func _on_active_timer_timeout() -> void:
	$Hitbox/CollisionShape3D.disabled = true
	$Hitbox.visible = false


func _on_cooldown_timer_timeout() -> void:
	cooldown_active = false


func _on_body_entered(body: Node3D) -> void:
	if body is Ghost:
		body.hit.emit()
