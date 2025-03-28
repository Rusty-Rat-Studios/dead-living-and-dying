extends Possessable

@export var player_detector: Area3D
@export var fire: GPUParticles3D
var lit: bool = false


func _ready() -> void:
	super()
	player_detector.body_entered.connect(_on_body_entered)
	player_detector.body_exited.connect(_on_body_exited)
	$Interactable.input_detected.connect(_on_interaction)
	reset()


func reset() -> void:
	$Interactable.inputs = ["interact"]
	$Interactable.hide_message()
	$Interactable.enabled = false
	snuff()


func attack(_target: Node3D) -> void:
	snuff()
	depossess()


func possess() -> void:
	if not lit:
		return
	super()


func ignite() -> void:
	lit = true
	fire.emitting = true
	fire.visible = true


func snuff() -> void:
	lit = false
	fire.emitting = false
	fire.visible = false


func _on_interaction(input_name: String) -> void:
	if input_name == "interact":
		if lit:
			snuff()
		else:
			ignite()
		update_interactable()


func _on_body_entered(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	update_interactable()
	$Interactable.enabled = true


func update_interactable() -> void:
	if lit:
		$Interactable.display_message("[E] Snuff")
	else:
		$Interactable.display_message("[E] Ignite")


func _on_body_exited(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	$Interactable.hide_message()
	$Interactable.enabled = false
