extends GutTest

# Test 1.2.3
class TestGhostEnterPossessingState:
	extends GutTest
	
	var StatePossessing: Script = load("res://src/entity/ghost/state_machine/state_possessing.gd")
	var GhostSpriteFrames: SpriteFrames = load("res://src/entity/ghost/ghost_sprite_frames.tres")
	
	var _state_possessing: GhostState
	
	func before_each() -> void:
		_state_possessing = partial_double(StatePossessing).new()
		_state_possessing._parent = double(Ghost).new()
		_state_possessing._parent.stats = double(GhostStats).new()
		_state_possessing._parent.sprite = double(AnimatedSprite3D).new()
		_state_possessing._parent.sprite.sprite_frames = GhostSpriteFrames
		_state_possessing._parent.current_room = double(Room).new()
		_state_possessing.detector_collision_shape = partial_double(CollisionShape3D).new()
		_state_possessing.decision_timer = double(Timer).new()
		stub(_state_possessing, "set_closest_target").to_do_nothing()
	
	
	func test_possessing_state_variables_set_correctly_player_in_room() -> void:
		_state_possessing.detector_collision_shape.disabled = true
		_state_possessing._parent.player_in_room = true
		_state_possessing._parent.stats.speed = 0
		_state_possessing._parent.sprite.animation = "idle"
		_state_possessing.detector_collision_shape.disabled = true
		_state_possessing.decision_timer.wait_time = 1
		_state_possessing.attack_delay = 100
		_state_possessing.can_attack = false
		
		_state_possessing.enter()
		
		await wait_frames(1) # for set_deferred call
		
		assert_eq(_state_possessing._parent.sprite.animation, "active")
		assert_eq(_state_possessing.detector_collision_shape.disabled, false)
		assert_eq(_state_possessing.decision_timer.wait_time, _state_possessing.DECISION_TIME)
		assert_eq(_state_possessing.attack_delay, 0.0)
		assert_eq(_state_possessing.can_attack, true)
		assert_connected(SignalBus, _state_possessing, "player_state_changed")
		assert_connected(SignalBus, _state_possessing, "player_entered_room")
		assert_connected(SignalBus, _state_possessing, "player_exited_room")
		assert_connected(_state_possessing._parent, _state_possessing, "hit")
	
	
	func test_possessing_state_variables_set_correctly_player_not_in_room() -> void:
		_state_possessing.detector_collision_shape.disabled = true
		_state_possessing._parent.player_in_room = false
		_state_possessing._parent.stats.speed = 0
		_state_possessing._parent.sprite.animation = "idle"
		_state_possessing.detector_collision_shape.disabled = true
		_state_possessing.decision_timer.wait_time = 1
		_state_possessing.attack_delay = 0
		_state_possessing.can_attack = true
		
		_state_possessing.enter()
		
		await wait_frames(1) # for set_deferred call
		
		assert_eq(_state_possessing._parent.sprite.animation, "active")
		assert_eq(_state_possessing.detector_collision_shape.disabled, false)
		assert_eq(_state_possessing.decision_timer.wait_time, _state_possessing.DECISION_TIME)
		assert_eq(_state_possessing.attack_delay, _state_possessing.DECISION_TIME)
		assert_eq(_state_possessing.can_attack, false)
		assert_connected(SignalBus, _state_possessing, "player_state_changed")
		assert_connected(SignalBus, _state_possessing, "player_entered_room")
		assert_connected(SignalBus, _state_possessing, "player_exited_room")
		assert_connected(_state_possessing._parent, _state_possessing, "hit")


# Test 1.2.4
class TestGhostExitPossessingState:
	extends GutTest
	
	var StatePossessing: Script = load("res://src/entity/ghost/state_machine/state_possessing.gd")
	
	var _state_possessing: GhostState
	var _possessable: Possessable
	
	func before_each() -> void:
		_state_possessing = StatePossessing.new()
		_state_possessing._parent = double(Ghost).new()
		_state_possessing._parent.current_room = double(Room).new()
		_state_possessing.detector_collision_shape = partial_double(CollisionShape3D).new()
		_state_possessing.decision_timer = double(Timer).new()
		_possessable = double(Possessable).new()
		_state_possessing.target_possessable = _possessable
		
		SignalBus.player_state_changed.connect(_state_possessing._on_player_state_changed)
		SignalBus.player_entered_room.connect(_state_possessing._on_player_entered_room)
		SignalBus.player_exited_room.connect(_state_possessing._on_player_exited_room)
		_state_possessing._parent.hit.connect(_state_possessing._on_hit)
		_state_possessing.is_possessing = true
	
	
	func test_possessing_state_variables_unset_correctly() -> void:
		_state_possessing.exit()
		
		await wait_frames(1) # for set_deferred call
		
		assert_eq(_state_possessing.detector_collision_shape.disabled, true)
		assert_called(_possessable, "depossess")
		assert_eq(_state_possessing.is_possessing, false)
		assert_null(_state_possessing.target_possessable)
		assert_not_connected(SignalBus, _state_possessing, "player_state_changed")
		assert_not_connected(SignalBus, _state_possessing, "player_entered_room")
		assert_not_connected(SignalBus, _state_possessing, "player_exited_room")
		assert_not_connected(_state_possessing._parent, _state_possessing, "hit")
