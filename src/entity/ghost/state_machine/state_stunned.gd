extends GhostState

var collision_shape: CollisionShape3D

@onready var stun_timer: Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stun_timer.one_shot = true
	stun_timer.timeout.connect(_on_stun_timer_timeout)
	add_child(stun_timer)


func init(parent: CharacterBody3D, state_machine: StateMachine) -> void:
	super(parent, state_machine)
	collision_shape = _parent.hitbox.get_node("CollisionShape3D")
	stun_timer.wait_time = _parent.stats.stun_duration


func enter() -> void:
	_parent.sprite.animation = "idle"
	stun_timer.start()
	collision_shape.set_deferred("disabled", true)


func exit() -> void:
	collision_shape.set_deferred("disabled", false)


func process_state() -> void:
	return


func _on_stun_timer_timeout() -> void:
	change_state(GhostStateMachine.States.WAITING)
