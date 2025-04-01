extends SpriteBacklight

@onready var item_world_shader_material: ShaderMaterial = preload("item_world_shader_material.tres")

func _ready() -> void:
	super()
	material = material_override
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.next_pass = item_world_shader_material
