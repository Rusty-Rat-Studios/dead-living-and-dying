extends Sprite3D

var material: StandardMaterial3D = StandardMaterial3D.new()


func _ready() -> void:
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.backlight_enabled = true
	material.backlight = Color.WHITE
	material.specular_mode = StandardMaterial3D.SPECULAR_DISABLED
	material.uv1_scale = scale
	
	material.albedo_texture = texture
	material_override = material
	
	cast_shadow =GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func replace_texture(new_texture: Texture2D) -> void:
	texture = new_texture
	material.albedo_texture = texture
