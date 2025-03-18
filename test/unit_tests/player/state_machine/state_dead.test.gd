extends GutTest

# Test 1.1.5
class TestPlayerEnterDeadState:
	extends GutTest
	
	var StateDead: Script = load("res://src/player/state_machine/state_dead.gd")
	var Hurtbox: Script = load("res://src/player/hurtbox.gd")
	
	var _state_dead: PlayerState
	var _key_item: KeyItemInventory
	
	func before_each() -> void:
		_state_dead = partial_double(StateDead).new()
		_state_dead._parent = double(Player).new()
		_state_dead._parent.player_stats = double(PlayerStats).new()
		_state_dead._parent._corpse = double(Corpse).new()
		_state_dead._parent._corpse_indicator = double(GPUParticles3D).new()
		_state_dead._parent.hurtbox = double(Hurtbox).new()
		_state_dead._parent.light_omni = double(OmniLight3D).new()
		_state_dead._parent.light_spot = double(SpotLight3D).new()
		_state_dead._state_machine = double(PlayerStateMachine).new()
		_key_item = double(KeyItemInventory).new()
		stub(_state_dead._parent, "get_key_item_or_null").to_return(_key_item)
		stub(_state_dead, "move_to_shrine").to_do_nothing()
		_state_dead._state_machine.current_state = PlayerStateMachine.States.DEAD
		_state_dead._parent._corpse_indicator.emitting = false
		_state_dead._parent.collision_layer = 0
		_state_dead._parent.collision_mask = 0
		_state_dead._parent.hurtbox.collision_mask = 0
		_state_dead._parent.light_omni.visible = true
		_state_dead._parent.light_spot.visible = true
	
	
	func test_dead_state_variables_set_correctly() -> void:
		_state_dead.enter()
		
		assert_called(_state_dead._parent.player_stats, "remove_stat_modifiers")
		assert_call_count(_state_dead._parent.player_stats, "stat_update_add", 1, [PlayerStats.Stats.SPEED, StateDead.SPEED_MODIFIER, StateDead.DEAD_MODIFIER_NAME, -1])
		assert_called(_state_dead._parent, "modulate_color")
		assert_called(_key_item, "drop")
		assert_called(_state_dead, "move_to_shrine")
		assert_called(_state_dead._parent._corpse, "activate")
		assert_eq(_state_dead._parent._corpse_indicator.emitting, true)
		assert_eq(_state_dead._parent.collision_layer, CollisionBit.PLAYER + CollisionBit.SPIRIT)
		assert_eq(_state_dead._parent.collision_mask, CollisionBit.WORLD)
		assert_eq(_state_dead._parent.hurtbox.collision_mask, CollisionBit.SPIRIT)
		assert_connected(SignalBus, _state_dead, "player_hurt")
		assert_connected(SignalBus, _state_dead, "player_escaped")
		assert_connected(SignalBus, _state_dead, "player_revived")
		assert_connected(SignalBus, _state_dead, "player_exited_room")
		assert_eq(_state_dead._parent.light_omni.visible, false)
		assert_eq(_state_dead._parent.light_spot.visible, false)
	
	
	func test_state_changed_signal_emitted() -> void:
		watch_signals(SignalBus)
		_state_dead.enter()
		
		assert_signal_emitted_with_parameters(SignalBus, 'player_state_changed', [PlayerStateMachine.States.DEAD])


# Test 1.1.6
class TestPlayerExitDeadState:
	extends GutTest
	
	var StateDead: Script = load("res://src/player/state_machine/state_dead.gd")
	var Hurtbox: Script = load("res://src/player/hurtbox.gd")
	
	var _state_dead: PlayerState
	
	func before_each() -> void:
		_state_dead = partial_double(StateDead).new()
		_state_dead._parent = double(Player).new()
		_state_dead._parent.player_stats = double(PlayerStats).new()
		_state_dead._parent._corpse = double(Corpse).new()
		_state_dead._parent._corpse_indicator = double(GPUParticles3D).new()
		_state_dead._parent.hurtbox = double(Hurtbox).new()
		_state_dead._parent.light_omni = double(OmniLight3D).new()
		_state_dead._parent.light_spot = double(SpotLight3D).new()
		_state_dead._state_machine = double(PlayerStateMachine).new()
		_state_dead.dead_light = partial_double(DirectionalLight3D).new()
		_state_dead.attacked_increment_timer = double(Timer).new()
		_state_dead.enter()
		_state_dead._parent._corpse_indicator.emitting = true
		_state_dead._parent.collision_layer = 0
		_state_dead._parent.collision_mask = 0
		_state_dead._parent.hurtbox.collision_mask = 0
		_state_dead._parent.light_omni.visible = false
		_state_dead._parent.light_spot.visible = false
		_state_dead.dead_light_energy_default = 1234.0
		_state_dead.attacked_modifier = 1234.0
	
	
	func test_dead_state_variables_unset_correctly() -> void:
		_state_dead.exit()
		
		assert_eq(_state_dead._parent.light_omni.visible, true)
		assert_eq(_state_dead._parent.light_spot.visible, true)
		assert_called(_state_dead._parent.player_stats, "remove_stat_modifiers")
		assert_eq(_state_dead.dead_light.light_energy, _state_dead.dead_light_energy_default)
		assert_eq(_state_dead.attacked_modifier, 0.0)
		assert_called(_state_dead._parent, "modulate_color", [Color(1, 1, 1, 1)])
		assert_eq(_state_dead._parent.collision_layer, CollisionBit.PLAYER + CollisionBit.PHYSICAL)
		assert_eq(_state_dead._parent.collision_mask, CollisionBit.WORLD)
		assert_eq(_state_dead._parent.hurtbox.collision_mask, CollisionBit.PHYSICAL)
		assert_called(_state_dead._parent._corpse_indicator, "restart")
		assert_eq(_state_dead._parent._corpse_indicator.emitting, false)
		assert_not_connected(SignalBus, _state_dead, "player_hurt")
		assert_not_connected(SignalBus, _state_dead, "player_escaped")
		assert_not_connected(SignalBus, _state_dead, "player_revived")
		assert_not_connected(SignalBus, _state_dead, "player_exited_room")
