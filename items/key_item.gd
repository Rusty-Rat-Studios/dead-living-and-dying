extends Item


# TODO: update and apply to relevant value
# could be ghost aggression
# could be player light range
const DEBUFF_MODIFIER: float = 0.25

# save starting room for item reset because the player
# reparents the key item to its inventory when picked up
# TODO: Later move the following code from base Item class
# to here -> only required for key item
#@onready var starting_room: Room = get_parent()


func _ready() -> void:
	super()


func _process(_delta: float) -> void:
	# TODO:
	# slowly moves the key item towards its original position
	# activated/deactivated when the key item is picked up or dropped
	pass


func reset() -> void:
	super()
	$Interactable.display_message("KEY ITEM")
	# TODO: Later move the following code from base Item class
	# to here -> only required for key item
	#if get_parent() != starting_room:
	#	reparent(starting_room)


func drop() -> void:
	# TODO: replace with enabling _process to "creep"
	# the key item back towards its starting location
	reset()
