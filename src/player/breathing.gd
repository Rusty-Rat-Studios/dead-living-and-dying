extends AudioStreamPlayer3D

const AUDIO_FOLDER_PATH: String = "res://src/sound/sfx/breath"

const DELAY_TIME_MIN: float = 1.5
const DELAY_TIME_MAX: float = 2.5

var audio_clips: Array[AudioStream]
var delay_timer: Timer = Timer.new()

func _ready() -> void:
	init_audio_clips()
	
	delay_timer.wait_time = RNG.rng.randf_range(DELAY_TIME_MIN, DELAY_TIME_MAX)
	add_child(delay_timer)
	delay_timer.timeout.connect(_on_delay_timer_timeout)


func init_audio_clips() -> void:
	audio_clips = []
	var dir_access: DirAccess = DirAccess.open(AUDIO_FOLDER_PATH)
	if dir_access == null:
		printerr("Could not open directory:", AUDIO_FOLDER_PATH)
		return

	dir_access.list_dir_begin()
	var file_name: String = dir_access.get_next()
	while file_name != "":
		if not dir_access.current_is_dir() and not file_name.ends_with(".import"):
			var full_path: String = AUDIO_FOLDER_PATH.rstrip("/") + "/" + file_name
			var audio_stream: AudioStream = load(full_path) as AudioStream
			if audio_stream != null:
				audio_clips.append(audio_stream)
			else:
				printerr("Failed to load audio file:", full_path)
		file_name = dir_access.get_next()

	dir_access.list_dir_end()
	print("Loaded", audio_clips.size(), "audio clips from:", AUDIO_FOLDER_PATH)


func enable() -> void:
	play_random_sound()
	delay_timer.start()


func disable() -> void:
	delay_timer.stop()
	stop()


func get_random_audio_clip() -> AudioStream:
	if audio_clips.is_empty():
		printerr("No audio clips loaded.")
		return null
	var random_index: int = RNG.rng.randi() % audio_clips.size()
	return audio_clips[random_index]


func play_random_sound() -> void:
	var random_clip: AudioStream = get_random_audio_clip()
	if random_clip != null:
		stream = random_clip
		play()


func _on_delay_timer_timeout() -> void:
	play_random_sound()
	delay_timer.wait_time = RNG.rng.randf_range(DELAY_TIME_MIN, DELAY_TIME_MAX)
