class_name Shrine
extends StaticBody3D

const TEXT_INACTIVE: String = "SHRINE\r---inactive---\nEnter the shrine\rto activate it"
const TEXT_ACTIVE: String = "SHRINE\r---ACTIVE---\nYou will revive here if this\ris the closest shrine"
const TEXT_CONSUMED: String = "SHRINE\r---CONSUMED---\nThis shrine cannot\rbe used anymore"
const TEXT_INTERACTABLE: String = "[E] Activate"

const TEXTURE: Texture2D = preload("res://map/rooms/shrine/shrine.png")
const TEXTURE_CONSUMED: Texture2D = preload("res://map/rooms/shrine/shrine_consumed.png")

@export var default: bool = false

# tracks if shrine has been reached and activated
@onready var activated: bool = false
# tracks if player has revived at this shrine
# for disallowing further revivals at this shrine
@onready var consumed: bool = false
# material duplicate for individually modifying material of each shrine
@onready var sprite_texture: Texture2D = $Sprite3D.texture
@onready var detector: Area3D = $PlayerDetector


func _ready() -> void:
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)
	$Interactable.input_detected.connect(_on_interaction)
	# for edge case of player reviving inside inactive shrine area
	SignalBus.player_revived.connect(_on_player_revived)
	
	# register the shrine with ShrineManager
	ShrineManager.register_shrine(self)
	
	reset()


func reset() -> void:
	consumed = false
	if default:
		activated = true
		#material.albedo_color = color_active
	else:
		activated = false
		#material.albedo_color = color_inactive
	
	$Interactable.inputs = ["interact"]
	$Interactable.hide_message()


func activate() -> void:
	activated = true
	# change color and text to show it is activated
	#material.albedo_color = color_active
	# remove input detection for interactable and hide message
	$Interactable.inputs.clear()
	$Interactable.hide_message()


func consume() -> void:
	if not default:
		consumed = true
		activated = false
		#material.albedo_color = color_consumed


func _on_body_entered(_body: Node3D) -> void:
	print("entered")
	print("consumed: ", consumed)
	print("activated: ", activated)
	# type-checking for player is unneeded as shrine collides on layer PLAYER
	if (not consumed 
		and not activated 
		and PlayerHandler.get_player_state() != PlayerStateMachine.States.DEAD):
		print("player can interact!")
		# display interaction text
		$Interactable.display_message(TEXT_INTERACTABLE)
		$Interactable.enabled = true


func _on_body_exited(_body: Node3D) -> void:
	# no guard check -> should always be non-interactable when player leaves
	# regardless of shrine and player states
	$Interactable.hide_message()
	$Interactable.enabled = false


func _on_interaction(input_name: String) -> void:
	if input_name == "interact":
		activate()


func _on_player_revived(_corpse_position: Vector3) -> void:
	# handle edge case of player reviving inside inactive shrine
	var player: Player = PlayerHandler.get_player()
	if detector.overlaps_body(player):
		_on_body_entered.call_deferred(player)
