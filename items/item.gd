class_name Item
extends Node3D

# save starting position to reset to on game over
@onready var starting_position: Vector3 = global_position

# TODO: Later move this to only key_item.gd - only needed here for reset()
# on game-over while maps and items are not dynamically generated
@onready var starting_room: Room = get_parent()

func _ready() -> void:
	$PlayerDetector.body_entered.connect(_on_body_entered)
	$PlayerDetector.body_exited.connect(_on_body_exited)
	$Interactable.input_detected.connect(_on_interaction)
	reset()


func reset() -> void:
	$Interactable.inputs = ["interact"]
	$Interactable.hide_message()
	$Interactable.enabled = false
	global_position = starting_position
	visible = true
	# TODO: Later move this to only key_item.gd
	if get_parent() != starting_room:
		reparent(starting_room)


func pick_up() -> void:
	# emits a signal caught by the player who then reparents
	# this node to its $Inventory node
	SignalBus.item_picked_up.emit(self)
	$Interactable.enabled = false
	visible = false


func _on_body_entered(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	if PlayerHandler.get_player_state() != PlayerStateMachine.States.DEAD:
		$Interactable.display_message("[E] Pick Up")
		$Interactable.enabled = true


func _on_body_exited(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	$Interactable.hide_message()
	$Interactable.enabled = false


func _on_interaction(input_name: String) -> void:
	if input_name == "interact":
		pick_up()
