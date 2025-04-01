extends SpriteBacklight

func _ready() -> void:
	super()
	material = material_override
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
