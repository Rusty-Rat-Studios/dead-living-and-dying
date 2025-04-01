extends GutTest

# Test 1.2.5
class TestGhostEnterStunnedState:
	extends GutTest
	
	var StateStunned: Script = load("res://src/entity/ghost/state_machine/state_stunned.gd")
	var GhostSpriteFrames: SpriteFrames = load("res://src/entity/ghost/ghost_sprite_frames.tres")
	
	var _state_stunned: GhostState
	
	func before_each() -> void:
		_state_stunned = StateStunned.new()
		_state_stunned._parent = double(Ghost).new()
		_state_stunned._parent.stats = double(GhostStats).new()
		_state_stunned._parent.sprite = double(AnimatedSprite3D).new()
		_state_stunned._parent.sprite.sprite_frames = GhostSpriteFrames
		_state_stunned.stun_timer = double(Timer).new()
		_state_stunned.collision_shape = partial_double(CollisionShape3D).new()
		_state_stunned._parent.sprite.animation = "active"
		_state_stunned.collision_shape.disabled = false
	
	
	func test_stunned_state_variables_set_correctly() -> void:
		_state_stunned.enter()
		
		await wait_frames(1) # for set_deferred call
		
		assert_eq(_state_stunned._parent.sprite.animation, "idle")
		assert_eq(_state_stunned.collision_shape.disabled, true)


# Test 1.2.6
class TestGhostExitStunnedState:
	extends GutTest
	
	var StateStunned: Script = load("res://src/entity/ghost/state_machine/state_stunned.gd")
	
	var _state_stunned: GhostState
	
	func before_each() -> void:
		_state_stunned = StateStunned.new()
		_state_stunned.collision_shape = partial_double(CollisionShape3D).new()
		_state_stunned.collision_shape.disabled = true
	
	
	func test_stunned_state_variables_unset_correctly() -> void:
		_state_stunned.exit()
		
		await wait_frames(1) # for set_deferred call
		
		assert_eq(_state_stunned.collision_shape.disabled, false)
