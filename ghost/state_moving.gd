extends GhostState

# door in current room ghost is moving to
var target_door: Door
var target_door_pos: Vector3
var target_door_pos_far: Vector3
# adjacent room ghost is moving to
var target_room: Room

var moving_through_door: bool = false

func enter() -> void:
	# pick random door and set target
	var doors: Array[Node] = _parent.current_room.find_children("*", "Door")
	
	# pick random door
	target_door = RNG.random_from_list(doors)
	target_room = target_door.linked_door.get_parent()
	
	target_door_pos = target_door.global_position
	target_door_pos_far = target_door_pos
	# shift target position to just in front of door
	match target_door.door_location.direction:
		DoorLocation.Direction.NORTH:
			target_door_pos += Vector3.BACK * 2
			target_door_pos_far -= Vector3.BACK * 2
		DoorLocation.Direction.EAST:
			target_door_pos += Vector3.LEFT * 2
			target_door_pos_far -= Vector3.LEFT * 2
		DoorLocation.Direction.SOUTH:
			target_door_pos += Vector3.FORWARD * 2
			target_door_pos_far -= Vector3.FORWARD * 2
		DoorLocation.Direction.WEST:
			target_door_pos += Vector3.RIGHT * 2
			target_door_pos_far -= Vector3.RIGHT * 2
	
	_parent.set_target(target_door_pos)


func exit() -> void:
	super()
	target_door = null
	target_room = null
	moving_through_door = false


func process_state() -> void:
	if _parent.at_target:
		if moving_through_door:
			# reached other side of the door
			_parent.current_room = target_room
			_parent.get_node("CollisionShape3D").set_deferred("disabled", false)
			_parent.reparent(_parent.current_room)
			change_state(GhostStateMachine.States.WAITING)
		else:
			# in front of target door
			move_through_door(target_door)


func move_through_door(door: Door) -> void:
	# disable ghost collision shape
	_parent.get_node("CollisionShape3D").set_deferred("disabled", true)
	# set target to same position relative to door in next room
	_parent.set_target(target_door_pos_far)
	moving_through_door = true
