extends Possessable

signal changed(lit: bool)

const SFX_IGNITE: AudioStream = preload("res://src/sound/objects/ignitable/match-strike.mp3")
const SFX_SNUFF: AudioStream = preload("res://src/sound/objects/ignitable/blow_out.mp3")

@export_range(0, 1, 0.001) var begin_lit_chance: float = 0.5
@export var player_detector: Area3D
@export var fire: GPUParticles3D
var lit: bool = false

@onready var sfx: AudioStreamPlayer3D = $SFX


func _ready() -> void:
	super()
	player_detector.body_entered.connect(_on_body_entered)
	player_detector.body_exited.connect(_on_body_exited)
	$Interactable.input_detected.connect(_on_interaction)
	reset()


func reset() -> void:
	$Interactable.inputs = ["interact"]
	$Interactable.hide()
	$Interactable.enabled = false
	if(RNG.rng.randf() < begin_lit_chance):
		ignite()
	else:
		snuff()


func attack(_target: Node3D, _attack_windup: float) -> void:
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
	if not sfx.stream == SFX_IGNITE:
		sfx.stream = SFX_IGNITE
	AudioManager.play_modulated(sfx)
	changed.emit(lit)


func snuff() -> void:
	lit = false
	fire.emitting = false
	fire.visible = false
	if not sfx.stream == SFX_SNUFF:
		sfx.stream = SFX_SNUFF
	AudioManager.play_modulated(sfx)
	changed.emit(lit)


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


func update_interactable() -> void:
	if lit:
		$Interactable.show()
		$Interactable.enabled = true
	else:
		if PlayerHandler.get_player_state() == PlayerStateMachine.States.DEAD:
			$Interactable.hide()
			$Interactable.enabled = false
		else:
			$Interactable.show()
			$Interactable.enabled = true


func _on_body_exited(_body: Node3D) -> void:
	# no node check required as collision mask is layer PLAYER
	$Interactable.hide()
	$Interactable.enabled = false
