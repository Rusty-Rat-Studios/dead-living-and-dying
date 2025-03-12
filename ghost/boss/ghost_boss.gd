extends Ghost

# amount of time before rolling for event
const EVENT_CHANCE_TIME: float = 5

@onready var event_chance_timer: Timer = Timer.new()


func _ready() -> void:
	super()
	
	add_child(event_chance_timer)
	event_chance_timer.wait_time = EVENT_CHANCE_TIME
	event_chance_timer.timeout.connect(_on_event_chance_timer_timeout)


func _on_event_chance_timer_timeout() -> void:
	pass
