extends Node

# signal for communicating player state to all interested nodes
# e.g. Game node making universal changes (e.g. lighting) based on player state 
signal player_state_changed(state_name: String)

# when the player takes damage. caught by player states to cause state change
signal player_hurt

signal game_over

# signal for communicating player entering and leaving a room
# passes the room instance which ghosts can match against their
# current_room variable
signal player_entered_room(room: Node3D)
signal player_exited_room(room: Node3D)

# used when player activates shrine
signal activated_shrine(shrine: Shrine)
# used when player revives at a shrine
signal consumed_shrine(shrine: Shrine)

# emitted when player contacts their corpse in DEAD state
signal player_revived(corpse_position: Vector3)
