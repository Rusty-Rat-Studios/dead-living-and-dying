extends GutTest

# Test 1.1.1
class TestPlayerEnterLivingState:
	extends GutTest
	
	var _state_machine: PlayerStateMachine
	var _player: CharacterBody3D
	
	func before_each() -> void:
		_state_machine = PlayerStateMachine.new()
		_player = double(CharacterBody3D).new()
		_state_machine.init(_player)
	
	func test_player_in_living_state() -> void:
		_state_machine.change_state(PlayerStateMachine.States.LIVING)
		
		assert_eq(_state_machine.current_state, PlayerStateMachine.States.LIVING)
