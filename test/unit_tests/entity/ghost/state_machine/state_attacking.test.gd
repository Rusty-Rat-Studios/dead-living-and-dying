extends GutTest

# Test 1.2.7
class TestGhostEnterAttackingState:
	extends GutTest
	
	var StateAttacking: Script = load("res://src/entity/ghost/state_machine/state_attacking.gd")
	var GhostSpriteFrames: SpriteFrames = load("res://src/entity/ghost/ghost_sprite_frames.tres")
	
	var _state_attacking: GhostState
	
	func before_each() -> void:
		_state_attacking = partial_double(StateAttacking).new()
		_state_attacking._parent = double(Ghost).new()
		_state_attacking._parent.sprite = double(AnimatedSprite3D).new()
		_state_attacking._parent.sprite.sprite_frames = GhostSpriteFrames
		_state_attacking.attack_range_collision_shape = partial_double(CollisionShape3D).new()
		stub(_state_attacking, "change_state").to_do_nothing()
		_state_attacking._parent.sprite.modulate = Color(0.5, 0.6, 0.7, 0.8)
		_state_attacking.base_color = Color(0, 0, 0, 0)
		_state_attacking._parent.speed = 0
		_state_attacking._parent.at_target = false
		_state_attacking.attack_range_collision_shape.disabled = true
		_state_attacking.winding_up = true
	
	
	func test_attacking_state_variables_set_correctly_player_not_attackable() -> void:
		stub(_state_attacking, "is_player_attackable").to_return(false)
		
		_state_attacking.enter()
		
		await wait_frames(1) # for set_deferred call
		
		assert_eq(_state_attacking.base_color, _state_attacking._parent.sprite.modulate)
		assert_called(_state_attacking, "change_state")
		assert_ne(_state_attacking._parent.speed, _state_attacking.PRE_ATTACK_SPEED)
		assert_ne(_state_attacking.attack_range_collision_shape.disabled, false)
		assert_ne(_state_attacking.winding_up, false)
		assert_not_connected(SignalBus, _state_attacking, "player_state_changed")
		assert_not_connected(SignalBus, _state_attacking, "player_exited_room")
	
	
	func test_attacking_state_variables_set_correctly_player_attackable() -> void:
		stub(_state_attacking, "is_player_attackable").to_return(true)
		
		_state_attacking.enter()
		
		await wait_frames(1) # for set_deferred call
		
		assert_eq(_state_attacking.base_color, _state_attacking._parent.sprite.modulate)
		assert_not_called(_state_attacking, "change_state")
		assert_eq(_state_attacking._parent.speed, _state_attacking.PRE_ATTACK_SPEED)
		assert_eq(_state_attacking.attack_range_collision_shape.disabled, false)
		assert_eq(_state_attacking.winding_up, false)
		assert_connected(SignalBus, _state_attacking, "player_state_changed")
		assert_connected(SignalBus, _state_attacking, "player_exited_room")


# Test 1.2.8
class TestGhostExitAttackingState:
	extends GutTest
	
	var StateAttacking: Script = load("res://src/entity/ghost/state_machine/state_attacking.gd")
	
	var _state_attacking: GhostState
	
	func before_each() -> void:
		_state_attacking = partial_double(StateAttacking).new()
		_state_attacking._parent = double(Ghost).new()
		_state_attacking._parent.sprite = double(AnimatedSprite3D).new()
		_state_attacking.attack_range_collision_shape = partial_double(CollisionShape3D).new()
		_state_attacking.sprite_shaker = double(SpriteShaker).new()
		_state_attacking._parent.speed = 0
		_state_attacking.attack_range_collision_shape.disabled = false
		_state_attacking.base_color = Color(0, 0, 0, 0)
		_state_attacking._parent.sprite.modulate = Color(0.5, 0.5, 0.5, 1.0)
		SignalBus.player_state_changed.connect(_state_attacking._on_player_state_changed)
		SignalBus.player_exited_room.connect(_state_attacking._on_player_exited_room)
		
	
	
	func test_attacking_state_variables_unset_correctly() -> void:
		_state_attacking.exit()
		
		await wait_frames(1) # for set_deferred call
		
		assert_eq(_state_attacking._parent.speed, _state_attacking._parent.BASE_SPEED)
		assert_eq(_state_attacking.attack_range_collision_shape.disabled, true)
		assert_called(_state_attacking.sprite_shaker, "halt")
		assert_eq(_state_attacking._parent.sprite.modulate, _state_attacking.base_color)
		assert_called(_state_attacking._parent, "set_target")
		assert_not_connected(SignalBus, _state_attacking, "player_state_changed")
		assert_not_connected(SignalBus, _state_attacking, "player_exited_room")
