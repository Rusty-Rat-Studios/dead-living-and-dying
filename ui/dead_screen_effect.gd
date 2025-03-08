extends ScreenOverlay

@onready var fade_tween: Tween


func _ready() -> void:
	# ensure invisible and zero opacity
	visible = false
	modulate.a = 0


func fade_in(duration: float) -> void:
	self.visible = true
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self, "modulate:a", 1, duration / 2)
	await Utility.delay(duration)


func fade_out(duration: float) -> void:
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self, "modulate:a", 0, duration / 2)
	await Utility.delay(duration)
	self.visible = false
