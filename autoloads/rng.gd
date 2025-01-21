extends Node

var _rng: RandomNumberGenerator


func _ready() -> void:
	_rng = RandomNumberGenerator.new()


func get_rng() -> RandomNumberGenerator:
	return _rng


func set_seed(seed: int) -> void:
	_rng.seed = seed


func get_seed() -> int:
	return _rng.seed


func random_from_list(list: Array) -> Variant:
	var choices: Dictionary = {}
	for item: Variant in list:
		choices[item] = 1
	return weighted_random(choices)
 

func weighted_random(choices: Dictionary) -> Variant:
	var weights: PackedFloat32Array = PackedFloat32Array(choices.values())
	var items: Array = choices.keys()
	var weighted_index: int = _rng.rand_weighted(weights)
	return items[weighted_index]
