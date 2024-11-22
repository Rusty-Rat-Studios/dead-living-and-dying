extends Area3D

# responds to player hit timer elapsing
@onready var hit_cooldown_active: bool = false
# tracks if player is in the area or not
@onready var player_colliding: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	SignalBus.hit_cooldown_finished.connect(_on_hit_cooldown_finished)
	
	# just for giggles
	SignalBus.player_state_changed.connect(_on_state_change)


func hurt_player() -> void:
	if not hit_cooldown_active and player_colliding:
		SignalBus.emit_signal("player_hurt")
		hit_cooldown_active = true


func _on_body_entered(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		player_colliding = true
		hurt_player()


func _on_body_exited(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		player_colliding = false


func _on_state_change(state_name: String) -> void:
	match state_name:
		"Living":
			$Label3D.text = "HURTBOX\n\nCome here to\nget hurt ;_ ;"
		"Dead":
			$Label3D.text = "HURTBOX\n\nDon't worry little ghost,\n\nHurtbox can't hurt you."


func _on_hit_cooldown_finished() -> void:
	hit_cooldown_active = false
	# damage player again if they're still intersecting
	if player_colliding:
		hurt_player()
