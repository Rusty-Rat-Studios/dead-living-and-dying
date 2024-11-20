class_name Ghost
extends CharacterBody3D

@onready var state_machine: Node = $StateMachine

@onready var current_room: Node3D = get_parent()
var movement_boundaries: Rect2

@onready var speed: float = 4.5 # marginally faster than player in Dying state
@onready var pause_duration_range: Vector2 = Vector2(1.0, 2.0)
@onready var target_pos: Vector3 = Vector3.ZERO
@onready var is_paused: bool = false
@onready var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# dynamically generate bounding box based on floor size of ghost's current room
	var floor_mesh_instance: MeshInstance3D = current_room.get_node("Floor/MeshInstance3D")
	var floor_mesh: PlaneMesh = floor_mesh_instance.mesh
	var floor_width: float = floor_mesh.size.x - 2 # add padding from wall
	var floor_depth: float = floor_mesh.size.y - 2 # add padding from wall
	
	# create movement boundary, Rect2(Vector2 position, Vector2 size)
	# Rect2 position starts in top-left corner; x-extends right and y-extends down
	movement_boundaries = Rect2(Vector2(-floor_width / 2, -floor_depth / 2), 
								Vector2(floor_width, floor_depth))
	
	set_random_target()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if is_paused:
		return
	
	if target_pos:
		move_to_target(delta)


func set_random_target() -> void:
	# generate random movement target within room boundaries
	var x: float = rng.randf_range(movement_boundaries.position.x,
					movement_boundaries.position.x + movement_boundaries.size.x)
	var z: float = rng.randf_range(movement_boundaries.position.y,
					movement_boundaries.position.y + movement_boundaries.size.y)
	target_pos = Vector3(x, 1.0, z) # keep ghost above ground
	is_paused = false


func move_to_target(delta: float) -> void:
	var direction: Vector3 = (target_pos - global_position).normalized()
	var distance_to_target: float = global_position.distance_to(target_pos)
	
	if distance_to_target < speed * delta:
		# set position to target if close enough
		global_position = target_pos
		pause()
	else:
		velocity = direction * speed
		move_and_slide()


func pause() -> void:
	is_paused = true
	target_pos = global_position
	
	var pause_duration: float = rng.randf_range(pause_duration_range.x, pause_duration_range.y)
	await get_tree().create_timer(pause_duration).timeout # create and wait for timer to elapse
	
	set_random_target()
