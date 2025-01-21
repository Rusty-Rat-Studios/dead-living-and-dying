extends Node

@onready var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


# Returns the basic rng object so that basic random functions can be called
func get_rng() -> RandomNumberGenerator:
	return _rng


func set_seed(seed: int) -> void:
	_rng.seed = seed


func get_seed() -> int:
	return _rng.seed


# Given a list of items, pick one at random (equally weighted)
func random_from_list(list: Array) -> Variant:
	var choices: Dictionary = {}
	for item: Variant in list:
		choices[item] = 1
	return weighted_random(choices)
 

# Given a dictionary in the format of {item: weight} pick an item from the 
# dictionary respecting the weights. (Ex. {a:1, b:2} item b is twice as likely 
# to be chosen as a)
func weighted_random(choices: Dictionary) -> Variant:
	var weights: PackedFloat32Array = PackedFloat32Array(choices.values())
	var items: Array = choices.keys()
	var weighted_index: int = _rng.rand_weighted(weights)
	return items[weighted_index]
