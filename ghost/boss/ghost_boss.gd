extends Ghost

# amount of time before rolling for event
const EVENT_CHANCE_TIME: float = 5
const EVENT_CHANCE: float = 0.4
const EVENT_DURATION: float = 15

var event_active: bool = false

@onready var event_chance_timer: Timer = Timer.new()
@onready var event_duration_timer: Timer = Timer.new()


func _ready() -> void:
	super()
	
	add_child(event_chance_timer)
	add_child(event_duration_timer)
	event_chance_timer.wait_time = EVENT_CHANCE_TIME
	event_duration_timer.wait_time = EVENT_DURATION
	event_chance_timer.timeout.connect(_on_event_chance_timer_timeout)
	event_duration_timer.timeout.connect(_on_event_duration_timer_timeout)
	
	SignalBus.player_state_changed.connect(_on_player_state_changed)


###########
# TEMPORARY: prevent boss ghost from leaving room during event
# to be replaced with movement chance modifier
func _process(_delta: float) -> void:
	if event_active and state_machine.current_state == GhostStateMachine.States.MOVING:
		state_machine.change_state(GhostStateMachine.States.WAITING)


func _input(event: InputEvent) -> void:
	if event.is_action("trigger_boss_event"):
		start_event()


func start_event() -> void:
	print(Time.get_time_string_from_system(), ": BOSS EVENT MAKE SURE TO RUN AND HIDE HAHAHAHAHAHAHAHAHAHAHA")
	state_machine.change_state(GhostStateMachine.States.WAITING)
	set_target(current_room.global_position)
	#SignalBus.attack_event_started.emit(current_room)
	event_chance_timer.stop()
	event_duration_timer.start()
	event_active = true
	
	# lock all doors
	for door: Door in current_room.doors.values():
		door.lock()
		door.linked_door.lock()
	
	# make ghosts visible
	for ghost: Ghost in get_tree().get_nodes_in_group("ghosts"):
		ghost.set_opacity(OPACITY_DYING)
		ghost.light_enabled_permanent = true
		ghost.set_light(LIGHT_ENERGY)


func stop_event() -> void:
	#SignalBus.attack_event_stopped.emit(current_room)
	event_duration_timer.stop()
	event_active = false
	
	# unlock all doors
	for door: Door in current_room.doors.values():
		door.unlock()
		door.linked_door.unlock()
	
	if player_in_room and event_chance_timer.is_stopped():
		event_chance_timer.start()
	
	# reset ghosts visibility based on player state
	for ghost: Ghost in get_tree().get_nodes_in_group("ghosts"):
		ghost._on_player_state_changed(PlayerHandler.get_player_state())
		ghost.light_enabled_permanent = false
		ghost.set_light(0)


func _on_event_chance_timer_timeout() -> void:
	# every timeout roll for a chance to start the attack event
	if RNG.rng.randf() <= EVENT_CHANCE:
		start_event()


func _on_event_duration_timer_timeout() -> void:
	stop_event()


func _on_player_state_changed(state: PlayerStateMachine.States) -> void:
	super(state)
	# handle edge case with the short delay after player dies 
	# but before they are moved out of the room
	if state == PlayerStateMachine.States.DEAD and not event_chance_timer.is_stopped():
		event_chance_timer.stop()
		print(Time.get_time_string_from_system(), ": event chance stopped")
	elif (state == PlayerStateMachine.States.LIVING 
		and event_chance_timer.is_stopped()
		and player_in_room):
		# could use player_revived signal instead, but that doesn't register
		# with using tab to switch states -> easier to debug this way
		event_chance_timer.start()
		print(Time.get_time_string_from_system(), ": event chance started")


func _on_player_entered_room(room: Node3D) -> void:
	super(room)
	if (room == current_room 
		and event_chance_timer.is_stopped()
		and PlayerHandler.get_player_state() != PlayerStateMachine.States.DEAD):
		event_chance_timer.start()
		print(Time.get_time_string_from_system(), ": event chance started")


func _on_player_exited_room(room: Node3D) -> void:
	super(room)
	if room == current_room and not event_chance_timer.is_stopped():
		event_chance_timer.stop()
		print(Time.get_time_string_from_system(), ": event chance stopped")
