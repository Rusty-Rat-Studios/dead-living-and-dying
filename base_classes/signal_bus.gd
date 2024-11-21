extends Node

# signal for communicating player state to all interested nodes
# e.g. Game node making universal changes (e.g. lighting) based on player state 
signal player_state_changed(state_name: String)
