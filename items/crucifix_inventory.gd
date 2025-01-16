extends DefenseItemInventory

signal ghost_hit(ghost: Ghost)

@onready var cooldown_duration: float = 4
@onready var active_duration: float = 2
@onready var cooldown_active: bool = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ActiveTimer.wait_time = active_duration
	$CooldownTimer.wait_time = cooldown_duration
	$ActiveTimer.timeout.connect(_on_active_timer_timeout)
	$CooldownTimer.timeout.connect(_on_cooldown_timer_timeout)
	
	$Hitbox.body_entered.connect(_on_body_entered)


func _input(event: InputEvent) -> void:
	if PlayerHandler.get_player_state() == "Dead":
		return
	if event.is_action_pressed("use_defense_item"):
		use()


func use() -> void:
	if cooldown_active:
		return
	$Hitbox/CollisionShape3D.disabled = false
	$Hitbox.visible = true
	$ActiveTimer.start()
	cooldown_active = true


func _on_active_timer_timeout() -> void:
	$Hitbox/CollisionShape3D.disabled = true
	$Hitbox.visible = false
	$CooldownTimer.start()


func _on_cooldown_timer_timeout() -> void:
	cooldown_active = false


func _on_body_entered(body: Node3D) -> void:
	if body is Ghost:
		body.hit.emit()
