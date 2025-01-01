class_name Shrine
extends Area3D

const TEXT_INACTIVE: String = "SHRINE\r---inactive---\nEnter the shrine\rto activate it"
const TEXT_ACTIVE: String = "SHRINE\r---ACTIVE---\nYou will revive here if this\ris the closest shrine"
const TEXT_CONSUMED: String = "SHRINE\r---CONSUMED---\nThis shrine cannot\rbe used anymore"
#const TEXT_INTERACTABLE: String = "SHRINE\r---inactive---\nPress 'E' to activate"
const TEXT_INTERACTABLE: String = "[E] Activate"

# tracks if shrine has been reached and activated
@onready var activated: bool = false
# tracks whether player is in range to interact with shrine
@onready var interactable: bool = false
# tracks if player has revived at this shrine
# disallows further revivals at this shrine
@onready var consumed: bool = false
# set only for beginning shrine
@onready var default: bool = false
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
	
	# apply material to shrine
	$MeshInstance3D.set_surface_override_material(0, material)
	reset()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and interactable and not activated:
		activate()


func reset() -> void:
	$Interactable.inputs = ["interact"]
	$Interactable.input_detected.connect(activate)
	activated = false
	consumed = false
	material.albedo_color = color_inactive
	#$Label3D.text = TEXT_INACTIVE
	$Interactable.display_message(TEXT_INACTIVE)


func activate() -> void:
	activated = true
	# change color and text to show it is activated
	material.albedo_color = color_active
	#$Label3D.text = TEXT_ACTIVE
	$Interactable.display_message(TEXT_ACTIVE)
	SignalBus.activated_shrine.emit(self)
	# remove input detection for interactable
	$Interactable.inputs.clear()


func consume() -> void:
	if not default:
		consumed = true
		activated = false
		material.albedo_color = color_consumed
		$Interactable.display_message(TEXT_CONSUMED)
		#$Label3D.text = TEXT_CONSUMED
		SignalBus.consumed_shrine.emit(self)


func _on_body_entered(_body: Node3D) -> void:
	# type-checking for player is unneeded as shrine collides on layer PLAYER
	if not consumed and not activated and PlayerHandler.get_player_state() != "Dead":
		#activate()
		$Interactable.display_message(TEXT_INTERACTABLE)
		#$Label3D.text = TEXT_INTERACTABLE
		interactable = true


func _on_body_exited(_body: Node3D) -> void:
	# no guard check -> should always be non-interactable when player leaves
	# regardless of shrine and player states
	interactable = false
	
	if activated:
		$Interactable.display_message(TEXT_ACTIVE)
		#$Label3D.text = TEXT_ACTIVE
	elif consumed:
		$Interactable.display_message(TEXT_CONSUMED)
		#$Label3D.text = TEXT_CONSUMED
	else:
		$Interactable.display_message(TEXT_INACTIVE)
		#$Label3D.text = TEXT_INACTIVE
