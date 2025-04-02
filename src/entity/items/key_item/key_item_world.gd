class_name KeyItemWorld
extends ItemWorld

# minimum distance between position and target to be considered "at target"
const MOVE_TARGET_THRESHOLD: float = 0.1

var starting_room: Room
# updated as the key item moves through room; used to reparent key item
# to the appropriate room as it reaches each door
var target_room: Room
# the array of rooms fetched with the get_shortest_path algorithm
# populated by room.gd when it reparents the key item to itself
var movement_path: Array
# the 3D target within a room the key item is travelling towards (e.g. next door)
var move_target: Vector3
var move_speed: float = 0.8


func _ready() -> void:
	starting_room = get_parent()
	KeyItemHandler.register_key_item(self)
	
	# initialize game.gd value to track key starting position when it is
	# re-created when dropped by the player
	if get_node("/root/Game").key_item_starting_position == Vector3.ZERO:
		get_node("/root/Game").key_item_starting_position = starting_position
	else:
		starting_position = get_node("/root/Game").key_item_starting_position
	
	SignalBus.key_item_dropped.connect(_on_key_item_dropped, CONNECT_DEFERRED)
	
	# reactivated when key item is dropped
	set_process(false)
	super()


func _process(delta: float) -> void:
	# slowly moves the key item towards its original position
	# activated/deactivated when the key item is picked up or dropped
	if global_position.distance_squared_to(starting_position) < MOVE_TARGET_THRESHOLD:
		# check if key item has reached its starting position -> success condition
		set_process(false)
		return

	# force target_pos onto y=1 plane to ensure ghost can "reach" targets
	# at different heights - i.e. player which is at a lower height
	move_target = Vector3(move_target.x, 1, move_target.z)
	var distance_to_target: float = global_position.distance_squared_to(move_target)
	
	if distance_to_target < MOVE_TARGET_THRESHOLD:
		# key item has reached its target -> set a new target
		var next_target: Room = movement_path.pop_front()
		if next_target == null:
			# list is empty means we are at the starting room
			reparent(starting_room)
		else:
			reparent(target_room)
		set_target(next_target)
	else:
		# have not reached target, move towards it
		var direction: Vector3 = (move_target - global_position).normalized()
		global_position += direction * move_speed * delta


func set_target(new_target: Room) -> void:
	# null target means we have reached the end of the movement target rooms
	# i.e. we are at the starting room -> move to starting_position within room
	if new_target == null:
		move_target = starting_position
		return
	
	# get current room's available doors
	var current_room: Room = get_parent()
	var doors: Array = current_room.doors.values()
	# match each door's linked room against the target room
	for door: Door in doors:
		if door.linked_room == new_target:
			# after a match, set door as target
			move_target = door.global_position
			# key item is reparented to target room when reached
			# update target room to the new target
			target_room = new_target
			return
	
	# something went wrong, default to starting room and position
	push_error("Key Item unable to find movement target")
	reparent(starting_room)
	global_position = starting_position
	move_target = starting_position


func reset() -> void:
	super()
	$Interactable.display_message("KEY ITEM")


func pick_up() -> void:
	# overloaded version of ItemWorld.pick_up() that does not queue_free() at the end
	if inventory_resource == null:
		#gdlint:ignore=max-line-length
		push_error("AbstractVariableError: ItemWorld base class function pick_up() called without initializing variable 'inventory_resource'")
		return
	
	# emits a signal caught by the player who then adds a child
	# of the inventory resource version to its $Inventory node
	var item_inventory: ItemInventory = inventory_resource.instantiate()
	var player: Node = PlayerHandler.get_player()
	item_inventory.texture = $Sprite3D.texture
	
	SignalBus.item_picked_up.emit(item_inventory, false)
	# set invisible instead of queue_free() to preserve starting position data
	visible = false
	set_process(false)


func _on_body_exited(_body: Node3D) -> void:
	# override function to display "key item" message again instead of hiding message
	$Interactable.display_message("KEY ITEM")
	$Interactable.enabled = false


func _on_key_item_dropped() -> void:
	# movement list is populated with current room at the 
	# start of the list which must be removed
	movement_path.pop_front()
	
	# begin moving towards the first target room in the movement path
	set_target(movement_path.pop_front())
	set_process(true)
