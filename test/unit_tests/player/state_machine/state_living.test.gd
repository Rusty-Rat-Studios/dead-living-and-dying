extends GutTest

# Test 1.1.1
class TestPlayerEnterLivingState:
	extends GutTest
	
	var basic_test_scene: Node3D
	var player: Player
	
	
	func before_each() -> void:
		basic_test_scene = preload("res://test/unit_tests/basic_test_scene.tscn").instantiate()
		player = basic_test_scene.get_node("Player")
		player.set_script(partial_double(preload("res://src/player/player.gd")))
		get_tree().root.add_child(basic_test_scene)
	
	
	func after_each() -> void:
		basic_test_scene.free()
		basic_test_scene = null
		player = null
	
	
	func test_player_in_living_state() -> void:
		player._state_machine.change_state(PlayerStateMachine.States.LIVING)
		
		assert_eq(player._state_machine.current_state, PlayerStateMachine.States.LIVING)
	
	
	func test_living_state_variables_set_correctly() -> void:
		player._state_machine.change_state(PlayerStateMachine.States.LIVING)
		
		assert_called(player, 'inventory_update')
		assert_connected(SignalBus, basic_test_scene.get_node("StateMachine/Living"), 'player_hurt')
	
	
	func test_state_changed_signal_emitted() -> void:
		watch_signals(SignalBus)
		
		player._state_machine.change_state(PlayerStateMachine.States.LIVING)
		
		assert_signal_emitted_with_parameters(SignalBus, 'player_state_changed', [PlayerStateMachine.States.LIVING])


# Test 1.1.2
class TestPlayerExitLivingState:
	extends GutTest
	
	var basic_test_scene: Node3D
	var player: Player

	
	func before_each() -> void:
		basic_test_scene = preload("res://test/unit_tests/basic_test_scene.tscn").instantiate()
		player = basic_test_scene.get_node("Player")
		player.set_script(partial_double(preload("res://src/player/player.gd")))
		get_tree().root.add_child(basic_test_scene)
	
	
	func after_each() -> void:
		basic_test_scene.free()
		basic_test_scene = null
		player = null
	
	
	func test_player_not_in_living_state() -> void:
		player._state_machine.change_state(PlayerStateMachine.States.DYING)
		
		assert_ne(player._state_machine.current_state, PlayerStateMachine.States.LIVING)
