class_name GeneratorSettings
extends Resource

@export var spread: float = 0 # Multiplier to pick further doors
@export var min_rooms: int = 25 # Minimum number of rooms to have in world_grid
@export var room_table: EntityTable = null
@export var min_special_room_spread: int = 4

@export_category("Spawner Entity Tables")
@export var enemy_entity_table: EntityTable = null
@export var item_entity_table: EntityTable = null
@export var key_item_entity_table: EntityTable = null
@export var boss_entity_table: EntityTable = null
