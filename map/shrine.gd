class_name Shrine
extends Area3D

# tracks if shrine has been reached and activated
@onready var activated: bool = false
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
	
	# apply material to shrine
	$MeshInstance3D.set_surface_override_material(0, material)
	reset()


func reset() -> void:
	activated = false
	consumed = false
	material.albedo_color = color_inactive
	$Label3D.text = "SHRINE\r---inactive---\nEnter the shrine\rto activate it"


func activate() -> void:
	activated = true
	material.albedo_color = color_active
	$Label3D.text = "SHRINE\r---ACTIVE---\nYou will revive here if this\ris the closest shrine"
	SignalBus.emit_signal("activated_shrine", self)


func consume() -> void:
	if not default:
		consumed = true
		material.albedo_color = color_consumed
		$Label3D.text = "SHRINE\r---CONSUMED---\nThis shrine cannot\rbe used anymore"
		SignalBus.emit_signal("consumed_shrine", self)


func _on_body_entered(_body: Node3D) -> void:
	# type-checking for player is unneeded as shrine collides on layer PLAYER
	if not consumed and not activated and PlayerHandler.get_player_state() != "Dead":
		activate()
