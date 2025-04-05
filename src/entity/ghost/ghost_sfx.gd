extends AudioStreamMultiple

const MAX_DB_QUIET: float = -12 # used in state LIVING
const MAX_DB_NORMAL: float = -4 # used in state DYING

const DEAD_STING: AudioStream = preload("res://src/sound/ghost/dead_sting.mp3")


const DELAY_TIME_MIN: float = 1.5
const DELAY_TIME_MAX: float = 2.5

var player_dead: bool = false


func _ready() -> void:
	super()
	
	# initialize max_db to state living condition
	max_db = MAX_DB_QUIET
	# reduce volume if living; increase if dying; disable if dead
	SignalBus.player_state_changed.connect(_on_player_state_changed)


func play_sound() -> void:
	if playing: 
		return
	if player_dead:
		if stream != DEAD_STING:
			stream = DEAD_STING
		AudioManager.play_modulated(self)
	else:
		play_random_sound()


func _on_player_state_changed(state: PlayerStateMachine.States) -> void:
	match state:
		PlayerStateMachine.States.LIVING:
			player_dead = false
			max_db = MAX_DB_QUIET # quieter when player is living
			# halt any sound effects
			stop()
		PlayerStateMachine.States.DYING:
			max_db = MAX_DB_NORMAL # louder when player is dying
		PlayerStateMachine.States.DEAD:
			player_dead = true
			# change audio stream to scary noises
			stream = DEAD_STING
