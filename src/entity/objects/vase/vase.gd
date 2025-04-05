extends RigidBody3D

@onready var break_after_throw_timer: Timer = $BreakAfterThrowTimer
@onready var break_sfx: AudioStreamPlayer3D = $Break


func _ready() -> void:
	$Throwable.thrown.connect(_on_thrown)
	body_entered.connect(_on_body_entered)
	break_after_throw_timer.timeout.connect(stop_monitoring)


func stop_monitoring() -> void:
	call_deferred("set_contact_monitor", false)
	if not break_after_throw_timer.is_stopped():
		break_after_throw_timer.stop()


func _on_thrown() -> void:
	contact_monitor = true
	max_contacts_reported = 1
	break_after_throw_timer.start()


func _on_body_entered(_body: Node3D) -> void:
	stop_monitoring()
	print("BREAK!")
	
	# Prevent game from crashing due to possessable being added back to room
	(get_parent() as Room).call_deferred("remove_possessable", $Throwable)
	
	visible = false
	
	AudioManager.play_modulated(break_sfx)
	await break_sfx.finished
	
	queue_free()
