extends RichTextLabel

var bbcode_size: int = UIDevice.DEFAULT_BBCODE_SIZE


func _ready() -> void:
	bbcode_size = UIDevice.DEFAULT_BBCODE_SIZE
	if text:
		text = UIDevice.resize_bbcode(text, bbcode_size)


func init(input_string: String) -> void:
	text = UIDevice.retrieve_icon_sized(input_string)


# takes in a text string with an embedded BBCode [img] tag
# and replaces it with the current device icon, optionally resized
func update(input_string: String, updated_size: int = bbcode_size) -> void:
	# preserve text before and after BBCode icon
	var bbcode_start: int = text.find("[")
	var bbcode_end: int = text.rfind("]") + 1
	var text_pre_icon: String = text.substr(0, bbcode_start) # text before [img]
	var text_icon: String = text.substr(bbcode_start, bbcode_end)
	var text_post_icon: String = text.substr(bbcode_end) # text after [/img]
	
	# update BBCode
	text_icon = UIDevice.retrieve_icon_sized(input_string, updated_size)
	# reconstruct existing string with updated BBCode image
	text = text_pre_icon + text_icon + text_post_icon
