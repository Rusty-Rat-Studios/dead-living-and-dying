class_name ItemWorld
extends Node3D

# to be set by inheritors as a reference to their in-world partner version
@export var inventory_resource: Resource
# save starting position to reset to on game over
@onready var starting_position: Vector3 = global_position


func _ready() -> void:
	$PlayerDetector.body_entered.connect(_on_body_entered)
	$PlayerDetector.body_exited.connect(_on_body_exited)
	$Interactable.input_detected.connect(_on_interaction)
	reset()


func reset() -> void:
	$Interactable.inputs = ["interact"]
	$Interactable.hide()
	$Interactable.enabled = false
	global_position = starting_position


func pick_up() -> void:
	if inventory_resource == null:
		#gdlint:ignore=max-line-length
		push_error("AbstractVariableError: ItemWorld base class function pick_up() called without initializing variable 'inventory_resource'")
		return
	
	# emits a signal caught by the player who then adds a child
	# of the inventory resource version to its $Inventory node
	var item_inventory: ItemInventory = inventory_resource.instantiate()
	var player: Node = PlayerHandler.get_player()
	var current_consumable: bool = false
	item_inventory.texture = $Sprite3D.texture
	if item_inventory is not PassiveItemInventory:
		for n: Node in player.get_node("Inventory").get_children():
			if n is ActiveItemInventory and item_inventory is ActiveItemInventory:
				n.drop()
			if n is DefenseItemInventory and item_inventory is DefenseItemInventory:
				n.drop()
	SignalBus.item_picked_up.emit(item_inventory, current_consumable)
	queue_free()


func disable_interactable(duration: int) -> void:
	$PlayerDetector/CollisionShape3D.disabled = true
	await Utility.delay(duration)
	$PlayerDetector/CollisionShape3D.disabled = false


func _on_body_entered(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	if PlayerHandler.get_player_state() != PlayerStateMachine.States.DEAD:
		$Interactable.show()
		$Interactable.enabled = true


func _on_body_exited(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	$Interactable.hide()
	$Interactable.enabled = false


func _on_interaction(input_name: String) -> void:
	if input_name == "interact":
		pick_up()
