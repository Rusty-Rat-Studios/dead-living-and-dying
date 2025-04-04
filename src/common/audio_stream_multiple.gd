class_name AudioStreamMultiple
extends AudioStreamPlayer3D

@export var audio_folder_path: String
var audio_clips: Array[AudioStream]


func _ready() -> void:
	init_audio_clips()


func init_audio_clips() -> void:
	audio_clips = []
	var dir_access: DirAccess = DirAccess.open(audio_folder_path)
	if dir_access == null:
		printerr("Could not open directory:", audio_folder_path)
		return

	dir_access.list_dir_begin()
	var file_name: String = dir_access.get_next()
	while file_name != "":
		if not dir_access.current_is_dir() and not file_name.ends_with(".import"):
			var full_path: String = audio_folder_path.rstrip("/") + "/" + file_name
			var audio_stream: AudioStream = load(full_path) as AudioStream
			if audio_stream != null:
				audio_clips.append(audio_stream)
			else:
				printerr("Failed to load audio file:", full_path)
		file_name = dir_access.get_next()

	dir_access.list_dir_end()
	print("Loaded", audio_clips.size(), "audio clips from:", audio_folder_path)


func get_random_audio_clip() -> AudioStream:
	if audio_clips.is_empty():
		printerr("No audio clips loaded.")
		return null
	var random_index: int = RNG.rng.randi() % audio_clips.size()
	return audio_clips[random_index]


func play_random_sound(interrupt: bool = false) -> void:
	# check if audio already playing - don't interrupt self
	if playing and not interrupt:
		return
	var random_clip: AudioStream = get_random_audio_clip()
	if random_clip != null:
		stream = random_clip
		AudioManager.play_modulated(self)


func enable() -> void:
	play_random_sound()


func disable() -> void:
	stop()
