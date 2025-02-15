extends GhostState

const WAITING_SPEED: float = 3.0
const PAUSE_DURATION_MAX: float = 3.0
const PAUSE_DURATION_MIN: float = 1.0
const POSSESS_CHANCE: float = 0.5
const ATTACK_CHANCE: float = 0.25
const WAIT_CHANCE: float = 0.25

var room_boundaries: Rect2 # select random points in room to wander to

# flag for pausing physics execution
@onready var is_paused: bool = false
# timer for pause duration
@onready var pause_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(pause_timer)
	pause_timer.one_shot = true


func enter() -> void:
	_parent.speed = WAITING_SPEED
	
	_parent.sprite.animation = "idle"
	
	# dynamically generate bounding box based on floor size of ghost's current room
	var floor_mesh_instance: MeshInstance3D = _parent.current_room.get_node("Floor/MeshInstance3D")
	var floor_mesh: PlaneMesh = floor_mesh_instance.mesh
	var floor_width: float = floor_mesh.size.x - 2 # add padding from wall to avoid collision
	var floor_depth: float = floor_mesh.size.y - 2 # add padding from wall to avoid collision
	
	# create movement boundary, Rect2(Vector2 position, Vector2 size)
	# Rect2 position starts in top-left corner; x-extends right and y-extends down
	room_boundaries = Rect2(Vector2(-floor_width / 2, -floor_depth / 2), 
								Vector2(floor_width, floor_depth))
	
	# update parent movement boundaries
	_parent.movement_boundaries = room_boundaries
	
	is_paused = false
	set_random_target()


func exit() -> void:
	super()
	_parent.speed = _parent.BASE_SPEED
	is_paused = false
	pause_timer.stop()


func process_state() -> void:
	if is_paused:
		return
	
	if _parent.at_target:
		pause()


func set_random_target() -> void:
	# ensure at_target flag is unset to avoid race condition with process_state()
	# checking _parent.at_target before target is actually set
	_parent.at_target = false
	
	# generate random movement target within room boundaries
	# offset to avoid setting point within walls
	var x: float = RNG.rng.randf_range(room_boundaries.position.x + 1,
					room_boundaries.position.x + room_boundaries.size.x - 1)
	var z: float = RNG.rng.randf_range(room_boundaries.position.y + 1,
					room_boundaries.position.y + room_boundaries.size.y - 1)
	
	_parent.set_target(_parent.current_room.global_position + Vector3(x, 1.0, z))


func pause() -> void:
	# pause movement behavior until timer expires
	is_paused = true
	# use variable reference to allow disabling the timer on state exit()
	pause_timer.wait_time = RNG.rng.randf_range(PAUSE_DURATION_MIN, PAUSE_DURATION_MAX)
	pause_timer.start()
	await pause_timer.timeout
	is_paused = false
	
	# weighted chances for choosing next action
	var choices: Dictionary = {
		_possess: POSSESS_CHANCE,
		_attack: ATTACK_CHANCE,
		set_random_target: WAIT_CHANCE
	}
	RNG.call_weighted_random(choices)


func _possess() -> void:
	change_state(GhostStateMachine.States.POSSESSING)


func _attack() -> void:
	# attack state will check if player is in DYING state
	# if player is living, return to WAITING which defaults to set_random_target()
	change_state(GhostStateMachine.States.ATTACKING)
