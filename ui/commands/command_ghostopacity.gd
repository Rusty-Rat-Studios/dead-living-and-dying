extends Command

@onready var ghost_resource: Resource = preload("res://ghost/ghost.tscn")


func help() -> String:
	return "Usage: ghostopacity [opacity] - Sets the ghost opacity to opacity or returns the current opacity"


func execute(args: PackedStringArray) -> String:
	if args.size() > 1:
		return help()
		
	var ghost: Ghost = ghost_resource.instantiate()
	var ghost_mesh_instance: MeshInstance3D = ghost.get_node("MeshInstance3D")
	
	if args.size() == 0:
		var opacity: float = ghost_mesh_instance.mesh.material.albedo_color.a
		ghost.queue_free()
		return "The current ghost opacity is %s" % [str(opacity)]
	
	if not args[0].is_valid_float():
		ghost.queue_free()
		return "Error: argument opacity must be a valid float"
		
	var opacity: float = args[0].to_float()
	if opacity < 0 or opacity > 1:
		ghost.queue_free()
		return "Error: argument opacity must be 0-1.0 (inclusive)"
	
	ghost_mesh_instance.mesh.material.albedo_color.a = opacity
	ghost.queue_free()
	return "Ghost opacity updated"
