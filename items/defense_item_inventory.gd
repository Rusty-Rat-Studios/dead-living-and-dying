class_name DefenseItemInventory
extends ItemInventory


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(_event: InputEvent) -> void:
	if PlayerHandler.get_player_state() == "Dead":
		return


func use() -> void:
	push_error("AbstractMethodError: DefenseItemInventory use() function called from base DefenseItemInventory class")
