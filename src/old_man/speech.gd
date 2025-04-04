extends AudioStreamMultiple

const AUDIO_FOLDER_PATH: String = "res://src/sound/old_man"


func _ready() -> void:
	audio_folder_path = AUDIO_FOLDER_PATH
	super()
