extends HBoxContainer

const MUTE_DB: float = -100

@export var sound_group: String = ""

var audio_bus: int


func _ready() -> void:
	audio_bus = AudioServer.get_bus_index(sound_group.capitalize())
	
	$Label.text = sound_group.capitalize()
	
	$HSlider.value = AudioServer.get_bus_volume_db(audio_bus)
	$HSlider.value_changed.connect(_on_value_changed)


func _on_value_changed(value: float) -> void:
	if value == $HSlider.min_value:
		AudioServer.set_bus_volume_db(audio_bus, MUTE_DB)
	else:
		AudioServer.set_bus_volume_db(audio_bus, value)
	
	
	print(AudioServer.get_bus_name(audio_bus), " bus set to ", value)
