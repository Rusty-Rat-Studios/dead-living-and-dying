extends AudioStreamMultiple

const AMBIENCE_DYING_PATH: String = "res://src/sound/ambience/dying"
const AMBIENCE_DEAD_PATH: String = "res://src/sound/ambience/dead"


func _ready() -> void:
	# switch set of ambience files based on player state
	SignalBus.player_state_changed.connect(_on_player_state_changed)
	# start new ambient track
	finished.connect(_on_stream_finished)


func _on_player_state_changed(state: PlayerStateMachine.States) -> void:
	match state:
		PlayerStateMachine.States.LIVING:
			stop()
			return
		PlayerStateMachine.States.DYING:
			audio_folder_path = AMBIENCE_DYING_PATH
		PlayerStateMachine.States.DEAD:
			audio_folder_path = AMBIENCE_DEAD_PATH
	
	init_audio_clips()
	play_random_sound()


func _on_stream_finished() -> void:
	play_random_sound()
