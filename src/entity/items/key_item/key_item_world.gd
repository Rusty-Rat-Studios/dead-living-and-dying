class_name KeyItemWorld
extends ItemWorld

var starting_room: Room
var movement_path: Array


func _ready() -> void:
	starting_room = get_parent()
	KeyItemHandler.register_key_item(self)
	
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


func pick_up() -> void:
	if inventory_resource == null:
		#gdlint:ignore=max-line-length
		push_error("AbstractVariableError: ItemWorld base class function pick_up() called without initializing variable 'inventory_resource'")
		return
	
	# emits a signal caught by the player who then adds a child
	# of the inventory resource version to its $Inventory node
	var item_inventory: ItemInventory = inventory_resource.instantiate()
	var player: Node = PlayerHandler.get_player()
	item_inventory.texture = $Sprite3D.texture
	
	SignalBus.item_picked_up.emit(item_inventory, false)
	#queue_free()
	visible = false


func _on_body_exited(_body: Node3D) -> void:
	# override function to display "key item" message again instead of hiding message
	$Interactable.display_message("KEY ITEM")
	$Interactable.enabled = false
