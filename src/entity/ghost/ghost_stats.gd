class_name GhostStats
extends Resource

enum Stats {
	SPEED,
	OPACITY,
	# state attacking
	ATTACK_DELAY, # time to wait before attacking when player enters room
	WINDUP_DURATION,
	# state possessing
	DECISION_TIME,
	POSSESSION_ATTACK_CHANCE,
	DEPOSSESS_CHANCE,
	POSSESSION_WAIT_CHANCE,
	# state stunned
	STUN_DURATION,
	# state waiting
	STATE_POSSESSING_CHANCE,
	STATE_ATTACKING_CHANCE,
	STATE_WAITING_CHANCE,
	STATE_MOVING_CHANCE
	}

const BASE_SPEED: float = 4.0
const BASE_OPACITY: float = 0.0
# state attacking
const BASE_ATTACK_DELAY: float = 0.3
const BASE_WINDUP_DURATION: float = 1.0
# state possessing
const BASE_DECISION_TIME: float = 1.0
const BASE_POSSESSION_ATTACK_CHANCE: float = 0.7
const BASE_DEPOSSESS_CHANCE: float = 0.1
const BASE_POSSESSION_WAIT_CHANCE: float = 0.2
# state stunned
const BASE_STUN_DURATION: float = 3.0
# state waiting
const BASE_STATE_POSSESSING_CHANCE: float = 0.6
const BASE_STATE_ATTACKING_CHANCE: float = 0.2
const BASE_STATE_WAITING_CHANCE: float = 0.1
const BASE_STATE_MOVING_CHANCE: float = 0.1

var modifier_speed: Dictionary[String, float] = {}
var modifier_opacity: Dictionary[String, float] = {}
# state attacking
var modifier_attack_delay: Dictionary[String, float] = {}
var modifier_windup_duration: Dictionary[String, float] = {}
# state possessing
var modifier_decision_time: Dictionary[String, float] = {}
var modifier_possession_attack_chance: Dictionary[String, float] = {}
var modifier_depossess_chance: Dictionary[String, float] = {}
var modifier_possession_wait_chance: Dictionary[String, float] = {}
# state stunned
var modifier_stun_duration: Dictionary[String, float] = {}
# state waiting
var modifier_state_possessing_chance: Dictionary[String, float] = {}
var modifier_state_attacking_chance: Dictionary[String, float] = {}
var modifier_state_waiting_chance: Dictionary[String, float] = {}
var modifier_state_moving_chance: Dictionary[String, float] = {}

var speed: float
var opacity: float
# state attacking
var attack_delay: float
var windup_duration: float
# state possessing
var decision_time: float
var possession_attack_chance: float
var depossess_chance: float
var possession_wait_chance: float
# state stunned
var stun_duration: float
# state waiting
var state_possessing_chance: float
var state_attacking_chance: float
var state_waiting_chance: float
var state_moving_chance: float

# map enum values to dicts
var _stat_map: Dictionary[Stats, Dictionary] = {
	Stats.SPEED: self.modifier_speed,
	Stats.OPACITY: self.modifier_opacity,
	# state attacking
	Stats.ATTACK_DELAY: self.modifier_attack_delay,
	Stats.WINDUP_DURATION: self.modifier_windup_duration,
	# state possessing
	Stats.DECISION_TIME: self.modifier_decision_time,
	Stats.POSSESSION_ATTACK_CHANCE: self.modifier_possession_attack_chance,
	Stats.DEPOSSESS_CHANCE: self.modifier_depossess_chance,
	Stats.POSSESSION_WAIT_CHANCE: self.modifier_possession_wait_chance,
	# state stunned
	Stats.STUN_DURATION: self.modifier_stun_duration,
	# state waiting
	Stats.STATE_POSSESSING_CHANCE: self.modifier_state_possessing_chance,
	Stats.STATE_ATTACKING_CHANCE: self.modifier_state_attacking_chance,
	Stats.STATE_WAITING_CHANCE: self.modifier_state_waiting_chance,
	Stats.STATE_MOVING_CHANCE: self.modifier_state_moving_chance
}


func _ready() -> void:
	speed = BASE_SPEED + dictionary_sum(modifier_speed)
	opacity = BASE_OPACITY + dictionary_sum(modifier_opacity)
	# state attacking
	attack_delay = BASE_ATTACK_DELAY + dictionary_sum(modifier_attack_delay)
	windup_duration = BASE_WINDUP_DURATION + dictionary_sum(modifier_windup_duration)
	# state possessing
	decision_time = BASE_DECISION_TIME + dictionary_sum(modifier_decision_time)
	possession_attack_chance = BASE_POSSESSION_ATTACK_CHANCE + dictionary_sum(modifier_possession_attack_chance)
	depossess_chance = BASE_DEPOSSESS_CHANCE + dictionary_sum(modifier_depossess_chance)
	possession_wait_chance = BASE_POSSESSION_WAIT_CHANCE + dictionary_sum(modifier_possession_wait_chance)
	# state stunned
	stun_duration = BASE_STUN_DURATION + dictionary_sum(modifier_stun_duration)
	# state waiting
	state_possessing_chance = BASE_STATE_POSSESSING_CHANCE + dictionary_sum(modifier_state_possessing_chance)
	state_attacking_chance = BASE_STATE_ATTACKING_CHANCE + dictionary_sum(modifier_state_attacking_chance)
	state_waiting_chance = BASE_STATE_WAITING_CHANCE + dictionary_sum(modifier_state_waiting_chance)
	state_moving_chance = BASE_STATE_MOVING_CHANCE + dictionary_sum(modifier_state_moving_chance)


func dictionary_sum(stat_modifier: Dictionary[String, float]) -> float:
	var total_modifier: float = 0.0
	for i: String in stat_modifier:
		total_modifier += stat_modifier[i]
	return total_modifier


func add_modifier(stat: Stats, modifier: float, name: String, id: int = -1) -> void:
	if (id != -1):
		name = name + ":" + str(id)
	_stat_map.get(stat)[name] = modifier
	update()


func remove_modifier(stat: Stats, name: String, id: int = -1) -> void:
	if (id != -1):
		name = name + ":" + str(id)
	_stat_map.get(stat).erase(name)
	update()


func update() -> void:
	speed = BASE_SPEED + dictionary_sum(modifier_speed)
	opacity = BASE_OPACITY + dictionary_sum(modifier_opacity)
	# state attacking
	attack_delay = BASE_ATTACK_DELAY + dictionary_sum(modifier_attack_delay)
	windup_duration = BASE_WINDUP_DURATION + dictionary_sum(modifier_windup_duration)
	# state possessing
	decision_time = BASE_DECISION_TIME + dictionary_sum(modifier_decision_time)
	possession_attack_chance = BASE_POSSESSION_ATTACK_CHANCE + dictionary_sum(modifier_possession_attack_chance)
	depossess_chance = BASE_DEPOSSESS_CHANCE + dictionary_sum(modifier_depossess_chance)
	possession_wait_chance = BASE_POSSESSION_WAIT_CHANCE + dictionary_sum(modifier_possession_wait_chance)
	# state stunned
	stun_duration = BASE_STUN_DURATION + dictionary_sum(modifier_stun_duration)
	# state waiting
	state_possessing_chance = BASE_STATE_POSSESSING_CHANCE + dictionary_sum(modifier_state_possessing_chance)
	state_attacking_chance = BASE_STATE_ATTACKING_CHANCE + dictionary_sum(modifier_state_attacking_chance)
	state_waiting_chance = BASE_STATE_WAITING_CHANCE + dictionary_sum(modifier_state_waiting_chance)
	state_moving_chance = BASE_STATE_MOVING_CHANCE + dictionary_sum(modifier_state_moving_chance)


func remove_stat_modifiers() -> void:
	modifier_speed.clear()
	modifier_opacity.clear()
	# state attacking
	modifier_attack_delay.clear()
	modifier_windup_duration.clear()
	# state possessing
	modifier_decision_time.clear()
	modifier_possession_attack_chance.clear()
	modifier_depossess_chance.clear()
	modifier_possession_wait_chance.clear()
	# state stunned
	modifier_stun_duration.clear()
	# state waiting
	modifier_state_possessing_chance.clear()
	modifier_state_attacking_chance.clear()
	modifier_state_waiting_chance.clear()
	modifier_state_moving_chance.clear()
	
	update()
