extends GutTest

# Test 1.1.1
class TestPlayerEnterLivingState:
	extends GutTest
	
	var StateLiving: Script = load("res://src/player/state_machine/state_living.gd")
	
	var _state_living: PlayerState
	
	func before_each() -> void:
		_state_living = StateLiving.new()
		_state_living._parent = double(Player).new()
		stub(_state_living._parent, "inventory_update").to_do_nothing()
		_state_living._state_machine = double(PlayerStateMachine).new()
		_state_living._state_machine.current_state = PlayerStateMachine.States.LIVING
	
	
	func test_living_state_variables_set_correctly() -> void:
		_state_living.enter()
		
		assert_called(_state_living._parent, "inventory_update")
		assert_connected(SignalBus, _state_living, 'player_hurt')
	
	
	func test_state_changed_signal_emitted() -> void:
		watch_signals(SignalBus)
		_state_living.enter()
		
		assert_signal_emitted_with_parameters(SignalBus, 'player_state_changed', [PlayerStateMachine.States.LIVING])


# Test 1.1.2
class TestPlayerExitLivingState:
	extends GutTest
	
	var StateLiving: Script = load("res://src/player/state_machine/state_living.gd")
	
	var _state_living: PlayerState
	
	func before_each() -> void:
		_state_living = StateLiving.new()
		_state_living._parent = double(Player).new()
		stub(_state_living._parent, "inventory_update").to_do_nothing()
		_state_living._state_machine = double(PlayerStateMachine).new()
		_state_living.enter()
	
	
	func test_living_state_variables_unset_correctly() -> void:
		_state_living.exit()
		
		assert_not_connected(SignalBus, _state_living, 'player_hurt')
