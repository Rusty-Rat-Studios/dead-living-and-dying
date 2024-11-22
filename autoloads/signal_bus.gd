extends Node

# signal for communicating player state to all interested nodes
# e.g. Game node making universal changes (e.g. lighting) based on player state 
signal player_state_changed(state_name: String)

# when the player takes damage. caught by player states to cause state change
signal player_hurt

# signifies player hit cooldown has finished, used to determine if player is
# still intersecting an area they should take damage from
signal hit_cooldown_finished

# signal for communicating player entering and leaving a room
# passes the room instance which ghosts can match against their
# current_room variable
signal player_entered_room(room: Node3D)
signal player_exited_room(room: Node3D)

signal player_entered_shrine
