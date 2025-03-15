extends GhostState

# delay between ghost decision
const DECISION_TIME: float = 1.0
# used to determine whether ghost attacks
const ATTACK_CHANCE: float = 0.7
# used to determine whether ghost depossesses
const DEPOSSESS_CHANCE: float = 0.15
# used to determine whether ghost waits
const WAIT_CHANCE: float = 0.35
# short delay for the ghost to wait when failing to possess an object
const TARGET_RESET_DELAY: float = 0.1
# used by attack delay timer to increment/decrement attack delay counter
# based on whether player is in the room or not to avoid door-cheesing
const ATTACK_DELAY_INCREMENT: float = 0.05
const ATTACK_DELAY_DECREMENT: float = 0.1
const ATTACK_DELAY_INCREMENT_DURATION: float = 0.1

var target_possessable: Possessable
var is_possessing: bool = false
# possessable detector
var detector: Area3D
var detector_collision_shape: CollisionShape3D
# unset by player entering room and set after the attack delay timer expires
var can_attack: bool = false
var attack_delay: float = DECISION_TIME

@onready var decision_timer: Timer = Timer.new()
# used to delay attacking if player has just entered the room
@onready var attack_delay_increment_timer: Timer = Timer.new()


func _ready() -> void:
	attack_delay_increment_timer.wait_time = ATTACK_DELAY_INCREMENT_DURATION
	add_child(attack_delay_increment_timer)
	attack_delay_increment_timer.timeout.connect(_on_attack_delay_increment_timer_timeout)


func init(parent: CharacterBody3D, state_machine: StateMachine) -> void:
	# use init() instead of _ready() because we need access to parent variables
	# which are initialized after child variables (i.e. this state)
	super(parent, state_machine)
	decision_timer.one_shot = true
	decision_timer.wait_time = DECISION_TIME
	decision_timer.timeout.connect(_on_decision_timeout)
	add_child(decision_timer)
	detector = _parent.get_node("PossessableDetector")
	detector.area_entered.connect(_on_contact_possessable)
	detector_collision_shape = detector.get_node("CollisionShape3D")


func enter() -> void:
	_parent.speed = _parent.BASE_SPEED
	_parent.sprite.animation = "active"
	# enable possessable detector
	detector_collision_shape.set_deferred("disabled", false)
	# reset decision timer
	decision_timer.wait_time = DECISION_TIME
	
	# negate attack delay if the player is already in the room
	if _parent.player_in_room:
		attack_delay = 0
		can_attack = true
	else:
		attack_delay = DECISION_TIME
		can_attack = false
	
	# connect/disconnect in enter/exit to ensure function only fires while state is active
	SignalBus.player_state_changed.connect(_on_player_state_changed)
	SignalBus.player_entered_room.connect(_on_player_entered_room)
	SignalBus.player_exited_room.connect(_on_player_exited_room)
	_parent.hit.connect(_on_hit)
	
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
	for p: Possessable in _parent.current_room.possessables_available:
		if p.possessed.is_connected(set_closest_target):
			p.possessed.disconnect(set_closest_target)
	
	SignalBus.player_state_changed.disconnect(_on_player_state_changed)
	SignalBus.player_entered_room.disconnect(_on_player_entered_room)
	SignalBus.player_exited_room.disconnect(_on_player_exited_room)
	_parent.hit.disconnect(_on_hit)


func set_closest_target() -> void:
	# get all possessable items in the room
	var possessables: Array = _parent.current_room.possessables_available

	# return to WAITING if no possessables available
	if possessables.is_empty():
		change_state(GhostStateMachine.States.WAITING)
		return
	
	# find nearest possessable and set it as target
	target_possessable = Utility.find_closest(possessables, _parent.global_position)
	
	# set ghost target to closest possessable position
	_parent.set_target(target_possessable.global_position)
	
	# check if already overlapping the target possessable and immediately possess
	if detector.overlaps_area(target_possessable):
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


func process_state() -> void:
	# update target position if it moved
	# case: still moving from last possession interaction
	# case: player or other object bumps into it
	if target_possessable:
		_parent.set_target(target_possessable.global_position)


func _depossess() -> void:
	# check if ghost has already been forced into WAITING by player state change
	# depossess object and go to WAITING
	if target_possessable:
		target_possessable.depossess()
		is_possessing = false
		change_state(GhostStateMachine.States.WAITING)


func _attack() -> void:
	# check if ghost has already been forced into WAITING by player state change
	# if player not in range, possessable.attack() simply depossesses
	if target_possessable:
		await target_possessable.attack(PlayerHandler.get_player())
		is_possessing = false
		change_state(GhostStateMachine.States.WAITING)


func _wait() -> void:
	# no action was taken, restart decision timer
	decision_timer.wait_time = DECISION_TIME
	decision_timer.start()


func _on_decision_timeout() -> void:
	if is_possessing:
		var choices: Dictionary[Callable, float] = {
			_depossess: DEPOSSESS_CHANCE,
			_wait: WAIT_CHANCE
		}
		# add option to attack only if attack delay has expired
		if can_attack:
			choices[_attack] = ATTACK_CHANCE
		RNG.call_async_weighted_random(choices)


func _on_contact_possessable(body: Node3D) -> void:
	# ensure overlapping body is indeed the target, then possess it
	if body == target_possessable and target_possessable.is_possessable:
		# disconnect target reset signal before possession so this ghost
		# does not try to seek another target
		if target_possessable.possessed.is_connected(set_closest_target):
			target_possessable.possessed.disconnect(set_closest_target)
		target_possessable.possess()
		is_possessing = true
		# delay, then make decision
		decision_timer.wait_time = DECISION_TIME
		decision_timer.start()


func _on_player_state_changed(state: PlayerStateMachine.States) -> void:
	# when the player is hurt, change all currently possessing ghosts
	# back into WAITING to ensure the player has some breathing room
	if state == PlayerStateMachine.States.DYING and _parent.player_in_room:
		change_state(GhostStateMachine.States.WAITING)


func _on_player_entered_room(room: Node3D) -> void:
	# prevent ghost from immediately attack the player when entering room
	if is_possessing and room == _parent.current_room:
		# begin delay time before attacking
		if attack_delay_increment_timer.is_stopped():
			attack_delay_increment_timer.start()
			can_attack = false


func _on_player_exited_room(room: Node3D) -> void:
	if (room == _parent.current_room 
		and attack_delay_increment_timer.is_stopped()):
		attack_delay_increment_timer.start()


func _on_attack_delay_increment_timer_timeout() -> void:
	# attack delay decrements while player is in the room until it reaches zero,
	# enabling the ghost to attack. If the player is outside the room, it increments
	# (twice as slowly as it decrements) until the attack delay is restored to
	# its base value of DECISION_TIME
	if _parent.player_in_room:
		attack_delay -= ATTACK_DELAY_DECREMENT
	elif not _parent.player_in_room and attack_delay <= DECISION_TIME:
		attack_delay += ATTACK_DELAY_INCREMENT
	
	if attack_delay <= 0 or attack_delay >= DECISION_TIME:
		attack_delay_increment_timer.stop()
	if attack_delay <= 0:
		can_attack = true


func _on_hit() -> void:
	# ghost has been hit and will move into stunned state
	#########
	# PROBLEM: exit() is called before the hit signal is fired and target_possessable is null
	if is_possessing:
		target_possessable.exorcised.emit()
