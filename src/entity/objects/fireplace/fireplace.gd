extends StaticBody3D


func _ready() -> void:
	$Ignitable.changed.connect(_on_snuffed)


func _on_snuffed(lit: bool) -> void:
	if lit:
		$Fire.play()
	else:
		$Fire.stop()
