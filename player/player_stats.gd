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
	var speed: float = BASE_SPEED
	var light_omni_range: float = BASE_LIGHT_OMNI_RANGE
	var light_spot_range: float = BASE_LIGHT_SPOT_RANGE
	var light_energy: float = BASE_LIGHT_ENERGY
	var cooldown_reduction: float = BASE_COOLDOWN_REDUCTION
	var duration: float = BASE_DURATION
	var area_size: float = BASE_AREA_SIZE
