extends AudioStreamMultiple

const DELAY_TIME_MIN: float = 1.5
const DELAY_TIME_MAX: float = 2.5

var delay_timer: Timer = Timer.new()


func _ready() -> void:
	super()
	
	delay_timer.wait_time = RNG.rng.randf_range(DELAY_TIME_MIN, DELAY_TIME_MAX)
	add_child(delay_timer)
	delay_timer.timeout.connect(_on_delay_timer_timeout)



func enable() -> void:
	super()
	delay_timer.start()


func disable() -> void:
	super()
	delay_timer.stop()


func _on_delay_timer_timeout() -> void:
	play_random_sound()
	delay_timer.wait_time = RNG.rng.randf_range(DELAY_TIME_MIN, DELAY_TIME_MAX)
