extends GhostState

const PAUSE_DURATION_MAX: float = 3.0
const PAUSE_DURATION_MIN: float = 1.0

var room_boundaries: Rect2 # select random points in room to wander to

# flag for pausing physics execution
@onready var is_paused: bool = false
# timer for pause duration
@onready var pause_timer: Timer = Timer.new()

func _ready() -> void:
	# defer connecting this signal to ensure this function executes
	# AFTER this signal updates the player_in_room flag in ghost.gd
	SignalBus.player_entered_room.connect(_on_player_entered_room, CONNECT_DEFERRED)
	add_child(pause_timer)
	pause_timer.one_shot = true


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
	super()
	is_paused = false
	pause_timer.stop()


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
	var x: float = parent.rng.get_rng().randf_range(room_boundaries.position.x + 1,
					room_boundaries.position.x + room_boundaries.size.x - 1)
	var z: float = parent.rng.get_rng().randf_range(room_boundaries.position.y + 1,
					room_boundaries.position.y + room_boundaries.size.y - 1)
	
	parent.target_pos = parent.current_room.global_position + Vector3(x, 1.0, z)


func pause() -> void:
	# pause movement behavior until timer expires
	is_paused = true
	# use variable reference to allow disabling the timer on state exit()
	pause_timer.wait_time = parent.rng.get_rng().randf_range(PAUSE_DURATION_MIN, PAUSE_DURATION_MAX)
	pause_timer.start()
	await pause_timer.timeout
	is_paused = false
	
	# 25/75 chance to continue waiting or possess item
	var choices: Dictionary = {
		_possess: .75,
		set_random_target: .25
	}
	parent.rng.call_weighted_random(choices)


func _possess() -> void:
	print(Time.get_time_string_from_system(), ": ", parent.name, " decided to possess")
	parent.state_machine.change_state(state_possessing)
