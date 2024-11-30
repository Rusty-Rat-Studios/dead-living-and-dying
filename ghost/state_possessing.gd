extends GhostState

var target_possessable: Possessable

# possessable detector
var detector: Area3D

func _ready() -> void:
	# child nodes' _ready functions are called before parent nodes, so to initialize
	# the detector variable we have to wait for the parent _ready function to fire
	call_deferred("ready_after_parent")


func ready_after_parent() -> void:
	detector = parent.get_node("PossessableDetector")
	detector.body_entered.connect(_on_contact_possessable)


func enter() -> void:
	# enable possessable detector
	detector.collision_mask = CollisionBit.PHYSICAL
	
	# DEBUG
	print("ghost ", self, " entered POSSESSING")
	
	set_closest_target()


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


func exit() -> void:
	# disable possessable detector
	detector.collision_mask = 0
	
	# clunky, but ensure no connections to possessables remain
	for p: Possessable in parent.current_room.possessables_available:
		if p.possessed.is_connected(set_closest_target):
			p.possessed.disconnect(set_closest_target)


func _process_physics(delta: float) -> void:
	if abs(parent.global_position - parent.target_pos) < 0.01:
		# only move if not at target
		parent.move_to_target(delta)


func _on_contact_possessable(body: Node3D) -> void:
	if body == target_possessable:
		target_possessable.possess()
		
