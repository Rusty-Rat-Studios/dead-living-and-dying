class_name SpriteShaker
extends Resource

"""
SpriteShaker operates on the animate() function which "shakes" the provided sprite
along to xy-plane for the provided duration. Optionally, a 2D vector can be provided
to specify the intensity it shakes along each axis - e.g. providing xy_magnitude = 
Vector2(1, 0) would only shake the sprite along the x-axis. The animate() function
operates on the local position of the sprite and resets it once finished, allowing
it to follow its parent object appropriately if it is moved during the animation.

There is an additional "halt_requested" variable set by the halt() function that
MUST be called any time the shaker is interrupted or cancelled to stop the animation
immediately.
"""

const MAX_OFFSET: float = 0.1
const FREQUENCY: float = 30

# variable to be set if something occurs that must halt the shaking, such
# as a ghost changing state due to the player changing state
var halt_requested: bool = false

func animate(sprite: SpriteBase3D, duration: float, xy_magnitude: Vector2 = Vector2(1, 1)) -> void:
	var time_elapsed: float = 0.0
	var original_position: Vector3 = sprite.position
	var sprite_position: Vector3
	
	halt_requested = false
	
	while time_elapsed < duration and not halt_requested:
		# track sprite position as the parent object moves
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
	
	# reset halt signal to allow sprite shaker to operate next call
	halt_requested = false


func halt() -> void:
	halt_requested = true
