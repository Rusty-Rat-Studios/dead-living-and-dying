extends GutTest

# Test 1.2.9
class TestGhostEnterMovingState:
	extends GutTest
	
	var StateMoving: Script = load("res://src/entity/ghost/state_machine/state_moving.gd")
	
	var _state_moving: GhostState
	
	func before_each() -> void:
		_state_moving = partial_double(StateMoving).new()
		_state_moving._parent = double(Ghost).new()
		stub(_state_moving, "change_state").to_do_nothing()
		_state_moving.state = _state_moving.DoorStates.AFTER
	
	
	func test_moving_state_variables_set_correctly_target_door_exists() -> void:
		stub(_state_moving, "find_target_door").to_return(true)
		
		_state_moving.enter()
		
		assert_eq(_state_moving.state, _state_moving.DoorStates.BEFORE)
		assert_called(_state_moving, "find_target_door")
		assert_connected(_state_moving._parent, _state_moving, "target_reached")
		assert_called(_state_moving._parent, "set_target")
		assert_not_called(_state_moving, "change_state")
	
	
	func test_moving_state_variables_set_correctly_target_door_doesnt_exist() -> void:
		stub(_state_moving, "find_target_door").to_return(false)
		
		_state_moving.enter()
		
		assert_eq(_state_moving.state, _state_moving.DoorStates.BEFORE)
		assert_called(_state_moving, "find_target_door")
		assert_not_connected(_state_moving._parent, _state_moving, "target_reached")
		assert_not_called(_state_moving._parent, "set_target")
		assert_called(_state_moving, "change_state")


# Test 1.2.10
class TestGhostExitMovingState:
	extends GutTest
	
	var StateMoving: Script = load("res://src/entity/ghost/state_machine/state_moving.gd")
	
	var _state_moving: GhostState
	
	func before_each() -> void:
		_state_moving = partial_double(StateMoving).new()
		_state_moving._parent = double(Ghost).new()
		_state_moving._parent.target_reached.connect(_state_moving._on_target_reached)
		_state_moving.target_door = Door.new()
		_state_moving.target_door_pos_near = Vector3.FORWARD
		_state_moving.target_door_pos_far = Vector3.FORWARD
		_state_moving.target_room = Room.new()
		_state_moving.state = _state_moving.DoorStates.AFTER
	
	
	func test_moving_state_variables_set_correctly_target_door_exists() -> void:
		_state_moving.exit()
		
		assert_not_connected(_state_moving._parent, _state_moving, "target_reached")
		assert_null(_state_moving.target_door)
		assert_eq(_state_moving.target_door_pos_near, Vector3.ZERO)
		assert_eq(_state_moving.target_door_pos_far, Vector3.ZERO)
		assert_null(_state_moving.target_room)
		assert_eq(_state_moving.state, _state_moving.DoorStates.BEFORE)
