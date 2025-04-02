class_name Shrine
extends StaticBody3D

const TEXTURE: Texture2D = preload("res://src/map/room_components/shrine/shrine.png")
const TEXTURE_CONSUMED: Texture2D = preload("res://src/map/room_components/shrine/shrine_consumed.png")

const LIGHT_ENERGY: float = 2
const TWEEN_DURATION: float = 1

@export var default: bool = false

# tracks if shrine has been reached and activated
@onready var activated: bool = false
# tracks if player has revived at this shrine
# for disallowing further revivals at this shrine
@onready var consumed: bool = false
@onready var detector: Area3D = $PlayerDetector
@onready var respawn_point: Vector3 = $RespawnPoint.global_position


func _ready() -> void:
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)
	$Interactable.input_detected.connect(_on_interaction)
	# for edge case of player reviving inside inactive shrine area
	SignalBus.player_revived.connect(_on_player_revived)
	
	# register the shrine with ShrineManager
	ShrineManager.register_shrine(self)
	
	reset()


# TEMPORARY - to be removed once map generation complete
func reset() -> void:
	consumed = false
	$Sprite3D.replace_texture(TEXTURE)
	
	if default:
		activated = true
		enable_effects()
	else:
		activated = false
		disable_effects()
	
	$Interactable.inputs = ["interact"]
	$Interactable.hide()


func enable_effects() -> void:
	$FountainParticles.emitting = true
	$FireParticles.emitting = true
	$FireParticles2.emitting = true
	$OmniLight3D.visible = true
	
	var light_tween: Tween = create_tween().set_parallel()
	light_tween.tween_property($FireParticles/SpotLight3D, "light_energy", LIGHT_ENERGY, TWEEN_DURATION)
	light_tween.tween_property($FireParticles2/SpotLight3D, "light_energy", LIGHT_ENERGY, TWEEN_DURATION)


func disable_effects() -> void:
	$FountainParticles.emitting = false
	$FireParticles.emitting = false
	$FireParticles2.emitting = false
	$OmniLight3D.visible = false
	
	var light_tween: Tween = create_tween().set_parallel()
	light_tween.tween_property($FireParticles/SpotLight3D, "light_energy", 0, TWEEN_DURATION)
	light_tween.tween_property($FireParticles2/SpotLight3D, "light_energy", 0, TWEEN_DURATION)


func activate() -> void:
	activated = true
	# change color and text to show it is activated
	enable_effects()
	# remove input detection for interactable and hide message
	$Interactable.inputs.clear()
	$Interactable.hide()


func consume() -> void:
	if not default:
		consumed = true
		activated = false
		disable_effects()
		$Sprite3D.replace_texture(TEXTURE_CONSUMED)


func _on_body_entered(_body: Node3D) -> void:
	# type-checking for player is unneeded as shrine collides on layer PLAYER
	if (not consumed 
		and not activated 
		and PlayerHandler.get_player_state() != PlayerStateMachine.States.DEAD):
		# display interaction text
		$Interactable.show()
		$Interactable.enabled = true


func _on_body_exited(_body: Node3D) -> void:
	# no guard check -> should always be non-interactable when player leaves
	# regardless of shrine and player states
	$Interactable.hide()
	$Interactable.enabled = false


func _on_interaction(input_name: String) -> void:
	if input_name == "interact":
		activate()


func _on_player_revived() -> void:
	# handle edge case of player reviving inside inactive shrine
	var player: Player = PlayerHandler.get_player()
	if detector.overlaps_body(player):
		_on_body_entered.call_deferred(player)
