extends RigidBody3D

@onready var hit_sfx: AudioStreamMultiple = $Hit


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(_body: Node3D) -> void:
	print("crate detected collision")
	hit_sfx.play_random_sound()
