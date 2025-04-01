extends GhostState

"""
The ghost position and target is checked according to whether it has reached
one of three target stages (DoorStates):
1. BEFORE: current_room side of target door
2. AT: center of target door, between rooms
3. AFTER: target_room side of target door
These checks are required when reparenting the ghost to the target room as
the ghost's visibility is controlled by its parent room. If the ghost is
reparented too early, it suddenly disappears from the current room; if it's 
reparented too late, it suddenly appears in the target room. 

For a smooth transition, the ghost is made intangible at stage BEFORE and made
tangible again at stage AFTER. The ghost is reparented to the target room at
stage AT (directly on top of target door) as this is the appropriate transition
point if the visibility of the ghost were to toggle.
"""
enum DoorStates { BEFORE, AT, AFTER }

const OFFSET_DISTANCE: float = 0.8

var state: DoorStates = DoorStates.BEFORE

# door in current room ghost is moving to
var target_door: Door
# the target position for the current room side of the door
var target_door_pos_near: Vector3
# the target position for the far side of the linked door in the target room
var target_door_pos_far: Vector3
# adjacent room ghost is moving to
var target_room: Room


func enter() -> void:
	state = DoorStates.BEFORE
	if find_target_door():
		_parent.target_reached.connect(_on_target_reached)
		_parent.set_target(target_door_pos_near)
	else:
		change_state(GhostStateMachine.States.WAITING)

func exit() -> void:
	# super() sets _parent.target_pos to its current position
	# - ensure target_reached signal disconnected prior to calling super()
	if _parent.target_reached.is_connected(_on_target_reached):
		_parent.target_reached.disconnect(_on_target_reached)
	super()
	target_door = null
	target_door_pos_near = Vector3.ZERO
	target_door_pos_far = Vector3.ZERO
	target_room = null
	state = DoorStates.BEFORE


func process_state() -> void:
	pass


# sets all variables related to target door selected at random from available doors
func find_target_door() -> bool:
	# pick random door and set target
	var doors: Array[Door]
	doors.assign(_parent.current_room.doors.values())
	if doors.is_empty():
		return false
	
	# pick random door
	target_door = RNG.random_from_list(doors)
	target_room = target_door.linked_door.get_parent()
	
	# shift target positions to slightly ahead/behind door
	var position_offset: Vector3
	match target_door.door_location.direction:
		DoorLocation.Direction.NORTH:
			position_offset = Vector3.BACK * OFFSET_DISTANCE
		DoorLocation.Direction.EAST:
			position_offset = Vector3.LEFT * OFFSET_DISTANCE
		DoorLocation.Direction.SOUTH:
			position_offset = Vector3.FORWARD * OFFSET_DISTANCE
		DoorLocation.Direction.WEST:
			position_offset = Vector3.RIGHT * OFFSET_DISTANCE
	
	target_door_pos_near = target_door.global_position + position_offset
	target_door_pos_far = target_door.global_position - position_offset
	
	return true


func _on_target_reached() -> void:
	match state:
		DoorStates.BEFORE:
			# make intangible before going through door
			_parent.get_node("CollisionShape3D").set_deferred("disabled", true)
			_parent.set_target(target_door.global_position)
			state = DoorStates.AT
		DoorStates.AT:
			# transition to next room
			_parent.current_room = target_room
			_parent.reparent(_parent.current_room)
			_parent.player_in_room = true if _parent.current_room.player_in_room else false
			_parent.set_target(target_door_pos_far)
			state = DoorStates.AFTER
		DoorStates.AFTER:
			# make tangible again when finished going through door
			_parent.get_node("CollisionShape3D").set_deferred("disabled", false)
			if _parent.player_in_room and PlayerHandler.get_player_state() == PlayerStateMachine.States.DEAD:
				change_state(GhostStateMachine.States.ATTACKING)
			else:
				change_state(GhostStateMachine.States.WAITING)
