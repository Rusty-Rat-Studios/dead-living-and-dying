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
