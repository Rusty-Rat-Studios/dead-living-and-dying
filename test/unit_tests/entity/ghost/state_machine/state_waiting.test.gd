extends GutTest

# Test 1.2.1
class TestGhostEnterWaitingState:
	extends GutTest
	
	var StateWaiting: Script = load("res://src/entity/ghost/state_machine/state_waiting.gd")
	var GhostSpriteFrames: SpriteFrames = load("res://src/entity/ghost/ghost_sprite_frames.tres")
	
	var _state_waiting: GhostState
	
	func before_each() -> void:
		_state_waiting = partial_double(StateWaiting).new()
		_state_waiting._parent = double(Ghost).new()
		_state_waiting._parent.sprite = double(AnimatedSprite3D).new()
		_state_waiting._parent.sprite.sprite_frames = GhostSpriteFrames
		_state_waiting._parent.current_room = double(Room, DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
		var polygon: PackedVector2Array = PackedVector2Array([
			Vector2(-8, -8),
			Vector2(-8, 8),
			Vector2(8, 8),
			Vector2(8, -8)
		])
		stub(_state_waiting._parent.current_room, "get_room_polygon").to_return(polygon)
		stub(_state_waiting, "set_random_target").to_do_nothing()
		_state_waiting._parent.speed = 9999
		_state_waiting._parent.sprite.animation = "active"
		_state_waiting.is_paused = true
	
	
	func test_waiting_state_variables_set_correctly() -> void:
		_state_waiting.enter()
		
		assert_eq(_state_waiting._parent.speed, StateWaiting.WAITING_SPEED)
		assert_eq(_state_waiting._parent.sprite.animation, "idle")
		assert_eq(_state_waiting.is_paused, false)
		assert_called(_state_waiting, "set_random_target")


# Test 1.2.2
class TestGhostExitWaitingState:
	extends GutTest
	
	var StateWaiting: Script = load("res://src/entity/ghost/state_machine/state_waiting.gd")
	
	var _state_waiting: GhostState
	
	func before_each() -> void:
		_state_waiting = StateWaiting.new()
		_state_waiting._parent = double(Ghost).new()
		_state_waiting.pause_timer = double(Timer).new()
		# _state_waiting._parent.target_pos = Vector3(0, 0, 0)
		# _state_waiting._parent.global_position = Vector3(1, 1, 1)
		_state_waiting._parent.speed = 0
		_state_waiting.is_paused = true
	
	
	func test_waiting_state_variables_unset_correctly() -> void:
		_state_waiting.exit()
		
		# Cannot test as it uses global_position which refuses to work correctly if not in tree
		# Test manually (This goes for all GhostStates)
		# assert_eq(_state_waiting._parent.target_pos, Vector3(1, 1, 1))
		
		assert_eq(_state_waiting._parent.speed, _state_waiting._parent.BASE_SPEED)
		assert_eq(_state_waiting.is_paused, false)
