extends Node

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func set_seed(seed: int) -> void:
	rng.seed = seed


func get_seed() -> int:
	return rng.seed


# Given a list of items, pick one at random (equally weighted)
func random_from_list(list: Array) -> Variant:
	var choices: Dictionary[Variant, float] = {}
	for item: Variant in list:
		choices[item] = 1
	return weighted_random(choices)
 

# Given a dictionary in the format of {item: weight} pick an item from the 
# dictionary respecting the weights. (Ex. {a:1, b:2} item b is twice as likely 
# to be chosen as a)
func weighted_random(choices: Dictionary[Variant, float]) -> Variant:
	var weights: PackedFloat32Array = PackedFloat32Array(choices.values())
	var items: Array = choices.keys()
	var weighted_index: int = rng.rand_weighted(weights)
	return items[weighted_index]


# call the output of random_from_list()
func call_random_from_list(list: Array[Callable]) -> Variant:
	return random_from_list(list).call()


# call the output of weighted_random() (Dict keys should be Callable)
func call_weighted_random(choices: Dictionary[Callable, float]) -> Variant:
	return weighted_random(choices).call()


# asynchronously call the output of weighted_random() (Dict keys should be Callable)
func call_async_weighted_random(choices: Dictionary[Callable, float]) -> Variant:
	return await weighted_random(choices).call()
