extends GhostState

var movement_boundaries: Rect2 # select random points in room to wander to

const PAUSE_DURATION_MAX: float = 2.0
const PAUSE_DURATION_MIN: float = 0.5
@onready var target_pos: Vector3 = Vector3.ZERO
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
	movement_boundaries = Rect2(Vector2(-floor_width / 2, -floor_depth / 2), 
								Vector2(floor_width, floor_depth))
	
	# set timer and connect to timeout function
	$PauseTimer.wait_time = randf_range(PAUSE_DURATION_MIN, PAUSE_DURATION_MAX)
	#$PauseTimer.connect("timeout", Callable(self, "_on_pause_timeout"))
	$PauseTimer.timeout.connect(_on_pause_timeout)
	
	set_random_target()


func exit() -> void:
	$PauseTimer.stop()
	#$PauseTimer.disconnect("timeout", Callable(self, "_on_pause_timeout"))
	$PauseTimer.timeout.disconnect(_on_pause_timeout)


func process_physics(delta: float) -> State:
	if is_paused:
		return null # stay in waiting state
	
	move_to_target(delta)
	return null # stay in waiting state


func set_random_target() -> void:
	# generate random movement target within room boundaries
	var x: float = rng.randf_range(movement_boundaries.position.x,
					movement_boundaries.position.x + movement_boundaries.size.x)
	var z: float = rng.randf_range(movement_boundaries.position.y,
					movement_boundaries.position.y + movement_boundaries.size.y)
	target_pos = Vector3(x, 1.0, z) # keep ghost above ground



func move_to_target(delta: float) -> void:
	var direction: Vector3 = (target_pos - parent.position).normalized()
	var distance_to_target: float = parent.position.distance_to(target_pos)
	
	if distance_to_target < parent.speed * delta:
		# set target to ghost position if close enough
		target_pos = parent.position
		pause()
	else:
		parent.velocity = direction * parent.speed
		parent.move_and_slide()


func pause() -> void:
	is_paused = true
	
	$PauseTimer.start()

func _on_pause_timeout() -> void:
	is_paused = false
	
	# reset timer
	$PauseTimer.wait_time = randf_range(PAUSE_DURATION_MIN, PAUSE_DURATION_MAX)
	set_random_target()
