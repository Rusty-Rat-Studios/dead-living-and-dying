class_name PossessableThrowable
extends PossessableAttack

signal thrown

# impulse strength used to throw the object
const THROW_FORCE: float = 15.0
# speed threshold for enabling/disabling hurtbox
const DAMAGE_VELOCITY: float = 6.0
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
# how much the shake animation moves in x or y dimensions
const ATTACK_SHAKE_MAGNITUDE: Vector2 = Vector2(1, 0.5)

const HITBOX_COLLISION_SHAPE_EXPANSION_FACTOR: float = 1.2

# for timing float effect oscillation
@onready var float_time_offset: float = 0.0
@onready var base_height: float = parent.position.y
@onready var hitbox: Area3D = $Hitbox
@onready var hitbox_collision_shape: CollisionShape3D = $Hitbox/CollisionShape3D

# used to animate sprite for attack
@onready var sprite_shaker: SpriteShaker = SpriteShaker.new()

@onready var throw_sfx: AudioStreamMultiple = $Throw

func _ready() -> void:
	super()
	
	# disable physics process - re-enabled by possess()
	set_physics_process(false)
	
	# instantiate hitbox as a slightly larger duplicate of parent collision shape
	# to guarantee hitbox collision is detected before physics collision
	hitbox_collision_shape.shape = parent.get_node("CollisionShape3D").shape.duplicate()
	if hitbox_collision_shape.shape is CylinderShape3D:
		hitbox_collision_shape.shape.height *= HITBOX_COLLISION_SHAPE_EXPANSION_FACTOR
		hitbox_collision_shape.shape.radius *= HITBOX_COLLISION_SHAPE_EXPANSION_FACTOR
	elif hitbox_collision_shape.shape is BoxShape3D:
		hitbox_collision_shape.shape.size *= HITBOX_COLLISION_SHAPE_EXPANSION_FACTOR
	else:
		push_error("ERROR: possessable throwable initialized as child of non-supported collision shape.",
			"Throwable objects must have a CylinderShape3D or BoxShape3D collision shape.")
		return


func _physics_process(delta: float) -> void:
	# if object has been thrown, thus depossessed, it should not be possessable
	# again until object has slowed down enough
	if not is_possessed and parent.linear_velocity.length() < DAMAGE_VELOCITY:
		# disable hurtbox when slow enough
		hitbox_collision_shape.set_deferred("disabled", true)
		float_time_offset = 0
		disable_effects()
		parent.collision_layer = CollisionBit.OBJECT_BLOCKER
		# disable physics process - re-enabled by possess()
		set_physics_process(false)
		return
	
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
	if not is_possessable:
		return
	super()
	# enable physics processing - disabled along with hitbox when slow enough
	set_physics_process(true)


func depossess(disable_effects_flag: bool = true) -> void:
	super(disable_effects_flag)
	# force sprite shaker to stop if object depossessed mid-attack
	sprite_shaker.halt()


func attack(target: Node3D, attack_windup: float) -> void:
	if player_in_range and room.player_in_room:
		# disable player detection
		range_collision_shape.disabled = true
		
		# display "wind-up" to attack
		await sprite_shaker.animate(parent.get_node("Sprite3D"), attack_windup, ATTACK_SHAKE_MAGNITUDE)

		# check again that object wasn't depossessed mid-attack
		if is_possessed:
			# enable hurtbox 
			hitbox_collision_shape.set_deferred("disabled", false)
			# VIOLENTLY LAUNCH SELF TOWARDS PLAYER \m/
			parent.collision_layer = CollisionBit.POSSESABLE + CollisionBit.OBJECT_BLOCKER
			parent.apply_impulse(global_position.direction_to(target.global_position) * THROW_FORCE)
			thrown.emit()
			throw_sfx.play_random_sound()
	
	# do not disable effects until hurtbox is disabled
	depossess(false)
