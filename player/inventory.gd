extends Node

var items: Array = []

func add_item(item: Node3D) -> void:
	#items.append(item)
	add_child(item)


func remove_item(item: Node3D) -> void:
	items.remove_at(items.find(item))
