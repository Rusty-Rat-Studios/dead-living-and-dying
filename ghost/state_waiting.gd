extends GhostState

var movement_boundaries: Rect2 # select random points in room to wander to

const PAUSE_DURATION_MAX: float = 2.0
const PAUSE_DURATION_MIN: float = 0.5
@onready var is_paused: bool = false
@onready var rng = RandomNumberGenerator.new() # generating wait time and target positions


func enter() -> void:
	super()
	parent.speed = 3.0
	
	# DEBUG
	print("ghost entered Waiting")
	
	# dynamically generate bounding box based on floor size of ghost's current room
	var floor_mesh_instance: MeshInstance3D = parent.current_room.get_node("Floor/MeshInstance3D")
	var floor_mesh: PlaneMesh = floor_mesh_instance.mesh
	var floor_width: float = floor_mesh.size.x - 2 # add padding from wall to avoid collision
	var floor_depth: float = floor_mesh.size.y - 2 # add padding from wall to avoid collision
		
	# create movement boundary, Rect2(Vector2 position, Vector2 size)
	# Rect2 position starts in top-left corner; x-extends right and y-extends down
	movement_boundaries = Rect2(Vector2(-floor_width / 2, -floor_depth / 2), 
								Vector2(floor_width, floor_depth))
	
	# set timer and connect to timeout function
	$PauseTimer.wait_time = randf_range(PAUSE_DURATION_MIN, PAUSE_DURATION_MAX)
	$PauseTimer.timeout.connect(_on_pause_timeout)
	
	set_random_target()


func exit() -> void:
	$PauseTimer.stop()
	$PauseTimer.timeout.disconnect(_on_pause_timeout)


func process_physics(delta: float) -> State:
	if is_paused:
		return null # stay in waiting state
	
	parent.move_to_target(delta)
	return null # stay in waiting state


func set_random_target() -> void:
	# generate random movement target within room boundaries
	var x: float = rng.randf_range(movement_boundaries.position.x,
					movement_boundaries.position.x + movement_boundaries.size.x)
	var z: float = rng.randf_range(movement_boundaries.position.y,
					movement_boundaries.position.y + movement_boundaries.size.y)
	parent.target_pos = Vector3(x, 1.0, z) # keep ghost above ground


func _on_pause_timeout() -> void:
	is_paused = true
		
	# reset timer
	$PauseTimer.wait_time = randf_range(PAUSE_DURATION_MIN, PAUSE_DURATION_MAX)
	$PauseTimer.start()
	set_random_target()
