extends DefenseItemInventory

@onready var cooldown_duration: float = 4
@onready var active_duration: float = 2
@onready var cooldown_active: bool = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ActiveTimer.wait_time = active_duration
	$CooldownTimer.wait_time = cooldown_duration
	$ActiveTimer.timeout.connect(_on_active_timer_timeout)
	$CooldownTimer.timeout.connect(_on_cooldown_timer_timeout)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	super(event) 
	if event.is_action_pressed("use_defense_item"):
		use()


func use() -> void:
	if cooldown_active:
		return
	$Hitbox.collision_mask = CollisionBit.SPIRIT
	$ActiveTimer.start()
	cooldown_active = true


func _on_active_timer_timeout() -> void:
	$Hitbox.collision_mask = 0
	$CooldownTimer.start()


func _on_cooldown_timer_timeout() -> void:
	cooldown_active = false
