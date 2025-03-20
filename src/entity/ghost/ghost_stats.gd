class_name GhostStats
extends Resource

enum Stats {
	SPEED,
	OPACITY,
	# state attacking
	ATTACK_DELAY,
	PRE_ATTACK_SPEED,
	WINDUP_SPEED,
	WINDUP_DURATION,
	# state possessing
	DECISION_TIME,
	ATTACK_CHANCE,
	DEPOSSESS_CHANCE,
	WAIT_CHANCE,
	# state stunned
	STUN_DURATION,
	# state waiting
	POSSESSING_CHANCE,
	ATTACKING_CHANCE,
	WAITING_CHANCE,
	MOVING_CHANCE
	}

const BASE_SPEED: float = 4.0
const BASE_OPACITY: float = 0.0
# state attacking
const BASE_ATTACK_DELAY: float = 0.3
#const BASE_PRE_ATTACK_SPEED: float = 6.0 # modifier + 2
#const BASE_ATTACK_SPEED: float = 8.5 # modifier + 2.5 on top of pre-attack_speed
#const BASE_WINDUP_SPEED: float = 4.0 # modififer -2
const BASE_WINDUP_DURATION: float = 1.0
# state possessing
const BASE_DECISION_TIME: float = 1.0
const BASE_ATTACK_CHANCE: float = 0.7
const BASE_DEPOSSESS_CHANCE: float = 0.15
const BASE_WAIT_CHANCE: float = 0.35
# state stunned
const BASE_STUN_DURATION: float = 3.0
# state waiting
#const BASE_WAITING_SPEED: float = 4.0 # modifier -2
const BASE_POSSESSING_CHANCE: float = 0.6
const BASE_ATTACKING_CHANCE: float = 0.2
const BASE_WAITING_CHANCE: float = 0.1
const BASE_MOVING_CHANCE: float = 0.1

var modifier_speed: Dictionary[String, float] = {}
var modifier_opacity: Dictionary[String, float] = {}
# state attacking
var modifier_attack_delay: Dictionary[String, float] = {}
var modifier_windup_duration: Dictionary[String, float] = {}
# state possessing
var modifier_decision_time: Dictionary[String, float] = {}
var modifier_attack_chance: Dictionary[String, float] = {}
var modifier_depossess_chance: Dictionary[String, float] = {}
var modifier_wait_chance: Dictionary[String, float] = {}
# state stunned
var modifier_stun_duration: Dictionary[String, float] = {}
# state waiting
var modifier_possessing_chance: Dictionary[String, float] = {}
var modifier_attacking_chance: Dictionary[String, float] = {}
var modifier_waiting_chance: Dictionary[String, float] = {}
var modifier_moving_chance: Dictionary[String, float] = {}

var speed: float = BASE_SPEED + dictionary_sum(modifier_speed)
var opacity: float = BASE_SPEED + dictionary_sum(modifier_speed)
# state attacking
var attack_delay: float = BASE_SPEED + dictionary_sum(modifier_speed)
var windup_duration: float = BASE_SPEED + dictionary_sum(modifier_speed)
# state possessing
var decision_time: float = BASE_SPEED + dictionary_sum(modifier_speed)
var attack_chance: float = BASE_SPEED + dictionary_sum(modifier_speed)
var depossess_chance: float = BASE_SPEED + dictionary_sum(modifier_speed)
var wait_chance: float = BASE_SPEED + dictionary_sum(modifier_speed)
# state stunned
var stun_duration: float = BASE_SPEED + dictionary_sum(modifier_speed)
# state waiting
var possessing_chance: float = BASE_SPEED + dictionary_sum(modifier_speed)
var attacking_chance: float = BASE_SPEED + dictionary_sum(modifier_speed)
var waiting_chance: float = BASE_SPEED + dictionary_sum(modifier_speed)
var moving_chance: float = BASE_SPEED + dictionary_sum(modifier_speed)

# map enum values to dicts
var _stat_map: Dictionary[Stats, Dictionary] = {
	Stats.SPEED: self.modifier_speed,
	Stats.OPACITY: self.modifier_opacity,
	# state attacking
	Stats.ATTACK_DELAY: self.modifier_attack_delay,
	Stats.WINDUP_DURATION: self.modifier_windup_duration,
	# state possessing
	Stats.DECISION_TIME: self.modifier_decision_time,
	Stats.ATTACK_CHANCE: self.modifier_attack_chance,
	Stats.DEPOSSESS_CHANCE: self.modifier_depossess_chance,
	Stats.WAIT_CHANCE: self.modifier_wait_chance,
	# state stunned
	Stats.STUN_DURATION: self.modifier_stun_duration,
	# state waiting
	Stats.POSSESSING_CHANCE: self.modifier_possessing_chance,
	Stats.ATTACKING_CHANCE: self.modifier_attacking_chance,
	Stats.WAITING_CHANCE: self.modifier_waiting_chance,
	Stats.MOVING_CHANCE: self.modifier_moving_chance
}


func dictionary_sum(stat_modifier: Dictionary[String, float]) -> float:
	var total_modifier: float = 0.0
	for i: String in stat_modifier:
		total_modifier += stat_modifier[i]
	return total_modifier


func stat_update_add(stat: Stats, stat_modifier: float, name: String, id: int = -1) -> void:
	if (id != -1):
		name = name + ":" + str(id)
	_stat_map.get(stat)[name] = stat_modifier
	update_stats()


func stat_update_remove(stat: Stats, name: String, id: int = -1) -> void:
	if (id != -1):
		name = name + ":" + str(id)
	_stat_map.get(stat).erase(name)
	update_stats()


func update_stats() -> void:
	speed = BASE_SPEED + dictionary_sum(modifier_speed)


func remove_stat_modifiers() -> void:
	modifier_speed.clear()
	update_stats()
