extends KeyItemInventory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_resource = load("res://src/entity/items/key_item/journal/journal_world.tscn")
	display_name = "Journal"
	description = ("An old jornal your grandfather has scribbled in for decades.")
