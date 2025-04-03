class_name ShrineRoom
extends Room

@onready var rain_sfx: AudioStreamPlayer3D = $Sounds/Rain
@onready var player_sfx_detector: Area3D = $Sounds/PlayerSoundDetector


func _ready() -> void:
	super()
	rain_sfx.play()
	rain_sfx.stream_paused = false if player_in_room else true
	
	player_sfx_detector.body_entered.connect(_on_player_entered_sfx_range)
	player_sfx_detector.body_exited.connect(_on_player_exited_sfx_range)


func _on_player_entered_room(body: Node3D) -> void:
	super(body)
	
	body.footsteps_sfx.stream = body.footsteps_sfx.FOOTSTEPS_GRASS
	body.footsteps_sfx.play()


func _on_player_exited_room(body: Node3D) -> void:
	super(body)
	
	body.footsteps_sfx.stream = body.footsteps_sfx.FOOTSTEPS_WOOD
	body.footsteps_sfx.play()


func _on_player_entered_sfx_range(body: Node3D) -> void:
	rain_sfx.stream_paused = false


func _on_player_exited_sfx_range(body: Node3D) -> void:
	rain_sfx.stream_paused = true
