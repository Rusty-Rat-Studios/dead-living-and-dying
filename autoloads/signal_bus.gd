extends Node

# signal for communicating player state to all interested nodes
# e.g. Game node making universal changes (e.g. lighting) based on player state 
@warning_ignore("unused_signal") signal player_state_changed(state_name: String)

# when the player takes damage. caught by player states to cause state change
@warning_ignore("unused_signal") signal player_hurt
@warning_ignore("unused_signal") signal game_over

# signal for communicating player entering and leaving a room
# passes the room instance which ghosts can match against their
# current_room variable
@warning_ignore("unused_signal") signal player_entered_room(room: Node3D)
@warning_ignore("unused_signal") signal player_exited_room(room: Node3D)

# emitted when player contacts their corpse in DEAD state
@warning_ignore("unused_signal") signal player_revived(corpse_position: Vector3)

# emitted by item when the player interacts to pick it up
@warning_ignore("unused_signal") signal item_picked_up(item: Area3D)
