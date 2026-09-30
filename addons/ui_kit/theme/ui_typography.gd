@tool
class_name UITypography
extends Resource

## Font and text-size tokens for the whole kit.
##
## Sizes are named by role, not by number, so a project scales its text by
## editing one resource instead of hunting font size overrides. Like
## [UIPalette], changing a field re-builds the [UITheme] that holds it.

const DEFAULT_SIZE_HEADING := 32
const DEFAULT_SIZE_BODY := 16
const DEFAULT_SIZE_BUTTON := 18
const DEFAULT_SIZE_CAPTION := 12

@export_group("Fonts")
## Used for body text, button labels and captions.
@export var font_default: Font:
	set(value):
		font_default = value
		emit_changed()

## Used for the heading label variation. Falls back to [member font_default]
## when unset.
@export var font_heading: Font:
	set(value):
		font_heading = value
		emit_changed()

@export_group("Sizes")
@export_range(8, 128, 1) var size_heading: int = DEFAULT_SIZE_HEADING:
	set(value):
		size_heading = value
		emit_changed()

@export_range(8, 128, 1) var size_body: int = DEFAULT_SIZE_BODY:
	set(value):
		size_body = value
		emit_changed()

@export_range(8, 128, 1) var size_button: int = DEFAULT_SIZE_BUTTON:
	set(value):
		size_button = value
		emit_changed()

@export_range(8, 128, 1) var size_caption: int = DEFAULT_SIZE_CAPTION:
	set(value):
		size_caption = value
		emit_changed()


## [member font_heading] when set, otherwise [member font_default].
func heading_font() -> Font:
	return font_heading if font_heading != null else font_default
