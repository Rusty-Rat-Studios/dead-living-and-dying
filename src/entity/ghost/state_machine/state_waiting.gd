extends GhostState

const PAUSE_DURATION_MAX: float = 2.0
const PAUSE_DURATION_MIN: float = 0.5

var polygon_point_generator: PolygonPointGenerator # select random points in room to wander to

# flag for pausing physics execution
@onready var is_paused: bool = false
# timer for pause duration
@onready var pause_timer: Timer = Timer.new()


func _ready() -> void:
	add_child(pause_timer)
	pause_timer.one_shot = true


func enter() -> void:
	_parent.sprite.animation = "idle"
	
	# dynamically grab region based ghost's current room
	polygon_point_generator = PolygonPointGenerator.new(RNG.rng, _parent.current_room.get_room_polygon())
	
	is_paused = false
	set_random_target()


func exit() -> void:
	super()
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
	var target: Vector2 = polygon_point_generator.get_random_point()
	
	_parent.set_target(_parent.current_room.global_position + Vector3(target.x, 1.0, target.y))


func pause() -> void:
	# pause movement behavior until timer expires
	is_paused = true
	# use variable reference to allow disabling the timer on state exit()
	pause_timer.wait_time = RNG.rng.randf_range(PAUSE_DURATION_MIN, PAUSE_DURATION_MAX)
	pause_timer.start()
	await pause_timer.timeout
	is_paused = false
	
	# weighted chances for choosing next action
	var choices: Dictionary[Callable, float] = {
		_possess: _parent.stats.state_possessing_chance,
		_attack: _parent.stats.state_attacking_chance,
		set_random_target: _parent.stats.state_waiting_chance,
		_move: _parent.stats.state_moving_chance
	}
	RNG.call_weighted_random(choices)


func _possess() -> void:
	change_state(GhostStateMachine.States.POSSESSING)


func _attack() -> void:
	# attack state will check if player is in DYING state
	# if player is living, return to WAITING which defaults to set_random_target()
	change_state(GhostStateMachine.States.ATTACKING)


func _move() -> void:
	change_state(GhostStateMachine.States.MOVING)
