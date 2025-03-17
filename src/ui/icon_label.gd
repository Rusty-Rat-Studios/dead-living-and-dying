extends RichTextLabel

const SCALE_FACTOR: float = 4

@onready var bbcode_size: int = get_parent().size.x / SCALE_FACTOR
@onready var bbcode: String = text


func _ready() -> void:
	print("bbcode size: ", bbcode_size)
	get_parent().resized.connect(_on_parent_resized)
	if text:
		text = UIDevice.resize_bbcode(text, bbcode_size)


func init(input_string: String) -> void:
	text = UIDevice.retrieve_icon(input_string)


func _on_parent_resized() -> void:
	bbcode_size = get_parent().size.x / SCALE_FACTOR
	if text:
		# resize bbcode width value according to parent size
		text = UIDevice.resize_bbcode(text, bbcode_size)
