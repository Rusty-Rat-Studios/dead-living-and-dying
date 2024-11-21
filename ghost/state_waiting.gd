extends GhostState

var room_boundaries: Rect2 # select random points in room to wander to

const PAUSE_DURATION_MAX: float = 3.0
const PAUSE_DURATION_MIN: float = 1.0
@onready var is_paused: bool = false
@onready var rng = RandomNumberGenerator.new() # generating wait time and target positions


func enter() -> void:
	super()
	parent.speed = 3.0
	
	# dynamically generate bounding box based on floor size of ghost's current room
	var floor_mesh_instance: MeshInstance3D = parent.current_room.get_node("Floor/MeshInstance3D")
	var floor_mesh: PlaneMesh = floor_mesh_instance.mesh
	var floor_width: float = floor_mesh.size.x - 2 # add padding from wall to avoid collision
	var floor_depth: float = floor_mesh.size.y - 2 # add padding from wall to avoid collision
		
	# create movement boundary, Rect2(Vector2 position, Vector2 size)
	# Rect2 position starts in top-left corner; x-extends right and y-extends down
	room_boundaries = Rect2(Vector2(-floor_width / 2, -floor_depth / 2), 
								Vector2(floor_width, floor_depth))
	
	# update parent movement boundaries
	parent.movement_boundaries = room_boundaries
	
	is_paused = false
	set_random_target()


func exit() -> void:
	is_paused = false


func process_physics(delta: float) -> State:
	if is_paused:
		return null # stay in waiting state
	
	if parent.global_position != parent.target_pos:
		# only move if not at target
		parent.move_to_target(delta)
	else:
		pause()
	return null # stay in waiting state


func set_random_target() -> void:
	# generate random movement target within room boundaries
	# offset to avoid setting point within walls
	var x: float = rng.randf_range(room_boundaries.position.x + 1,
					room_boundaries.position.x + room_boundaries.size.x - 1)
	var z: float = rng.randf_range(room_boundaries.position.y + 1,
					room_boundaries.position.y + room_boundaries.size.y - 1)
	
	parent.target_pos = parent.current_room.global_position + Vector3(x, 1.0, z)


func pause() -> void:
	is_paused = true
	# used with await inside pause_timeout() 
	# to do nothing until timer expires
	await pause_timeout() 


func pause_timeout() -> void:
	# pause function execution until timer expires
	await get_tree().create_timer(randf_range(PAUSE_DURATION_MIN, PAUSE_DURATION_MAX)).timeout
	is_paused = false
	set_random_target()
