class_name OldMan
extends StaticBody3D

var player_has_key_item: bool = false

func _ready() -> void:
	$PlayerDetector.body_entered.connect(_on_player_entered)
	$PlayerDetector.body_exited.connect(_on_player_exited)
	$Interactable.input_detected.connect(_on_interaction)
	SignalBus.key_item_picked_up.connect(_on_key_item_picked_up)
	SignalBus.key_item_dropped.connect(_on_key_item_dropped)
	
	$Interactable.inputs = ["interact"]
	reset()


func reset() -> void:
	$Interactable.hide_message()
	$Interactable.enabled = false


func _on_player_entered(_player: Player) -> void:
	if PlayerHandler.get_player_state() != PlayerStateMachine.States.DEAD:
		if player_has_key_item:
			$Interactable.display_message("[E] Give [KEY_ITEM]")
			$Interactable.enabled = true
		else:
			$Interactable.display_message("Bring me the [KEY ITEM]")


func _on_player_exited(_player: Player) -> void:
	$Interactable.hide_message()
	$Interactable.enabled = false


func _on_interaction(input_name: String) -> void:
	if input_name == "interact" and player_has_key_item:
		SignalBus.level_complete.emit()


func _on_key_item_picked_up() -> void:
	player_has_key_item = true


func _on_key_item_dropped() -> void:
	player_has_key_item = false
