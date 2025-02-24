class_name PossessableThrowable
extends PossessableAttack

# impulse strength used to throw the object
const THROW_FORCE: float = 15.0
# impulse strength used to spin the object when picked up
const SPIN_FORCE_MIN: float = -0.2
const SPIN_FORCE_MAX: float = 0.2
# speed threshold for enabling/disabling hurtbox
const DAMAGE_VELOCITY: float = 2.0
# speed threshold for slowing down possessable when bumped while possessed
# used to avoid "floating away"
const SPEED_THRESHOLD: float = 1

# RANGE object rises/falls while possessed
const FLOAT_RANGE: float = 0.2
# speed at which the object oscillates
const FLOAT_SPEED: float = 2
# scalar for speed that the object is lifted
const FLOAT_FORCE: float = 1.4
# target height for possessed objects to float to
const FLOAT_HEIGHT: float = 4
# for timing float effect oscillation
@onready var float_time_offset: float = 0.0
@onready var hitbox: Area3D = $Hitbox
@onready var hitbox_collision_shape: CollisionShape3D = $Hitbox/CollisionShape3D

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# if object has been thrown, thus depossessed, it should not be possessable
	# again until object has slowed down enough
	if not is_possessable and linear_velocity.length() < DAMAGE_VELOCITY:
		# disable hurtbox when slow enough
		hitbox_collision_shape.set_deferred("disabled", true)
		# set flag to allow possession again
		is_possessable = true
	
	# animate object to "float" in the air
	if is_possessed:
		# record time difference of how far the object should have floated
		# up-and-down (FLOAT_RANGE) at it's peak height (float_height)
		float_time_offset += state.step * FLOAT_SPEED
		
		# add default on-the-floor height to floating height and add an
		# oscillating sine component to float above/below target height
		var target_height: float = starting_transform.origin.y + FLOAT_HEIGHT + FLOAT_RANGE * sin(float_time_offset)
		var current_height: float = position.y
		var height_diff: float = target_height - current_height
		
		# ensure no "downward" velocity applies; let gravity do it
		if height_diff > 0:
			# increase velocity exponentially proportional to the target/current height difference
			# --- higher increase if far from target, smaller increase if close to target
			state.linear_velocity.y = lerp(state.linear_velocity.y, height_diff**2 * FLOAT_FORCE, state.step)
		
		# get magnitude of xz-plane velocity
		var speed: float = Vector3(state.linear_velocity.x, 0, state.linear_velocity.z).length()
		# slow down possessed object if it is travelling above a given speed
		if speed > SPEED_THRESHOLD:
			state.linear_velocity.x = lerp(state.linear_velocity.x, 0.0, state.step)
			state.linear_velocity.z = lerp(state.linear_velocity.z, 0.0, state.step)


func possess() -> void:
	super()
	# apply small, random spin when possessed
	# side effect: brings _integrate_forces() out of sleep
	apply_torque_impulse(Vector3(randf_range(SPIN_FORCE_MIN, SPIN_FORCE_MAX), 
		randf_range(SPIN_FORCE_MIN, SPIN_FORCE_MAX), 
		randf_range(SPIN_FORCE_MIN, SPIN_FORCE_MAX)))


func attack(target: Node3D) -> void:
	if player_in_range and room.player_in_room:
		# disable player detection
		range_collision_shape.disabled = true
		# enable hurtbox
		hitbox_collision_shape.disabled = false
		# disallow re-possession during attack
		is_possessable = false
		# VIOLENTLY LAUNCH SELF TOWARDS PLAYER \m/
		apply_impulse(global_position.direction_to(target.global_position) * THROW_FORCE)
