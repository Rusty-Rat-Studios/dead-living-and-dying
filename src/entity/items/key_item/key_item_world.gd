class_name KeyItemWorld
extends ItemWorld

var starting_room: Room
var movement_path: Array
var move_target: Vector3
var move_speed: float = 2


func _ready() -> void:
	starting_room = get_parent()
	KeyItemHandler.register_key_item(self)
	
	# initialize game.gd value to track key starting position when it is
	# re-created when dropped by the player
	if get_node("/root/Game").key_item_starting_position == Vector3.ZERO:
		get_node("/root/Game").key_item_starting_position = starting_position
	else:
		starting_position = get_node("/root/Game").key_item_starting_position
	
	SignalBus.key_item_dropped.connect(_on_key_item_dropped)
	
	# reactivated when key item is dropped
	set_process(false)
	super()


func _process(delta: float) -> void:
	# TODO:
	# slowly moves the key item towards its original position
	# activated/deactivated when the key item is picked up or dropped
	var direction: Vector3 = move_target - global_position
	# ensure ghost only moves in xz-plane and does not follow objects up into the air
	direction.y = 0
	# force target_pos onto y=1 plane to ensure ghost can "reach" targets
	# at different heights - i.e. player which is at a lower height
	move_target = Vector3(move_target.x, 1, move_target.z)
	var distance_to_target: float = global_position.distance_squared_to(move_target)
	
	if distance_to_target < move_speed * delta:
		var next_target: Room = movement_path.pop_front()
		if next_target != null:
			# set target to next room
			set_target(next_target)
		else:
			set_process(false)
	else:
		direction = direction.normalized()
		global_position.lerp(direction, move_speed * delta)


func set_target(target_room: Room) -> void:
	# if target is self, move to center of room
	var parent_room: Room = get_parent()
	if target_room == parent_room or target_room == null:
		move_target = parent_room.global_position
		return
	
	# get current room's available doors
	var doors: Array[Door] = parent_room.doors.values()
	# match each door's linked room against the target room
	for door: Door in doors:
		if door.linked_room == target_room:
			# after a match, set door as target
			move_target = door.global_position
			return
	
	push_error("Key Item unable to find movement target")
	move_target = self.global_position


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
	#queue_free()
	visible = false
	set_process(false)


func _on_body_exited(_body: Node3D) -> void:
	# override function to display "key item" message again instead of hiding message
	$Interactable.display_message("KEY ITEM")
	$Interactable.enabled = false


func _on_key_item_dropped() -> void:
	set_process(true)
	set_target(movement_path.pop_front())
