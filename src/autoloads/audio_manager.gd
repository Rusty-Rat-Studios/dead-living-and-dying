extends Node

const PITCH_MAX_STEP: float = 0.1


func play_modulated(audio_player: AudioStreamPlayer3D, from_position: float = 0) -> void:
	# randomly modulate pitch +/- 10%
	var pitch: float = audio_player.pitch_scale
	audio_player.pitch_scale = pitch + RNG.rng.randf_range(-PITCH_MAX_STEP, PITCH_MAX_STEP)
	audio_player.play(from_position)
	# reset pitch
	await audio_player.finished
	audio_player.pitch_scale = 1
