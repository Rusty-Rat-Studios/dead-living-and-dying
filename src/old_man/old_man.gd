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
		"prompt": ("I've been missing my [KEY_ITEM], it seems I've misplaced it. Could you be a\n" +
		"dear and go find it for me? It should be somewhere in this blasted maze of a house."),
		"responses": ["Of course, I'll be back with it as soon as I can.NEXT EXIT"],
		"next_stage": "return"
	},
	"return": {
		"prompt": "Have you found my [KEY_ITEM] yet?",
		"responses": [
			"Yes, I've got it here.NEXT KEY_ITEM",
			"Sorry, I haven't found it yet Grandpa.EXIT"
			],
		"next_stage": "return_success"
	},
	"return_success": {
		"prompt": "Oh how wonderful, thank you very much! Here, I found this while you were gone\n" +
		"and I think you should have it. Go on, take it.",
		"responses": ["Thank you!EXIT"]
	}
}

# used to instantiate crucifix to give to player when first talking to old man
var crucifix_scene: PackedScene = load("res://src/entity/items/crucifix/crucifix_world.tscn")

# reference to key item inventory instance - includes description, name, etc
var _key_item: KeyItemInventory
var _player_has_key_item: bool = false

var _dialogue_stage: String

@onready var dialogue_popup: DialoguePopup = get_tree().root.get_node("Game/UI/DialoguePopup")

func _ready() -> void:
	$PlayerDetector.body_entered.connect(_on_player_entered)
	$PlayerDetector.body_exited.connect(_on_player_exited)
	$Interactable.input_detected.connect(_on_interaction)
	dialogue_popup.next_stage.connect(_on_response_selected)
	SignalBus.key_item_picked_up.connect(_on_key_item_picked_up)
	SignalBus.key_item_dropped.connect(_on_key_item_dropped)
	
	$Interactable.inputs = ["interact"]
	$Interactable.hide_message()
	$Interactable.enabled = false
	
	_dialogue_stage = "intro"


# called by game.gd and passed in the current level's key item
# to initialize old man's reference to key item
func init(key_item: KeyItemInventory) -> void:
	_key_item = key_item


func reset() -> void:
	$Interactable.hide_message()
	$Interactable.enabled = false
	_dialogue_stage = "fetch"


func _on_player_entered(_player: Player) -> void:
	if PlayerHandler.get_player_state() != PlayerStateMachine.States.DEAD:
		$Interactable.display_message("[E] Talk")
		$Interactable.enabled = true


func _on_player_exited(_player: Player) -> void:
	$Interactable.hide_message()
	$Interactable.enabled = false


func _on_interaction(input_name: String) -> void:
	if input_name == "interact":
		dialogue_popup.show_dialogue(dialogue[_dialogue_stage])
	#if input_name == "interact" and player_has_key_item:
	#	SignalBus.level_complete.emit()


func _on_response_selected(next_stage: String) -> void:
	print("response selected:", next_stage)
	_dialogue_stage = next_stage
	
	match _dialogue_stage:
		"crucifix":
			var crucifix: ItemWorld = crucifix_scene.instantiate()
			crucifix.pick_up()
		"return_success":
			SignalBus.level_complete.emit()
	
	if dialogue_popup.visible:
		dialogue_popup.show_dialogue(dialogue[_dialogue_stage])


func _on_key_item_picked_up() -> void:
	_player_has_key_item = true


func _on_key_item_dropped() -> void:
	_player_has_key_item = false
