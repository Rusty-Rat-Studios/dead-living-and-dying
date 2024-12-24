class_name Rooms extends Resource

static func get_basic_room_information() -> RoomInformation:
	var basic_room: RoomInformation = RoomInformation.new()
	basic_room.resource = preload("res://map/basic_room/basic_room.tscn")
	basic_room.room_shape = [
		Vector2(0, 0)
		]
	basic_room.possible_door_locations = [
		Vector2(1, 0),
		Vector2(0, 1),
		Vector2(-1, 0),
		Vector2(0, -1)
	]
	return basic_room
