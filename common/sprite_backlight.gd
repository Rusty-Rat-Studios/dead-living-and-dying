extends Sprite3D


func _ready() -> void:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.backlight_enabled = true
	material.backlight = Color.WHITE
	material.billboard_mode = StandardMaterial3D.BILLBOARD_FIXED_Y
	material.specular_mode = StandardMaterial3D.SPECULAR_DISABLED
	material.uv1_scale = scale
	
	material.albedo_texture = texture
	material_override = material
