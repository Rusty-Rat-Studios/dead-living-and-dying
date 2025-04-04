extends AudioStreamPlayer3D

const MAX_DB_QUIET: float = -12 # used in state LIVING
const MAX_DB_NORMAL: float = -4 # used in state DYING

const WHEEZE_AUDIO_FOLDER_PATH: String = "res://src/sound/ghost/wheeze"
const DEAD_STING: AudioStream = preload("res://src/sound/ghost/dead_sting.mp3")


const DELAY_TIME_MIN: float = 1.5
const DELAY_TIME_MAX: float = 2.5

var audio_clips: Array[AudioStream]
var player_dead: bool = false


func _ready() -> void:
	init_audio_clips()
	# initialize max_db to state living condition
	max_db = MAX_DB_QUIET
	# reduce volume if living; increase if dying; disable if dead
	SignalBus.player_state_changed.connect(_on_player_state_changed)


func init_audio_clips() -> void:
	audio_clips = []
	var dir_access: DirAccess = DirAccess.open(WHEEZE_AUDIO_FOLDER_PATH)
	if dir_access == null:
		printerr("Could not open directory:", WHEEZE_AUDIO_FOLDER_PATH)
		return

	dir_access.list_dir_begin()
	var file_name: String = dir_access.get_next()
	while file_name != "":
		if not dir_access.current_is_dir() and not file_name.ends_with(".import"):
			var full_path: String = WHEEZE_AUDIO_FOLDER_PATH.rstrip("/") + "/" + file_name
			var audio_stream: AudioStream = load(full_path) as AudioStream
			if audio_stream != null:
				audio_clips.append(audio_stream)
			else:
				printerr("Failed to load audio file:", full_path)
		file_name = dir_access.get_next()

	dir_access.list_dir_end()
	print("Loaded", audio_clips.size(), "audio clips from:", WHEEZE_AUDIO_FOLDER_PATH)


func enable() -> void:
	play_random_sound()


func disable() -> void:
	stop()


func get_random_audio_clip() -> AudioStream:
	if audio_clips.is_empty():
		printerr("No audio clips loaded.")
		return null
	var random_index: int = RNG.rng.randi() % audio_clips.size()
	return audio_clips[random_index]


func play_sound() -> void:
	if playing: 
		return
	if player_dead:
		if stream != DEAD_STING:
			stream = DEAD_STING
		AudioManager.play_modulated(self)
	else:
		play_random_sound()


func play_random_sound() -> void:
	# check if audio already playing - don't interrupt self
	if playing:
		return
	var random_clip: AudioStream = get_random_audio_clip()
	if random_clip != null:
		stream = random_clip
		play()


func _on_player_state_changed(state: PlayerStateMachine.States) -> void:
	match state:
		PlayerStateMachine.States.LIVING:
			player_dead = false
			max_db = MAX_DB_QUIET # quieter when player is living
		PlayerStateMachine.States.DYING:
			max_db = MAX_DB_NORMAL # louder when player is dying
		PlayerStateMachine.States.DEAD:
			player_dead = true
			# change audio stream to scary noises
			stream = DEAD_STING
