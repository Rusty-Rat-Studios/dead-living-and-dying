extends KeyItemInventory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_resource = load("res://src/entity/items/key_item/pipe/pipe_world.tscn")
	display_name = "Pipe"
	description = ("This is the treasured pipe your grandfather requested.")
