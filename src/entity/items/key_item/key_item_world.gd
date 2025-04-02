class_name KeyItemWorld
extends ItemWorld

const MOVE_TARGET_THRESHOLD: float = 0.1

var starting_room: Room
var target_room: Room
var movement_path: Array
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
		set_process(false)
		return

	# force target_pos onto y=1 plane to ensure ghost can "reach" targets
	# at different heights - i.e. player which is at a lower height
	move_target = Vector3(move_target.x, 1, move_target.z)
	var distance_to_target: float = global_position.distance_squared_to(move_target)
	
	if distance_to_target < MOVE_TARGET_THRESHOLD:
		var next_target: Room = movement_path.pop_front()
		if next_target == null:
			reparent(starting_room)
		else:
			reparent(target_room)
		set_target(next_target)
	else:
		var direction: Vector3 = (move_target - global_position).normalized()
		global_position += direction * move_speed * delta


func set_target(new_target: Room) -> void:
	# if target is self, move to center of room
	var parent_room: Room = get_parent()
	if new_target == null:
		move_target = starting_position
		return
	
	# get current room's available doors
	var doors: Array = parent_room.doors.values()
	# match each door's linked room against the target room
	for door: Door in doors:
		if door.linked_room == new_target:
			# after a match, set door as target
			move_target = door.global_position
			target_room = new_target
			return
	
	push_error("Key Item unable to find movement target")
	reparent(starting_room)
	global_position = starting_position
	move_target = starting_position


func reset() -> void:
	super()
	$Interactable.display_message("KEY ITEM")


func pick_up() -> void:
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
	visible = false
	set_process(false)


func _on_body_exited(_body: Node3D) -> void:
	# override function to display "key item" message again instead of hiding message
	$Interactable.display_message("KEY ITEM")
	$Interactable.enabled = false


func _on_key_item_dropped() -> void:
	# delete current room from movement list
	movement_path.pop_front()
	set_target(movement_path.pop_front())
	set_process(true)
