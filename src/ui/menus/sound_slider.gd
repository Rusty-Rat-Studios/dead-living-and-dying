extends HBoxContainer

var MASTER_BUS: int = AudioServer.get_bus_index("Master")

@export var master: bool = false
@export var sound_group: String = ""


func _ready() -> void:
	if master:
		$HSlider.value_changed.connect(_on_master_value_changed)
		$Label.text = "Master"
	else:
		$HSlider.value_changed.connect(_on_value_changed)
		$Label.text = sound_group.capitalize()


func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MASTER_BUS, value)


func _on_value_changed(value: float) -> void:
	print("sound group: ", sound_group)
	var audio_players: Array[Node] = get_tree().get_nodes_in_group(sound_group)
	
	print(audio_players)
