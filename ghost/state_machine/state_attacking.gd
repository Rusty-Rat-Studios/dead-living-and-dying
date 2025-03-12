extends GhostState

const PRE_ATTACK_SPEED: float = 6.0
const ATTACK_SPEED: float = 8.5
# speed to move toward/away from player while winding up
const WINDUP_SPEED: float = 4.0

# how long the shake animation is displayed before attacking
const ATTACK_WINDUP: float = 1
# how much the shake animation moves in x or y dimensions
const ATTACK_SHAKE_MAGNITUDE: Vector2 = Vector2(1.5, 0.2)
const COLOR_RESTORATION_DURATION: float = 1
# red color to modulate ghost when initiating attack
const ATTACK_COLOR: Color = Color.FIREBRICK

var attack_range_collision_shape: CollisionShape3D
# used to pause moving towards player once they are in range of attack
var winding_up: bool = false
var base_color: Color
var color_tween: Tween

# used to animate sprite for attack
@onready var sprite_shaker: SpriteShaker = SpriteShaker.new()


func init(parent: CharacterBody3D, state_machine: StateMachine) -> void:
	# use init() instead of _ready() because we need access to parent variables
	# which are initialized after child variables (i.e. this state)
	super(parent, state_machine)
	
	attack_range_collision_shape = _parent.attack_range.get_node("CollisionShape3D")
	_parent.attack_range.body_entered.connect(_on_player_entered_attack_range)


func enter() -> void:
	base_color = _parent.sprite.modulate
	# ensure player is in a place/state to be attacked
	if not is_player_attackable():
		change_state(GhostStateMachine.States.POSSESSING)
		return
	
	_parent.speed = PRE_ATTACK_SPEED
	
	# reset at_target flag to handle case where previous state reached target
	# since this flag is used to detect when to exit ATTACKING state
	_parent.at_target = false
	
	# activate attack range collision for detecting if player in range of attack
	attack_range_collision_shape.set_deferred("disabled", false)
	winding_up = false
	
	# defer connecting this signal to ensure this function executes
	# AFTER this signal updates the player_in_room flag in ghost.gd
	SignalBus.player_exited_room.connect(_on_player_exited_room, CONNECT_DEFERRED)
	SignalBus.player_state_changed.connect(_on_player_state_changed)


func exit() -> void:
	super()
	_parent.speed = _parent.BASE_SPEED
	
	attack_range_collision_shape.set_deferred("disabled", true)
	winding_up = false
	# force sprite shaker to stop if mid-attack
	sprite_shaker.halt()
	# restore sprite color to normal
	if color_tween:
		color_tween.kill()
	_parent.sprite.modulate = base_color
	
	# reset target to self position
	_parent.set_target(_parent.global_position)
	
	if SignalBus.player_exited_room.is_connected(_on_player_exited_room):
		SignalBus.player_exited_room.disconnect(_on_player_exited_room)
	if SignalBus.player_state_changed.is_connected(_on_player_state_changed):
		SignalBus.player_state_changed.disconnect(_on_player_state_changed)


func process_state() -> void:
	var player_position: Vector3 = PlayerHandler.get_player().global_position
	if not winding_up:
		_parent.set_target(player_position)
	else:
		# set target position to edge of attack range
		# use xz coordinates to avoid floating up into the air
		var position_xz: Vector3 = Vector3(_parent.global_position.x, 0, _parent.global_position.z)
		var direction: Vector3 = (player_position - position_xz).normalized()
		_parent.set_target(PlayerHandler.get_player().global_position - direction * attack_range_collision_shape.shape.radius)
	
	if (_parent.global_position.distance_squared_to(PlayerHandler.get_player().global_position) < 0.5
		and PlayerHandler.get_player_state() != PlayerStateMachine.States.DEAD):
		# only revert to waiting after "hit" if player is in DYING state
		change_state(GhostStateMachine.States.WAITING)


func is_player_attackable() -> bool:
	# check if player is in room and DYING or DEAD when entering attack state
	if (_parent.player_in_room
		and (PlayerHandler.get_player_state() == PlayerStateMachine.States.DEAD
		or PlayerHandler.get_player_state() == PlayerStateMachine.States.DYING)):
		return true
	return false


func attack() -> void:
	# checked in process_state() to pause movement
	winding_up = true
	_parent.speed = WINDUP_SPEED
	# disable collision area to avoid re-triggering attack if player moved out of area
	attack_range_collision_shape.set_deferred("disabled", true)
	
	color_tween = create_tween()
	color_tween.tween_property(_parent.sprite, "modulate", ATTACK_COLOR * base_color, ATTACK_WINDUP)
	await sprite_shaker.animate(_parent.sprite, ATTACK_WINDUP, ATTACK_SHAKE_MAGNITUDE)
	
	winding_up = false
	_parent.speed = ATTACK_SPEED
	_parent.sprite.animation = "active"


func _on_player_exited_room(room: Node3D) -> void:
	if room == _parent.current_room and not _parent.player_in_room:
		change_state(GhostStateMachine.States.WAITING)


func _on_player_state_changed(state: PlayerStateMachine.States) -> void:
	if (state != PlayerStateMachine.States.DYING):
		change_state(GhostStateMachine.States.WAITING)


func _on_player_entered_attack_range(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		# set to halt ghost following player
		_parent.at_target = true
		attack()
