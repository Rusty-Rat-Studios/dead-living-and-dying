extends ActiveItemInventory

const BASE_COOLDOWN_DURATION: float = 10
const BASE_ACTIVE_DURATION: float = 4
const OMNI_RANGE_MODIFIER: float = 3
const SPOT_RANGE_MODIFIER: float = 3
const ENERGY_MODIFIER: float = 1
const NAME: String = "lamp_oil"

var cooldown_active: bool = false 

@onready var player: Node = PlayerHandler.get_player()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_name = "Lamp Oil"
	input_event = "use_active_item"
	description = ("Active ITEM: Use with " + UIDevice.retrieve_icon_sized(input_event)
		+ " to temporarily increase your light's strength.")
	texture = preload("res://src/entity/items/lamp_oil/lamp_oil.png")
	
	$ActiveTimer.wait_time = BASE_ACTIVE_DURATION
	$CooldownTimer.wait_time = BASE_COOLDOWN_DURATION
	$ActiveTimer.timeout.connect(_on_active_timer_timeout)
	$CooldownTimer.timeout.connect(_on_cooldown_timer_timeout)


func _input(event: InputEvent) -> void:
	if PlayerHandler.get_player_state() == PlayerStateMachine.States.DEAD:
		return
	if event.is_action_pressed("use_active_item"):
		use()


func use() -> void:
	if cooldown_active:
		return
	temp_stat_update(OMNI_RANGE_MODIFIER, SPOT_RANGE_MODIFIER, ENERGY_MODIFIER)
	$ActiveTimer.wait_time = BASE_ACTIVE_DURATION * player.player_stats.duration
	$ActiveTimer.start()
	$CooldownTimer.wait_time = BASE_COOLDOWN_DURATION / player.player_stats.cooldown_reduction
	$CooldownTimer.start()
	cooldown_active = true
	
	item_used.emit($CooldownTimer)


func _on_active_timer_timeout() -> void:
	reset_stat_update()


func _on_cooldown_timer_timeout() -> void:
	cooldown_active = false


func temp_stat_update(omni_range_modifier: float, spot_range_modifier: float, 
	energy_modifier: float) -> void:
	player.player_stats.stat_update_add(PlayerStats.Stats.LIGHT_OMNI_RANGE, omni_range_modifier, NAME)
	player.player_stats.stat_update_add(PlayerStats.Stats.LIGHT_SPOT_RANGE, spot_range_modifier, NAME)
	player.player_stats.stat_update_add(PlayerStats.Stats.LIGHT_ENERGY, energy_modifier, NAME)


func reset_stat_update() -> void:
	var player: Node = PlayerHandler.get_player()
	player.player_stats.stat_update_remove(PlayerStats.Stats.LIGHT_OMNI_RANGE, NAME)
	player.player_stats.stat_update_remove(PlayerStats.Stats.LIGHT_SPOT_RANGE, NAME)
	player.player_stats.stat_update_remove(PlayerStats.Stats.LIGHT_ENERGY, NAME)
