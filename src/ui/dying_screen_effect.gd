extends TextureRect

const MAX_OPACITY: float = 0.7
const MIN_OPACITY: float = 0.4
const FADE_DURATION: float = 2

var fade_timer: Timer = Timer.new()
var fade_tween: Tween
# used to swap fade in/out "direction" after each effect finishes
var fading_in: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(fade_timer)
	fade_timer.wait_time = FADE_DURATION
	fade_timer.timeout.connect(_on_fade_timer_timeout)


func enable() -> void:
	# begin with an extra strong effect and transition to normal "max strength" effect
	modulate.a = 0.8
	fade_to(MAX_OPACITY)
	# ensure on timeout that next step is to fade out
	fading_in = false
	fade_timer.start()


func disable() -> void:
	fade_timer.stop()
	fade_to(0)


func fade_to(target_opacity: float) -> void:
	fade_tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	fade_tween.tween_property(self, "modulate:a", target_opacity, FADE_DURATION)


func _on_fade_timer_timeout() -> void:
	if fading_in: 
		fade_to(MAX_OPACITY)
	else:
		fade_to(MIN_OPACITY)
	fading_in = !fading_in
