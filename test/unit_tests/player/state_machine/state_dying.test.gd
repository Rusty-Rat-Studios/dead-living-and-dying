extends GutTest

# Test 1.1.3
class TestPlayerEnterDyingState:
	extends GutTest
	
	var StateDying: Script = load("res://src/player/state_machine/state_dying.gd")
	var Stunbox: Script = load("res://src/player/stunbox.gd")
	var DyingScreenEffect: Script = load("res://src/ui/dying_screen_effect.gd")
	
	var _state_dying: PlayerState
	
	func before_each() -> void:
		_state_dying = StateDying.new()
		_state_dying._parent = double(Player).new()
		_state_dying._parent.player_stats = double(PlayerStats).new()
		_state_dying._state_machine = double(PlayerStateMachine).new()
		_state_dying._state_machine.current_state = PlayerStateMachine.States.DYING
		_state_dying._parent.stunbox = double(Stunbox).new()
		_state_dying._parent.stunbox.collision_shape = double(CollisionShape3D).new()
		_state_dying.screen_effect = double(DyingScreenEffect).new()
	
	
	func test_dying_state_variables_set_correctly() -> void:
		_state_dying.enter()
		
		assert_call_count(_state_dying._parent.player_stats, "stat_update_add", 1, [PlayerStats.Stats.SPEED, StateDying.SPEED_MODIFIER, StateDying.NAME, -1])
		assert_call_count(_state_dying._parent.player_stats, "stat_update_add", 1, [PlayerStats.Stats.LIGHT_OMNI_RANGE, StateDying.LIGHT_OMNI_RANGE_MODIFIER, StateDying.NAME, -1])
		assert_call_count(_state_dying._parent.player_stats, "stat_update_add", 1, [PlayerStats.Stats.LIGHT_SPOT_RANGE, StateDying.LIGHT_SPOT_RANGE_MODIFIER, StateDying.NAME, -1])
		assert_connected(SignalBus, _state_dying, 'player_hurt')
		assert_called(_state_dying._parent.stunbox.collision_shape, "set_deferred", ["disabled", false])
		assert_called(_state_dying._parent.stunbox, "stun")
		assert_called(_state_dying.screen_effect, "enable")
	
	
	func test_state_changed_signal_emitted() -> void:
		watch_signals(SignalBus)
		_state_dying.enter()
		
		assert_signal_emitted_with_parameters(SignalBus, 'player_state_changed', [PlayerStateMachine.States.DYING])


# Test 1.1.4
class TestPlayerExitDyingState:
	extends GutTest
	
	var StateDying: Script = load("res://src/player/state_machine/state_dying.gd")
	var Stunbox: Script = load("res://src/player/stunbox.gd")
	var DyingScreenEffect: Script = load("res://src/ui/dying_screen_effect.gd")
	
	var _state_dying: PlayerState
	
	func before_each() -> void:
		_state_dying = StateDying.new()
		_state_dying._parent = double(Player).new()
		_state_dying._parent.player_stats = double(PlayerStats).new()
		_state_dying._state_machine = double(PlayerStateMachine).new()
		_state_dying._parent.stunbox = double(Stunbox).new()
		_state_dying._parent.stunbox.collision_shape = double(CollisionShape3D).new()
		_state_dying.screen_effect = double(DyingScreenEffect).new()
		_state_dying.enter()
	
	
	func test_dying_state_variables_unset_correctly() -> void:
		_state_dying.exit()
		
		assert_not_connected(SignalBus, _state_dying, 'player_hurt')
		assert_called(_state_dying._parent.stunbox.collision_shape, "set_deferred", ["disabled", true])
		assert_called(_state_dying._parent.stunbox, "restore_instantly")
		assert_called(_state_dying.screen_effect, "disable")
