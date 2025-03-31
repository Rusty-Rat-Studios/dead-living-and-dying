class_name KeyItemWorld
extends ItemWorld


func _ready() -> void:
	# initialize game.gd value to track key starting position when it is
	# re-created when dropped by the player
	if get_node("/root/Game").key_item_starting_position == Vector3.ZERO:
		get_node("/root/Game").key_item_starting_position = starting_position
	else:
		starting_position = get_node("/root/Game").key_item_starting_position
	super()


func _process(_delta: float) -> void:
	# TODO:
	# slowly moves the key item towards its original position
	# activated/deactivated when the key item is picked up or dropped
	pass


func reset() -> void:
	super()
	$Interactable.display_message("KEY ITEM")


func _on_body_exited(_body: Node3D) -> void:
	# override function to display "key item" message again instead of hiding message
	$Interactable.display_message("KEY ITEM")
	$Interactable.enabled = false
