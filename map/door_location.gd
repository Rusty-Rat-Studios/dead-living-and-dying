extends Resource
class_name DoorLocation

enum Direction {
	NORTH = 0,
	EAST = 1,
	SOUTH = 2,
	WEST = 3
}

@export var location: Vector2
@export var direction: Direction


func _init(_location:Vector2=Vector2(0,0), _direction:Direction=Direction.NORTH) -> void:
	location = _location
	direction = _direction


func translate(new_origin: Vector2) -> DoorLocation:
	return DoorLocation.new(self.location + new_origin, self.direction)


func hash() -> PackedByteArray:
	# Create a string of the form "DoorLocation|(x, y)|d"
	var data_str: String = "DoorLocation|%s|%s" % [str(location), str(direction)]
	# Compute the hash
	return data_str.sha256_buffer()


func equals(other: DoorLocation) -> bool:
	return self.hash() == other.hash()


# Takes the current door location and returns the door location needed for the connecting door
func invert() -> DoorLocation:
	if direction == Direction.NORTH:
		return DoorLocation.new(Vector2(location.x, location.y - 1), Direction.SOUTH)
	if direction == Direction.EAST:
		return DoorLocation.new(Vector2(location.x + 1, location.y), Direction.WEST)
	if direction == Direction.SOUTH:
		return DoorLocation.new(Vector2(location.x, location.y + 1), Direction.NORTH)
	if direction == Direction.WEST:
		return DoorLocation.new(Vector2(location.x - 1, location.y), Direction.EAST)
	push_error("DoorLocation.invert lost its sense of direction")
	return null
