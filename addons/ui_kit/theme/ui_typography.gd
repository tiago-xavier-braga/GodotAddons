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

## Fonts to fall through to for characters the fonts above do not contain.
##
## This is where coverage a game needs and the kit cannot ship goes: Noto Sans
## CJK is tens of megabytes, so bundling it for every consumer is not an
## option, and on a web export there is no system font to fall back on either —
## a missing glyph is a visible box, not a substitution. Adding a font here
## applies it to every text item in the theme at once, including a project's
## own replacement fonts.
@export var font_fallbacks: Array[Font] = []:
	set(value):
		font_fallbacks = value
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


## [member font_default] with [member font_fallbacks] applied.
func default_font() -> Font:
	return _with_fallbacks(font_default)


## [member font_heading] when set, otherwise [member font_default] — with
## [member font_fallbacks] applied either way.
func heading_font() -> Font:
	return _with_fallbacks(font_heading if font_heading != null else font_default)


## Wraps [param font] so it falls through to [member font_fallbacks].
##
## A [FontVariation] around the font, rather than writing to the font's own
## [member Font.fallbacks]: the font may be a resource the project shares with
## something else, or one of this addon's, and neither should be mutated from
## here.
func _with_fallbacks(font: Font) -> Font:
	if font == null or font_fallbacks.is_empty():
		return font
	var variation := FontVariation.new()
	variation.base_font = font
	variation.fallbacks = font_fallbacks
	return variation
