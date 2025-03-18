extends GutTest

# Test 1.1.5
class TestPlayerEnterDeadState:
	extends GutTest
	
	var basic_test_scene: Node3D
	var player: Player
	var key_item: KeyItemInventory
	
	
	func before_each() -> void:
		basic_test_scene = preload("res://test/unit_tests/basic_test_scene.tscn").instantiate()
		player = basic_test_scene.get_node("Player")
		basic_test_scene.get_node("StateMachine/Dead").set_script(partial_double(preload("res://src/player/state_machine/state_dead.gd")))
		
		get_tree().root.add_child(basic_test_scene)
		
		player.player_stats = partial_double(preload("res://src/player/player_stats.gd")).new()
		key_item = partial_double(preload("res://src/entity/items/key_item/key_item_inventory.tscn")).instantiate()
		player.get_node("Inventory").add_child(key_item)
	
	
	func after_each() -> void:
		basic_test_scene.free()
		basic_test_scene = null
		player = null
	
	
	func test_player_in_dying_state() -> void:
		player._state_machine.change_state(PlayerStateMachine.States.DEAD)
		
		assert_eq(player._state_machine.current_state, PlayerStateMachine.States.DEAD)
	
	
	func test_dying_state_variables_set_correctly() -> void:
		player._state_machine.change_state(PlayerStateMachine.States.DEAD)
		
		assert_called(player.player_stats, "remove_stat_modifiers")
		var state_dead: Resource = preload("res://src/player/state_machine/state_dead.gd")
		assert_call_count(player.player_stats, "stat_update_add", 1, [PlayerStats.Stats.SPEED, state_dead.SPEED_MODIFIER, state_dead.DEAD_MODIFIER_NAME, -1])
		assert_eq(player.get_node("RotationOffset/AnimatedSprite3D").modulate, Color(0.5, 0.5, 0.5, 0.3))
		assert_called(key_item, "drop")
		assert_called(state_dead, "move_to_shrine")
		#assert_connected(SignalBus, basic_test_scene.get_node("StateMachine/Dying"), 'player_hurt')
		#assert_called(player.get_node("Stunbox").collision_shape, "set_deferred", ["disabled", false])
		#assert_called(basic_test_scene.get_node("UI/DyingScreenEffect"), "enable")
	
	
	func test_state_changed_signal_emitted() -> void:
		watch_signals(SignalBus)
		
		player._state_machine.change_state(PlayerStateMachine.States.DEAD)
		
		assert_signal_emitted_with_parameters(SignalBus, 'player_state_changed', [PlayerStateMachine.States.DEAD])


# Test 1.1.6
class TestPlayerExitDeadState:
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
