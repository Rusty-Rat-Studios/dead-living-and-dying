class_name PlayerStats
extends Resource

#used when calling stat_update_* methods
enum Stats {
	SPEED,
	LIGHT_OMNI_RANGE,
	LIGHT_SPOT_RANGE,
	LIGHT_ENERGY,
	COOLDOWN_REDUCTION,
	DURATION,
	AREA_SIZE
}

# player base stats
# additive
const BASE_SPEED: float = 4.5

# multipicative
const BASE_COOLDOWN_REDUCTION: float = 1.0
const BASE_DURATION: float = 1.0
const BASE_AREA_SIZE: float = 1.0

# base values used for light range and strength
# additive
const BASE_LIGHT_OMNI_RANGE: float = 8.0
const BASE_LIGHT_SPOT_RANGE: float = 14.0
const BASE_LIGHT_ENERGY: float = 1.0

var stat_modifier_speed: Dictionary[String, float] = {}
var stat_modifier_light_omni_range: Dictionary[String, float] = {}
var stat_modifier_light_spot_range: Dictionary[String, float] = {}
var stat_modifier_light_energy: Dictionary[String, float] = {}
var stat_modifier_cooldown_reduction: Dictionary[String, float] = {}
var stat_modifier_duration: Dictionary[String, float] = {}
var stat_modifier_area_size: Dictionary[String, float] = {}

var speed: float
var light_omni_range: float
var light_spot_range: float
var light_energy: float
var cooldown_reduction: float
var duration: float
var area_size: float

# map enum values to dicts
var _stat_map: Dictionary[Stats, Dictionary] = {
	Stats.SPEED: self.stat_modifier_speed,
	Stats.LIGHT_OMNI_RANGE: self.stat_modifier_light_omni_range,
	Stats.LIGHT_SPOT_RANGE: self.stat_modifier_light_spot_range,
	Stats.LIGHT_ENERGY: self.stat_modifier_light_energy,
	Stats.COOLDOWN_REDUCTION: self.stat_modifier_cooldown_reduction,
	Stats.DURATION: self.stat_modifier_duration,
	Stats.AREA_SIZE: self.stat_modifier_area_size
}


func _ready() -> void:
	speed = BASE_SPEED + dictionary_sum(stat_modifier_speed)
	light_omni_range = BASE_LIGHT_OMNI_RANGE + dictionary_sum(stat_modifier_light_omni_range)
	light_spot_range = BASE_LIGHT_SPOT_RANGE + dictionary_sum(stat_modifier_light_spot_range)
	light_energy = BASE_LIGHT_ENERGY + dictionary_sum(stat_modifier_light_energy)
	cooldown_reduction = BASE_COOLDOWN_REDUCTION + dictionary_sum(stat_modifier_cooldown_reduction)
	duration = BASE_DURATION + dictionary_sum(stat_modifier_duration)
	area_size = BASE_AREA_SIZE + dictionary_sum(stat_modifier_area_size)


func dictionary_sum(stat_modifier: Dictionary[String, float]) -> float:
	var total_modifier: float = 0.0
	for i: String in stat_modifier:
		total_modifier += stat_modifier[i]
	return total_modifier


func stat_update_add( stat: Stats, stat_modifier: float, name: String, id: int = -1) -> void:
	if (id != -1):
		name = name + ":" + str(id)
	_stat_map.get(stat)[name] = stat_modifier
	update_stats()


func stat_update_remove( stat: Stats, name: String, id: int = -1) -> void:
	if (id != -1):
		name = name + ":" + str(id)
	_stat_map.get(stat).erase(name)
	update_stats()


func update_stats() -> void:
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
	update_stats()
