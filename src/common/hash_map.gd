class_name HashMap
extends Resource

# HashMap is a simple key value dictionary where the key is always a hash.
# If the key being hashed is hashable (contains a hash() function) then use the
# add, remove, retrieve, and contains_key functions. If the key is not hashable
# then hash it manually and use the functions add_with_hash, remove_with_hash, 
# retrieve_with_hash, and contains_hash. Other than the key being a hash, the 
# dictionary is like any other (except maybe a little faster).

var _hash_map: Dictionary[PackedByteArray, Variant] = {}


func add(key: Variant, value: Variant) -> bool:
	if not _is_hashable(key):
		push_error("Error: key is not hashable")
		return false
	var hash: PackedByteArray = key.hash()
	_hash_map[hash] = value
	return true


func add_with_hash(hash: PackedByteArray, value: Variant) -> bool:
	_hash_map[hash] = value
	return true


func remove(key: Variant) -> bool:
	if not _is_hashable(key):
		push_error("Error: key is not hashable")
		return false
	var hash: PackedByteArray = key.hash()
	return _hash_map.erase(hash)


func remove_with_hash(hash: PackedByteArray) -> bool:
	return _hash_map.erase(hash)


func retrieve(key: Variant) -> Variant:
	if not _is_hashable(key):
		push_error("Error: key is not hashable")
		return null
	var hash: PackedByteArray = key.hash()
	return _hash_map.get(hash)


func retrieve_with_hash(hash: PackedByteArray) -> Variant:
	return _hash_map.get(hash)


func clear() -> void:
	_hash_map.clear()


func contains_key(key: Variant) -> bool:
	if not _is_hashable(key):
		push_error("Error: key is not hashable")
		return false
	var hash: PackedByteArray = key.hash()
	return _hash_map.has(hash)


func contains_hash(hash: PackedByteArray) -> bool:
	return _hash_map.has(hash)


# Returns a list of the keys (hashed)
func keys() -> Array:
	return _hash_map.keys()


func values() -> Array:
	return _hash_map.values()


func size() -> int:
	return _hash_map.size()


func dict() -> Dictionary[PackedByteArray, Variant]:
	return _hash_map


func _is_hashable(item: Variant) -> bool:
	return item.has_method("hash")
