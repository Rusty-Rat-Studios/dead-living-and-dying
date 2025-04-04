extends HBoxContainer

@export var sound_group: String = ""

#var master_bus: int = AudioServer.get_bus_index("Master")
var audio_bus: int


func _ready() -> void:
	audio_bus = AudioServer.get_bus_index(sound_group.capitalize())
	#AudioManager.register_sound_group(sound_group, 0)
	$Label.text = sound_group.capitalize()
	# get and apply any existing setting changes
	# needed if set in main menu and accessed in-game
	#$HSlider.value = AudioManager.get_db_value(sound_group)
	$HSlider.value = AudioServer.get_bus_volume_db(audio_bus)
	$HSlider.value_changed.connect(_on_value_changed)
	
	print(self.name, " initialized to ", $HSlider.value)
	
	#if sound_group == "master":
		#$HSlider.value_changed.connect(_on_master_value_changed)
	#else:
		#$HSlider.value_changed.connect(_on_value_changed)
		#_on_value_changed($HSlider.value)
	
	


#func _on_master_value_changed(value: float) -> void:
	#AudioServer.set_bus_volume_db(master_bus, value)
	#AudioManager.set_db_value(sound_group, value)
	#print("master volume set to: ", AudioServer.get_bus_volume_db(master_bus), "db")


func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(audio_bus, value)
	print(AudioServer.get_bus_name(audio_bus), " bus set to ", value)


#func _on_value_changed(value: float) -> void:
	#AudioManager.set_db_value(sound_group, value)
	#var audio_players: Array[Node] = get_tree().get_nodes_in_group(sound_group)
	#for audio_player: Node in audio_players:
		#audio_player.volume_db = value
		#print(audio_player.name, " in sound group ", sound_group, " changed to ",
		#audio_player.volume_db, "db")
