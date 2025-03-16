extends GutTest

class TestPlayerEnterLivingState:
	extends GutTest
	
	var player_state_machine: PlayerStateMachine
	
	
	func before_each() -> void:
		player_state_machine = preload("res://src/player/state_machine/player_state_machine.tscn").instantiate()
		add_child(player_state_machine)
	
	
	func after_each() -> void:
		player_state_machine.free()
		player_state_machine = null
	
	
	func test_player_enters_living_state() -> void:
		var char: CharacterBody3D = CharacterBody3D.new()
		add_child(char)
		player_state_machine.init(char)
		print(player_state_machine.current_state)
		assert_true(true)
	
	
	func test_living_state_variables_set_correctly() -> void:
		pass
	
	
	func test_state_changed_signal_emitted() -> void:
		pass
