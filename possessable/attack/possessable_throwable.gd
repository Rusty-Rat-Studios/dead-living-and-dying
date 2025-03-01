class_name PossessableThrowable
extends PossessableAttack

# impulse strength used to throw the object
const THROW_FORCE: float = 15.0
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
const FLOAT_FORCE: float = 1
# target height for possessed objects to float to
const FLOAT_HEIGHT: float = 4
# how long the shake animation is displayed before attacking
const ATTACK_WINDUP: float = 2
# how much the shake animation moves in x or y dimensions
const ATTACK_SHAKE_MAGNITUDE: Vector2 = Vector2(1, 0.5)

# for timing float effect oscillation
@onready var float_time_offset: float = 0.0
@onready var base_height: float = parent.position.y
@onready var hitbox: Area3D = $Hitbox
@onready var hitbox_collision_shape: CollisionShape3D = $Hitbox/CollisionShape3D

# used to animate sprite for attack
@onready var sprite_shaker: SpriteShaker = SpriteShaker.new()

func _ready() -> void:
	super()
	
	# disable physics process - re-enabled by possess()
	set_physics_process(false)
	
	# instantiate hitbox as a slightly larger duplicate of parent collision shape
	# to guarantee hitbox collision is detected before physics collision
	hitbox_collision_shape.shape = parent.get_node("CollisionShape3D").shape.duplicate()
	if hitbox_collision_shape.shape is not CylinderShape3D:
		push_error("ERROR: possessable throwable initialized as child of non-cylinder collision shape.",
			"Throwable objects must have a CylinderShape3D collision shape.")
		return
	hitbox_collision_shape.shape.height *= 1.1
	hitbox_collision_shape.shape.radius *= 1.1


func _physics_process(delta: float) -> void:
	# if object has been thrown, thus depossessed, it should not be possessable
	# again until object has slowed down enough
	if not is_possessable and not is_possessed and parent.linear_velocity.length() < DAMAGE_VELOCITY:
		# disable hurtbox when slow enough
		hitbox_collision_shape.set_deferred("disabled", true)
		# set flag to allow possession again
		is_possessable = true
		float_time_offset = 0
		# disable physics process - re-enabled by possess()
		set_physics_process(false)
	
	# animate object to "float" in the air
	if is_possessed:
		# record time difference of how far the object should have floated
		# up-and-down (FLOAT_RANGE) at it's peak height (float_height)
		float_time_offset += delta * FLOAT_SPEED
		
		# add default on-the-floor height to floating height and add an
		# oscillating sine component to float above/below target height
		var target_height: float = base_height + FLOAT_HEIGHT + FLOAT_RANGE * sin(float_time_offset)
		var current_height: float = parent.position.y
		var height_diff: float = target_height - current_height
		
		# ensure no "downward" velocity applies; let gravity do it
		if height_diff > 0:
			# increase velocity exponentially proportional to the target/current height difference
			# --- higher increase if far from target, smaller increase if close to target
			parent.linear_velocity.y = lerp(parent.linear_velocity.y, height_diff**2 * FLOAT_FORCE, delta)
		
		# get magnitude of xz-plane velocity
		var speed: float = Vector3(parent.linear_velocity.x, 0, parent.linear_velocity.z).length()
		# slow down possessed object if it is travelling above a given speed
		if speed > SPEED_THRESHOLD:
			parent.linear_velocity.x = lerp(parent.linear_velocity.x, 0.0, delta)
			parent.linear_velocity.z = lerp(parent.linear_velocity.z, 0.0, delta)


func possess() -> void:
	super()
	# enable physics processing - disabled along with hitbox when slow enough
	set_physics_process(true)


func depossess() -> void:
	super()
	# force sprite shaker to stop if object depossessed mid-attack
	sprite_shaker.halt()


func attack(target: Node3D) -> void:
	if player_in_range and room.player_in_room:
		# disable player detection
		range_collision_shape.disabled = true
		# enable hurtbox
		hitbox_collision_shape.disabled = false
		# disallow re-possession during attack
		is_possessable = false
		
		# display "wind-up" to attack
		await sprite_shaker.animate(parent.get_node("Sprite3D"), ATTACK_WINDUP, ATTACK_SHAKE_MAGNITUDE)
		
		# check again that object wasn't depossessed mid-attack
		if is_possessed:
			# VIOLENTLY LAUNCH SELF TOWARDS PLAYER \m/
			parent.apply_impulse(global_position.direction_to(target.global_position) * THROW_FORCE)
	
	depossess()
