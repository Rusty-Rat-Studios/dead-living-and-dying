extends Node


func _ready() -> void:
	var map: HashMap = HashMap.new()
	
	print(map.keys())
	print(map.values())
	print(map.size())
	
	var a: DoorLocation = DoorLocation.new(Vector2(0, 0), DoorLocation.Direction.NORTH)
	var b: DoorLocation = DoorLocation.new(Vector2(1, 1), DoorLocation.Direction.SOUTH)
	var c: DoorLocation = DoorLocation.new(Vector2(1, 0), DoorLocation.Direction.EAST)
	
	map.add(a, a)
	map.add(b, b)
	map.add(a, c)
	
	print(map.keys())
	print(map.values())
	print(map.size())
	
	map.clear()
	
	print(map.keys())
	print(map.values())
	print(map.size())
