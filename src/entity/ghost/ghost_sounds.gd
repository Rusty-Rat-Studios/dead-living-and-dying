extends Node3D

@onready var ghost_sfx: AudioStreamPlayer3D = $GhostSFX
@onready var player_detector: Area3D = $PlayerSoundDetector


func _ready() -> void:
	# play wheezing sound if player nearby
	player_detector.body_entered.connect(_on_body_entered)


func _on_body_entered(_body: Node3D) -> void:
	ghost_sfx.play_sound()
