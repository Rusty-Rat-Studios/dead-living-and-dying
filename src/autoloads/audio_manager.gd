extends Node

const PITCH_MAX_STEP: float = 0.05

var db_values: Dictionary[String, float]

func register_sound_group(group_name: String, value: float) -> void:
	if not db_values.has(group_name):
		db_values[group_name] = value


func set_db_value(group_name: String, value: float) -> void:
	db_values[group_name] = value


func get_db_value(group_name: String) -> float:
	return db_values[group_name]


func play_modulated(audio_player: AudioStreamPlayer3D, from_position: float = 0) -> void:
	# randomly modulate pitch +/- 10%
	var pitch: float = audio_player.pitch_scale
	audio_player.pitch_scale = pitch + RNG.rng.randf_range(-PITCH_MAX_STEP, PITCH_MAX_STEP)
	audio_player.play(from_position)
	# reset pitch
	await audio_player.finished
	audio_player.pitch_scale = 1
