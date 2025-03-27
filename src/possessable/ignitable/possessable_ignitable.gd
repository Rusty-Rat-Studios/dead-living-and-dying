extends Possessable

@export var player_detector: Area3D
var lit: bool = false


func _ready() -> void:
	super()
	player_detector.body_entered.connect(_on_body_entered)
	player_detector.body_entered.connect(_on_body_exited)
	$Interactable.input_detected.connect(_on_interaction)
	reset()


func reset() -> void:
	$Interactable.inputs = ["interact"]
	$Interactable.hide_message()
	$Interactable.enabled = false
	snuff()


func attack(_target: Node3D) -> void:
	snuff()


func ignite() -> void:
	$FireParticles.emitting = true
	$FireParticles.visible = true


func snuff() -> void:
	$FireParticles.emitting = false
	$FireParticles.visible = false


func _on_interaction(input_name: String) -> void:
	if input_name == "interact":
		if lit:
			snuff()
		else:
			ignite()


func _on_body_entered(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	if lit:
		$Interactable.display_message("[E] Snuff")
	else:
		$Interactable.display_message("[E] Ignite")
	$Interactable.enabled = true


func _on_body_exited(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	$Interactable.hide_message()
	$Interactable.enabled = false
