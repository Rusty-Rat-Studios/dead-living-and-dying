extends GhostState

const STUN_DURATION: float = 3

@onready var stun_timer: Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stun_timer.one_shot = true
	stun_timer.wait_time = STUN_DURATION
	stun_timer.timeout.connect(_on_stun_timer_timeout)
	add_child(stun_timer)


func enter() -> void:
	stun_timer.start()


func process_state() -> void:
	return


func _on_stun_timer_timeout() -> void:
	change_state(GhostStateMachine.States.WAITING)
