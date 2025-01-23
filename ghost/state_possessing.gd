extends GhostState

# delay between ghost decision
const DECISION_TIME: float = 3.0
# used to determine whether ghost attacks
const ATTACK_CHANCE: float = 0.67
# used to determine whether ghost depossesses
const DEPOSSESS_CHANCE: float = 0.33
# short delay for the ghost to wait when failing to possess an object
const TARGET_RESET_DELAY: float = 0.1

var target_possessable: Possessable
# possessable detector
var detector: Area3D
var detector_collision_shape: CollisionShape3D

@onready var decision_timer: Timer = Timer.new()
@onready var is_possessing: bool = false

func _ready() -> void:
	# child nodes' _ready functions are called before parent nodes, so to initialize
	# the detector variable we have to wait for the parent _ready function to fire
	call_deferred("ready_after_parent")
	
	# defer connecting this signal to ensure this function executes
	# AFTER this signal updates the player_in_room flag in ghost.gd
	SignalBus.player_entered_room.connect(_on_player_entered_room, CONNECT_DEFERRED)
	
	# configure decision timer
	decision_timer.one_shot = true
	decision_timer.wait_time = DECISION_TIME
	decision_timer.timeout.connect(_on_decision_timeout)
	add_child(decision_timer)


func ready_after_parent() -> void:
	# set and connect detector for possessable objects
	detector = parent.get_node("PossessableDetector")
	detector.body_entered.connect(_on_contact_possessable)
	detector_collision_shape = detector.get_node("CollisionShape3D")


func enter() -> void:
	# enable possessable detector
	detector_collision_shape.set_deferred("disabled", false)
	# reset decision timer
	decision_timer.wait_time = DECISION_TIME
	
	set_closest_target()


func exit() -> void:
	super()
	# disable possessable detector
	detector_collision_shape.set_deferred("disabled", true)
	
	# depossess any currently possessed item
	if is_possessing:
		target_possessable.depossess()
		is_possessing = false
	
	decision_timer.stop()
	target_possessable = null
	
	# clunky, but ensure no connections to possessables remain
	for p: Possessable in parent.current_room.possessables_available:
		if p.possessed.is_connected(set_closest_target):
			p.possessed.disconnect(set_closest_target)


func set_closest_target() -> void:
	# get all possessable items in the room
	var possessables: Array = parent.current_room.possessables_available

	# return to WAITING if no possessables available
	if possessables.is_empty():
		parent.state_machine.change_state(state_waiting)
		return
	
	# find nearest possessable and set it as target
	target_possessable = Utility.find_closest(possessables, parent.global_position)
	
	# set ghost target to closest possessable position
	parent.target_pos = target_possessable.global_position
	
	# check if already overlapping the target possessable and immediately possess
	if detector.overlaps_body(target_possessable):
		if target_possessable.is_possessable:
			target_possessable.possess()
			is_possessing = true
		else:
			# overlaps but is not possessable right now, reset target - it 
			# will likely follow the same target, but either wait until it 
			# is possessable again or until it is farther than another target
			# -- use slight delay to minimize repeated checks on closest target
			await Utility.delay(TARGET_RESET_DELAY)
			set_closest_target()
			return
	else:
		# connect signal to find a new target if the current one is possessed before we reach it
		target_possessable.possessed.connect(set_closest_target, CONNECT_ONE_SHOT)


func process_physics(delta: float) -> State:
	# update target position if it moved
	# case: still moving from last possession interaction
	# case: player or other object bumps into it
	if target_possessable:
		parent.target_pos = target_possessable.global_position
	
	# only move if not at target
	if parent.global_position.distance_squared_to(parent.target_pos) > 0.01:
		parent.move_to_target(delta)
	
	# remain in same state
	return null


func _on_decision_timeout() -> void:
	if is_possessing:
		# decide to depossess or not
		var depossess_chance: float = parent.rng.randf()
		if depossess_chance < DEPOSSESS_CHANCE:
			print(Time.get_time_string_from_system(), ": ", parent.name, " decided to depossess ", target_possessable.name)
			# depossess object and go to WAITING
			target_possessable.depossess()
			is_possessing = false
			parent.state_machine.change_state(state_waiting)
			return
		
		# decide to attack or not
		# if player not in range, possessable.attack() simply depossesses
		var attack_chance: float = parent.rng.randf()
		if attack_chance < ATTACK_CHANCE:
			print(Time.get_time_string_from_system(), ": ", parent.name, " decided to attack!")
			target_possessable.attack(PlayerHandler.get_player())
			target_possessable.depossess()
			is_possessing = false
			parent.state_machine.change_state(state_waiting)
			return
		
	# no action was taken, restart decision timer
	print(Time.get_time_string_from_system(), ": ", parent.name, " decided to do nothing")
	decision_timer.wait_time = DECISION_TIME
	decision_timer.start()


func _on_contact_possessable(body: Node3D) -> void:
	# ensure overlapping body is indeed the target, then possess it
	if body == target_possessable and target_possessable.is_possessable:
		print(Time.get_time_string_from_system(), ": ", parent.name, " possessed ", target_possessable.name)
		# disconnect target reset signal before possession so this ghost
		# does not try to seek another target
		if target_possessable.possessed.is_connected(set_closest_target):
			target_possessable.possessed.disconnect(set_closest_target)
		target_possessable.possess()
		is_possessing = true
		# delay, then make decision
		decision_timer.wait_time = DECISION_TIME
		decision_timer.start()
