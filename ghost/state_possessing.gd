extends GhostState

# delay between ghost decision
const DECISION_TIME: float = 3.0
# used to determine whether ghost attacks
const ATTACK_CHANCE: float = 0.67
# used to determine whether ghost depossesses
const DEPOSSESS_CHANCE: float = 0.33

var target_possessable: Possessable
# possessable detector
var detector: Area3D

@onready var decision_timer: Timer = Timer.new()

@onready var is_possessing: bool = false

func _ready() -> void:
	# child nodes' _ready functions are called before parent nodes, so to initialize
	# the detector variable we have to wait for the parent _ready function to fire
	call_deferred("ready_after_parent")
	
	# configure decision timer
	decision_timer.one_shot = true
	decision_timer.wait_time = DECISION_TIME
	decision_timer.timeout.connect(_on_decision_timeout)
	add_child(decision_timer)


func ready_after_parent() -> void:
	detector = parent.get_node("PossessableDetector")
	detector.body_entered.connect(_on_contact_possessable)


func enter() -> void:
	# enable possessable detector
	detector.collision_mask = CollisionBit.PHYSICAL
	
	# reset decision timer
	decision_timer.wait_time = DECISION_TIME
	
	# DEBUG
	print(Time.get_time_string_from_system(), ": ", parent.name, " entered POSSESSING")
	
	set_closest_target()


func exit() -> void:
	print(Time.get_time_string_from_system(), ": ", parent.name, " exited POSESSING")
	# disable possessable detector
	detector.collision_mask = 0
	
	# depossess any currently possessed item
	if is_possessing:
		target_possessable.depossess()
		is_possessing = false
	
	target_possessable = null
	
	# clunky, but ensure no connections to possessables remain
	for p: Possessable in parent.current_room.possessables_available:
		if p.possessed.is_connected(set_closest_target):
			p.possessed.disconnect(set_closest_target)


func set_closest_target() -> void:
	var possessables: Array = parent.current_room.possessables_available
	
	# return to WAITING if no possessables available
	if possessables.is_empty():
		parent.state_machine.change_state(state_waiting)
		return
	
	var target_distance: float = INF
	# find nereast possessable and set it as target
	for p: Possessable in possessables:
		# use squared distance because it computes fast
		var distance_sq: float = parent.global_position.distance_squared_to(p.global_position)
		if distance_sq < target_distance:
			target_possessable = p
			target_distance = distance_sq
	
	# set ghost target to closest possessable position
	parent.target_pos = target_possessable.global_position
	
	# check if already overlapping the target possessable and immediately possess
	if detector.overlaps_body(target_possessable):
		target_possessable.possess()
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
			print (Time.get_time_string_from_system(), ": ", parent.name, " decided to depossess ", target_possessable.name)
			# depossess object and go to WAITING
			target_possessable.depossess()
			parent.state_machine.change_state(state_waiting)
			return
		
		# decide to attack or not
		# if player not in range, simply depossess
		var attack_chance: float = parent.rng.randf()
		if attack_chance < ATTACK_CHANCE:
			print (Time.get_time_string_from_system(), ": ", parent.name, " decided to attack!")
			target_possessable.attack(PlayerHandler.get_player())
			target_possessable.depossess()
			parent.state_machine.change_state(state_waiting)
			return
		
	# no action was taken, restart decision timer
	print(Time.get_time_string_from_system(), ": ", parent.name, " decided to do nothing")
	decision_timer.wait_time = DECISION_TIME
	decision_timer.start()


func _on_contact_possessable(body: Node3D) -> void:
	if body == target_possessable:
		print(Time.get_time_string_from_system(), ": ", parent.name, " possessed ", target_possessable.name)
		target_possessable.possess()
		is_possessing = true
		# delay, then make decision
		decision_timer.wait_time = DECISION_TIME
		decision_timer.start()
