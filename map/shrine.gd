class_name Shrine
extends Area3D

const TEXT_INACTIVE: String = "SHRINE\r---inactive---\nEnter the shrine\rto activate it"
const TEXT_ACTIVE: String = "SHRINE\r---ACTIVE---\nYou will revive here if this\ris the closest shrine"
const TEXT_CONSUMED: String = "SHRINE\r---CONSUMED---\nThis shrine cannot\rbe used anymore"
const TEXT_INTERACTABLE: String = "[E] Activate"

@export var default: bool = false

# tracks if shrine has been reached and activated
@onready var activated: bool = false
# tracks if player has revived at this shrine
# for disallowing further revivals at this shrine
@onready var consumed: bool = false
# material duplicate for individually modifying material of each shrine
@onready var material: Material = $MeshInstance3D.get_active_material(0).duplicate()
# medium green
@onready var color_inactive: Color = Color(0.1, 0.4, 0.1, 0.25)
# bright green
@onready var color_active: Color = Color(0.1, 1, 0.1, 0.25)
# dark grey
@onready var color_consumed: Color = Color(0.1, 0.1, 0.1, 0.25)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Interactable.input_detected.connect(_on_interaction)
	# for edge case of player reviving inside inactive shrine area
	SignalBus.player_revived.connect(_on_player_revived)
	
	# apply material to shrine
	$MeshInstance3D.set_surface_override_material(0, material)
	
	# register the shrine with ShrineManager
	ShrineManager.register_shrine(self)
	
	reset()


func reset() -> void:
	consumed = false
	if default:
		$Label3D.text = TEXT_ACTIVE
		activated = true
		material.albedo_color = color_active
	else:
		$Label3D.text = TEXT_INACTIVE
		activated = false
		material.albedo_color = color_inactive
	
	$Interactable.inputs = ["interact"]
	$Interactable.hide_message()


func activate() -> void:
	activated = true
	# change color and text to show it is activated
	material.albedo_color = color_active
	$Label3D.text = TEXT_ACTIVE
	$Label3D.visible = true
	# remove input detection for interactable and hide message
	$Interactable.inputs.clear()
	$Interactable.hide_message()


func consume() -> void:
	if not default:
		consumed = true
		activated = false
		material.albedo_color = color_consumed
		$Label3D.text = TEXT_CONSUMED


func _on_body_entered(_body: Node3D) -> void:
	# type-checking for player is unneeded as shrine collides on layer PLAYER
	if not consumed and not activated and PlayerHandler.get_player_state() != "Dead":
		$Label3D.visible = false
		# display interaction text
		$Interactable.display_message(TEXT_INTERACTABLE)
		$Interactable.enabled = true


func _on_body_exited(_body: Node3D) -> void:
	# no guard check -> should always be non-interactable when player leaves
	# regardless of shrine and player states
	$Label3D.visible = true
	$Interactable.hide_message()
	$Interactable.enabled = false
	
	if activated:
		$Label3D.text = TEXT_ACTIVE
	elif consumed:
		$Label3D.text = TEXT_CONSUMED
	else:
		$Label3D.text = TEXT_INACTIVE


func _on_interaction(input_name: String) -> void:
	if input_name == "interact":
		activate()


func _on_player_revived(_corpse_position: Vector3) -> void:
	# handle edge case of player reviving inside inactive shrine
	var player: Player = PlayerHandler.get_player()
	if self.overlaps_body(player):
		_on_body_entered.call_deferred(player)
