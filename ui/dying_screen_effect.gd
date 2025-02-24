extends TextureRect

const MAX_OPACITY: float = 0.125
const MIN_OPACITY: float = 0.0625
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
	# begin with a strong effect and fade to normal in/out fading
	modulate.a = 0.5
	fade_in()
	fade_timer.start()


func disable() -> void:
	fade_timer.stop()
	fade_out()


func fade_in() -> void:
	fade_tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	fade_tween.tween_property(self, "modulate:a", MAX_OPACITY, FADE_DURATION)


func fade_out() -> void:
	fade_tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	fade_tween.tween_property(self, "modulate:a", MIN_OPACITY, FADE_DURATION)


func _on_fade_timer_timeout() -> void:
	if fading_in: 
		fade_out()
	else:
		fade_in()
	fading_in = !fading_in
