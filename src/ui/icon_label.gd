extends RichTextLabel

const SCALE_FACTOR: float = 4

@export var single_icon: bool = false

var bbcode_size: int

@onready var bbcode: String = text


func _ready() -> void:
	if single_icon:
		bbcode_size = get_parent().size.x / SCALE_FACTOR
		get_parent().resized.connect(_on_parent_resized)
	else:
		bbcode_size = 15
	if text:
		text = UIDevice.resize_bbcode(text, bbcode_size)


func init(input_string: String) -> void:
	text = UIDevice.retrieve_icon(input_string)


func update(input_string: String, size: int = bbcode_size) -> void:
	# preserve text before and after BBCode icon
	var bbcode_start: int = text.find("[")
	var bbcode_end: int = text.rfind("]") + 1
	var text_pre_icon: String = text.substr(0, bbcode_start) # text before [img]
	var text_icon: String = text.substr(bbcode_start, bbcode_end)
	var text_post_icon: String = text.substr(bbcode_end) # text after [/img]
	
	# update BBCode
	text_icon = UIDevice.retrieve_icon_sized(input_string, size)
	# reconstruct existing string with updated BBCode image
	text = text_pre_icon + text_icon + text_post_icon

func _on_parent_resized() -> void:
	bbcode_size = get_parent().size.x / SCALE_FACTOR
	if text:
		# resize bbcode width value according to parent size
		text = UIDevice.resize_bbcode(text, bbcode_size)
