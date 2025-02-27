class_name SpriteShaker
extends Resource

const MAX_OFFSET: float = 0.1
const FREQUENCY: float = 30

func animate(sprite: Sprite3D, duration: float, xy_magnitude: Vector2 = Vector2(1, 1)) -> void:
	var time_elapsed: float = 0.0
	var original_position: Vector3 = sprite.position
	var sprite_position: Vector3
	
	while time_elapsed < duration:
		# track sprite position as the parent object moves
		#sprite_position = sprite.get_parent().position + original_position
		var shake_offset: Vector3 = Vector3(
			randf_range(-MAX_OFFSET, MAX_OFFSET) * xy_magnitude.x,
			randf_range(-MAX_OFFSET, MAX_OFFSET) * xy_magnitude.y,
			0
		)
		shake_offset *= time_elapsed
		sprite.position = original_position + shake_offset
		await Utility.delay(1 / FREQUENCY)
		time_elapsed += 1 / FREQUENCY
		
	sprite.position = original_position
