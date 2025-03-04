class_name PlayerStats
extends Resource

#used when calling stat_update
enum Stats {
	SPEED,
	LIGHT_OMNI_RANGE,
	LIGHT_SPOT_RANGE,
	LIGHT_ENERGY,
	COOLDOWN_REDUCTION,
	DURATION,
	AREA_SIZE
}

#player base stats
const BASE_SPEED: float = 6.0
const BASE_COOLDOWN_REDUCTION: float = 1.0
const BASE_DURATION: float = 1.0
const BASE_AREA_SIZE: float = 1.0

# base values used for light range and strength
const BASE_LIGHT_OMNI_RANGE: float = 6.0
const BASE_LIGHT_SPOT_RANGE: float = 10.0
const BASE_LIGHT_ENERGY: float = 1.0

class CurrentStats:
	var stat_modifier_speed: Dictionary = {}
	var stat_modifier_light_omni_range: Dictionary = {}
	var stat_modifier_light_spot_range: Dictionary = {}
	var stat_modifier_light_energy: Dictionary = {}
	var stat_modifier_cooldown_reduction: Dictionary = {}
	var stat_modifier_duration: Dictionary = {}
	var stat_modifier_area_size: Dictionary = {}
	
	var speed: float = BASE_SPEED + dictionary_sum(stat_modifier_speed)
	var light_omni_range: float = BASE_LIGHT_OMNI_RANGE + dictionary_sum(stat_modifier_light_omni_range)
	var light_spot_range: float = BASE_LIGHT_SPOT_RANGE + dictionary_sum(stat_modifier_light_spot_range)
	var light_energy: float = BASE_LIGHT_ENERGY + dictionary_sum(stat_modifier_light_energy)
	var cooldown_reduction: float = BASE_COOLDOWN_REDUCTION + dictionary_sum(stat_modifier_cooldown_reduction)
	var duration: float = BASE_DURATION + dictionary_sum(stat_modifier_duration)
	var area_size: float = BASE_AREA_SIZE + dictionary_sum(stat_modifier_area_size)
	
	
	func dictionary_sum(stat_modifier: Dictionary)-> float:
		var total_modifier: float = 0.0
		for i: String in stat_modifier:
			total_modifier += stat_modifier[i]
		return total_modifier
	
	
	func update_stats()-> void:
		speed = BASE_SPEED + dictionary_sum(stat_modifier_speed)
		light_omni_range = BASE_LIGHT_OMNI_RANGE + dictionary_sum(stat_modifier_light_omni_range)
		light_spot_range = BASE_LIGHT_SPOT_RANGE + dictionary_sum(stat_modifier_light_spot_range)
		light_energy = BASE_LIGHT_ENERGY + dictionary_sum(stat_modifier_light_energy)
		cooldown_reduction = BASE_COOLDOWN_REDUCTION + dictionary_sum(stat_modifier_cooldown_reduction)
		duration = BASE_DURATION + dictionary_sum(stat_modifier_duration)
		area_size = BASE_AREA_SIZE + dictionary_sum(stat_modifier_area_size)

	func remove_stat_modifiers() -> void:
		stat_modifier_speed.clear()
		stat_modifier_light_omni_range.clear()
		stat_modifier_light_spot_range.clear()
		stat_modifier_light_energy.clear()
		stat_modifier_cooldown_reduction.clear()
		stat_modifier_duration.clear()
		stat_modifier_area_size.clear()
