extends Node

# define global names for bitmask collision layers
enum {
	WORLD = 1,
	PLAYER = 2,
	PHYSICAL = 4,
	SPIRIT = 8,
	ITEM = 16,
	POSSESABLE = 32,
	OBJECT_BLOCKER = 64, # used to prevent physical objects being pushed through doors
	PHYSICAL_DAMAGE = 128 # used by possessables to deal damage to player
}
