class_name OldMan
extends StaticBody3D


var dialogue: Dictionary[String, Dictionary] = {
	"intro": {
		"prompt": "Hello dear, it's so nice to see you.",
		"responses": ["Hello Grandfather.NEXT"],
		"next_stage": "crucifix"
		},
	"crucifix": {
		"prompt": ("I wanted you to have this old crucifix of mine. I've had it for a long time\n" +
			"but I'd like you to take it as a 'thank you' for taking care of me. I hope it helps\n" +
			"you feel safe in this old home."),
		"responses": ["Thank you, I will take good care of it!NEXT"],
		"next_stage": "fetch"
		},
	"fetch": {
		"prompt": ("I've been missing my KEY_ITEM, it seems I've misplaced it. Could you be a\n" +
		"dear and go find it for me? It should be somewhere in this blasted maze of a house."),
		"responses": ["Of course, I'll be back with it as soon as I can.NEXT EXIT"],
		"next_stage": "return"
	},
	"return": {
		"prompt": "Have you found my KEY_ITEM yet?",
		"responses": [
			"Yes, I've got it here.NEXT KEY_ITEM",
			"Sorry, I haven't found it yet Grandpa.EXIT"
			],
		"next_stage": "return_success"
	},
	"return_success": {
		"prompt": "Oh how wonderful, thank you very much!",
		"responses": ["Your welcome!EXIT"]
	}
}

# used to instantiate crucifix to give to player when first talking to old man
var crucifix_scene: PackedScene = load("res://src/entity/items/crucifix/crucifix_world.tscn")

# reference to key item inventory instance - includes description, name, etc
var _key_item: KeyItemInventory
var _player_has_key_item: bool = false

var _dialogue_stage: String

var _door: Door

@onready var dialogue_popup: DialoguePopup = get_tree().root.get_node("Game/UI/DialoguePopup")

func _ready() -> void:
	$PlayerDetector.body_entered.connect(_on_player_entered)
	$PlayerDetector.body_exited.connect(_on_player_exited)
	$Interactable.input_detected.connect(_on_interaction)
	dialogue_popup.next_stage.connect(_on_response_selected)
	SignalBus.key_item_picked_up.connect(_on_key_item_picked_up)
	SignalBus.key_item_dropped.connect(_on_key_item_dropped)
	SignalBus.level_complete.connect(_on_level_complete)
	
	$Interactable.inputs = ["interact"]
	$Interactable.hide()
	$Interactable.enabled = false
	
	_door = get_parent().doors.values()[0]
	_door.lock(false)
	
	_dialogue_stage = "intro"


func reset() -> void:
	$Interactable.hide()
	$Interactable.enabled = false
	
	_dialogue_stage = "fetch"


func _on_player_entered(_player: Player) -> void:
	if PlayerHandler.get_player_state() != PlayerStateMachine.States.DEAD:
		$Interactable.show()
		$Interactable.enabled = true


func _on_player_exited(_player: Player) -> void:
	$Interactable.hide()
	$Interactable.enabled = false


func _on_interaction(input_name: String) -> void:
	if input_name == "interact":
		dialogue_popup.show_dialogue(dialogue[_dialogue_stage])
		$Speech.play_random_sound(true)


func _on_response_selected(next_stage: String) -> void:
	_dialogue_stage = next_stage
	$Speech.play_random_sound(true)
	
	match _dialogue_stage:
		"crucifix":
			var crucifix: ItemWorld = crucifix_scene.instantiate()
			crucifix.pick_up()
		"fetch":
			# unlock the door so the player can leave
			_door.unlock()
		"return_success":
			SignalBus.level_complete.emit()
	
	if dialogue_popup.visible:
		dialogue_popup.show_dialogue(dialogue[_dialogue_stage])


func _on_key_item_picked_up() -> void:
	_player_has_key_item = true


func _on_key_item_dropped() -> void:
	_player_has_key_item = false


func _on_level_complete() -> void:
	_player_has_key_item = false
