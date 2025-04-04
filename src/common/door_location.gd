class_name DoorLocation
extends Resource

# Stores a door location with a x,y grid location and a direction.

enum Direction { NORTH, EAST, SOUTH, WEST }

@export var location: Vector2
@export var direction: Direction
@export var required: bool = false


func _init(_location:Vector2=Vector2(0,0), _direction:Direction=Direction.NORTH, _required:bool=false) -> void:
	location = _location
	direction = _direction
	required = _required


func translate(new_origin: Vector2) -> DoorLocation:
	return DoorLocation.new(self.location + new_origin, self.direction, self.required)


func hash() -> PackedByteArray:
	# Create a string of the form "DoorLocation|(x, y)|d"
	var data_str: String = "DoorLocation|%s|%s" % [str(location), str(direction)]
	# Compute the hash
	return data_str.sha256_buffer()


func equals(other: DoorLocation) -> bool:
	return self.hash() == other.hash()


# Returns the door location needed for the door connecting to this door.
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


func string() -> String:
	return "%s $%s" % [location, Direction.keys()[direction]]
