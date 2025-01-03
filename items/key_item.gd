extends Area3D


# TODO: update and apply to relevant value
# could be ghost aggression
# could be player light range
const DEBUFF_MODIFIER: float = 0.25

# save starting position to reset to on player death
@onready var starting_position: Vector3 = global_position
# save starting room for item reset because the player
# reparents the key item to its inventory when picked up
@onready var starting_room: Room = get_parent()

var picked_up: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PlayerDetector.body_entered.connect(_on_body_entered)
	$Interactable.input_detected.connect(_on_interaction)
	
	reset()


func _process(_delta: float) -> void:
	# TODO:
	# slowly moves the key item towards its original position
	# activated/deactivated when the key item is picked up or dropped
	pass


func reset() -> void:
	$Interactable.inputs = ["interact"]
	$Interactable.hide_message()
	$Interactable.enabled = false
	global_position = starting_position
	picked_up = false
	visible = true
	if get_parent() != starting_room:
		self.reparent(starting_room)


func pick_up() -> void:
	# adds itself as a child to the parent node
	# to be called by the player, passing its inventory 
	SignalBus.item_picked_up.emit(self)
	picked_up = true
	visible = false


func drop() -> void:
	# TODO: replace with enabling _process to "creep"
	# the key item back towards its starting location
	reset()


func _on_body_entered(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	if PlayerHandler.get_player_state() != "Dead":
		$Interactable.display_message("[E] Pick Up")
		$Interactable.enabled = true


func _on_body_exited(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	$Interactable.hide_message()
	$Interactable.enabled = false


func _on_interaction(input_name: String) -> void:
	if input_name == "interact":
		pick_up()
