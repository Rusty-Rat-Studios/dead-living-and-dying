extends Window

enum Screen { POSSESSION, STATES, MAP, KEY_ITEM }

const TEXT_TOPIC1: String = "Ghosts possess objects to attack you with."
const TEXT_TOPIC2: String = "You change state as you take damage."
const TEXT_TOPIC3: String = "Explore the map to find shrines and different items to help you along the way."
const TEXT_TOPIC4: String = "Collect and return the key item in each level to win."

const TEXT_POSSESSION1: String = "There are various objects around each room that ghosts can possess."
const TEXT_POSSESSION2: String = ("Ghosts can attack you with some of these possessed objects. "
	+ "Watch out for any objects acting strangely!")

const TEXT_STATE1: String = "LIVING: You cannot see ghosts and they can only attack you by possessing an object."
const TEXT_STATE2: String = "DYING: You move slower and can't see as far. Ghosts can directly attack you now."
const TEXT_STATE3: String = ("DEAD: Your spirit roams free! If a ghost reaches you it's game over. "
	+ "Make it back to where you died to return to the Living state.")

const TEXT_MAP1: String = ("Shrines are located around the map. "
	+ "When you die, your spirit appears at the nearest active shrine.")
const TEXT_MAP2: String = ("Shrines found in the map are consumed when you revive and can't be reactivated. "
	+ "Be sure to make your time alive count!")
const TEXT_MAP3: String = "Items can be found to provide defensive options or increase your stats."

const TEXT_KEY_ITEM1: String = "Find the Key Item and bring it back to the old man to complete the level."
const TEXT_KEY_ITEM2: String = "When the Key Item is picked up, you'll be getting a lot more attention from the ghosts."
const TEXT_KEY_ITEM3: String = ("If you die, the Key Item is dropped and begins to move back to its original location. "
	+ "Catch up to it before it gets too far!")

var image_possession1: Texture2D = load("res://src/ui/resources/how_to_play_possession.png")
var image_possession2: Texture2D = load("res://src/ui/resources/how_to_play_possession2.png")

var image_state1: Texture2D = load("res://src/ui/resources/how_to_play_state.png")
var image_state2: Texture2D = load("res://src/ui/resources/how_to_play_state2.png")
var image_state3: Texture2D = load("res://src/ui/resources/how_to_play_state3.png")

var image_map1: Texture2D = load("res://src/ui/resources/how_to_play_map.png")
var image_map2: Texture2D = load("res://src/ui/resources/how_to_play_map2.png")
var image_map3: Texture2D = load("res://src/ui/resources/how_to_play_map3.png")

var image_key_item1: Texture2D = load("res://src/ui/resources/how_to_play_key_item.png")
var image_key_item2: Texture2D = load("res://src/ui/resources/how_to_play_key_item2.png")
var image_key_item3: Texture2D = load("res://src/ui/resources/how_to_play_key_item3.png")

var images1: Array = [image_possession1, image_state1, image_map1, image_key_item1]
var images2: Array = [image_possession2, image_state2, image_map2, image_key_item2]
var images3: Array = [null, image_state3, image_map3, image_key_item3] # possession does not have a third image

var topics: Array = [TEXT_TOPIC1, TEXT_TOPIC2, TEXT_TOPIC3, TEXT_TOPIC4]

var instructions1: Array = [TEXT_POSSESSION1, TEXT_STATE1, TEXT_MAP1, TEXT_KEY_ITEM1]
var instructions2: Array = [TEXT_POSSESSION2, TEXT_STATE2, TEXT_MAP2, TEXT_KEY_ITEM2]
var instructions3: Array = ["", TEXT_STATE3, TEXT_MAP3, TEXT_KEY_ITEM3] # possession does not have a third image

var current_view: Screen = Screen.POSSESSION

@onready var topic: Label = $MenuBackground/MarginContainer/VBoxContainer/Topic

#gdlint:ignore = max-line-length
@onready var instructions_box: VBoxContainer = $MenuBackground/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer
@onready var image_box: HBoxContainer = instructions_box.get_node("HBoxImage")
@onready var instruction_box: HBoxContainer = instructions_box.get_node("HBoxLabel")

@onready var image1: TextureRect = image_box.get_node("TextureRect")
@onready var image2: TextureRect = image_box.get_node("TextureRect2")
@onready var image3: TextureRect = image_box.get_node("TextureRect3")

@onready var instruction1: Label = instruction_box.get_node("Instructions")
@onready var instruction2: Label = instruction_box.get_node("Instructions2")
@onready var instruction3: Label = instruction_box.get_node("Instructions3")

@onready var button_next: Button = $MenuBackground/MarginContainer/VBoxContainer/HboxButtons/ButtonNext
@onready var button_previous: Button = $MenuBackground/MarginContainer/VBoxContainer/HboxButtons/ButtonPrevious


func _ready() -> void:
	# on first screen, previous button closes the window
	# - update in code rather than editor so the editor has a "normal" view
	button_previous.text = "Close"
	
	button_next.pressed.connect(_on_next_pressed)
	button_previous.pressed.connect(_on_previous_pressed)
	visibility_changed.connect(func () -> void: button_next.grab_focus())


func reset() -> void:
	close_requested.emit()
	hide()
	current_view = 0
	image3.visible = false
	instruction3.visible = false
	button_previous.text = "Close"
	button_next.text = "Next"


func update_text_and_images() -> void:
	topic.text = topics[current_view]
	# update images
	image1.texture = images1[current_view]
	image2.texture = images2[current_view]
	image3.texture = images3[current_view]
	
	instruction1.text = instructions1[current_view]
	instruction2.text = instructions2[current_view]
	instruction3.text = instructions3[current_view]


func _on_next_pressed() -> void:
	match current_view:
		Screen.POSSESSION:
			current_view = Screen.STATES
			image3.visible = true
			instruction3.visible = true
			button_previous.text = "Previous"
		Screen.STATES:
			current_view = Screen.MAP
		Screen.MAP:
			current_view = Screen.KEY_ITEM
			button_next.text = "Close"
		Screen.KEY_ITEM:
			reset()
	
	update_text_and_images()


func _on_previous_pressed() -> void:
	match current_view:
		Screen.POSSESSION:
			reset()
		Screen.STATES:
			current_view = Screen.POSSESSION
			image3.visible = false
			instruction3.visible = false
			button_previous.text = "Close"
		Screen.MAP:
			current_view = Screen.STATES
		Screen.KEY_ITEM:
			current_view = Screen.MAP
			button_next.text = "Next"
	
	update_text_and_images()
