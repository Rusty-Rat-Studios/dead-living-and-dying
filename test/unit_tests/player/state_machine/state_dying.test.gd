extends GutTest

# Test 1.1.3
class TestPlayerEnterDyingState:
	extends GutTest
	
	var basic_test_scene: Node3D
	var player: Player
	
	
	func before_each() -> void:
		basic_test_scene = preload("res://test/unit_tests/basic_test_scene.tscn").instantiate()
		player = basic_test_scene.get_node("Player")
		basic_test_scene.get_node("UI/DyingScreenEffect").set_script(partial_double(preload("res://src/ui/dying_screen_effect.gd")))
		player.get_node("Stunbox").set_script(partial_double(preload("res://src/player/stunbox.gd")))
		
		get_tree().root.add_child(basic_test_scene)
		
		player.player_stats = partial_double(preload("res://src/player/player_stats.gd")).new()
		stub(player.stunbox, "stun").to_do_nothing()
		player.get_node("Stunbox").collision_shape = double(CollisionShape3D).new()
	
	
	func after_each() -> void:
		basic_test_scene.free()
		basic_test_scene = null
		player = null
	
	
	func test_player_in_dying_state() -> void:
		player._state_machine.change_state(PlayerStateMachine.States.DYING)
		
		assert_eq(player._state_machine.current_state, PlayerStateMachine.States.DYING)
	
	
	func test_dying_state_variables_set_correctly() -> void:
		player._state_machine.change_state(PlayerStateMachine.States.DYING)
		
		var state_dying: Resource = preload("res://src/player/state_machine/state_dying.gd")
		assert_call_count(player.player_stats, "stat_update_add", 1, [PlayerStats.Stats.SPEED, state_dying.SPEED_MODIFIER, state_dying.NAME, -1])
		assert_call_count(player.player_stats, "stat_update_add", 1, [PlayerStats.Stats.LIGHT_OMNI_RANGE, state_dying.LIGHT_OMNI_RANGE_MODIFIER, state_dying.NAME, -1])
		assert_call_count(player.player_stats, "stat_update_add", 1, [PlayerStats.Stats.LIGHT_SPOT_RANGE, state_dying.LIGHT_SPOT_RANGE_MODIFIER, state_dying.NAME, -1])
		assert_connected(SignalBus, basic_test_scene.get_node("StateMachine/Dying"), 'player_hurt')
		assert_called(player.get_node("Stunbox").collision_shape, "set_deferred", ["disabled", false])
		assert_called(basic_test_scene.get_node("UI/DyingScreenEffect"), "enable")
	
	
	func test_state_changed_signal_emitted() -> void:
		watch_signals(SignalBus)
		
		player._state_machine.change_state(PlayerStateMachine.States.DYING)
		
		assert_signal_emitted_with_parameters(SignalBus, 'player_state_changed', [PlayerStateMachine.States.DYING])


# Test 1.1.4
class TestPlayerExitDyingState:
	extends GutTest
	
	var basic_test_scene: Node3D
	var player: Player

	
	func before_each() -> void:
		basic_test_scene = preload("res://test/unit_tests/basic_test_scene.tscn").instantiate()
		player = basic_test_scene.get_node("Player")
		basic_test_scene.get_node("UI/DyingScreenEffect").set_script(partial_double(preload("res://src/ui/dying_screen_effect.gd")))
		player.get_node("Stunbox").set_script(partial_double(preload("res://src/player/stunbox.gd")))
		
		get_tree().root.add_child(basic_test_scene)
		
		player.get_node("Stunbox").collision_shape = double(CollisionShape3D).new()
		player._state_machine.change_state(PlayerStateMachine.States.DYING)
	
	
	func after_each() -> void:
		basic_test_scene.free()
		basic_test_scene = null
		player = null
	
	
	func test_player_not_in_dying_state() -> void:
		player._state_machine.change_state(PlayerStateMachine.States.DEAD)
		
		assert_ne(player._state_machine.current_state, PlayerStateMachine.States.DYING)
	
	
	func test_dying_state_variables_unset_correctly() -> void:
		player._state_machine.change_state(PlayerStateMachine.States.DEAD)
		
		assert_not_connected(SignalBus, basic_test_scene.get_node("StateMachine/Dying"), 'player_hurt')
		assert_called(player.get_node("Stunbox").collision_shape, "set_deferred", ["disabled", true])
		assert_called(player.get_node("Stunbox"), "restore_instantly")
		assert_called(basic_test_scene.get_node("UI/DyingScreenEffect"), "disable")
