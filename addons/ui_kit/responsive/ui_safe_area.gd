@tool
class_name UISafeArea
extends MarginContainer

## Keeps its content clear of notches, rounded corners and gesture bars.
##
## [method DisplayServer.get_display_safe_area] reports the part of the screen
## that is actually usable, and on a phone that is not the whole of it: a
## camera cut-out eats the top, a home-gesture bar the bottom, and in landscape
## both move to one side. Godot does not apply it for you — a full-rect
## [Control] happily draws underneath all three.
##
## Used as the outer container in each of this addon's templates. Margins never
## go below [member minimum_margin], so on a desktop, where the safe area is
## the whole screen, this is simply a [MarginContainer] with sensible padding.

## Padding applied regardless of the safe area, so content never touches the
## edge even on a screen with nothing in the way.
@export_range(0, 128, 1) var minimum_margin: int = 32:
	set(value):
		minimum_margin = value
		refresh()


func _ready() -> void:
	# An orientation change on a phone moves the cut-out from the top to a
	# side, and arrives here as a resize.
	get_window().size_changed.connect(refresh)
	refresh()


## Re-reads the safe area and reapplies the margins. Called for you on resize.
func refresh() -> void:
	if not is_inside_tree():
		return

	var insets := screen_insets(DisplayServer.get_display_safe_area(), _screen_size())
	var scale := _canvas_units_per_screen_pixel()

	add_theme_constant_override(&"margin_left", _margin(insets.x * scale.x))
	add_theme_constant_override(&"margin_top", _margin(insets.y * scale.y))
	add_theme_constant_override(&"margin_right", _margin(insets.z * scale.x))
	add_theme_constant_override(&"margin_bottom", _margin(insets.w * scale.y))


## How many screen pixels are unusable on each side, as
## [code](left, top, right, bottom)[/code].
##
## Static and pure so the awkward part — a safe *rect* has to become four
## *insets*, and an empty or oversized rect has to mean "no insets" rather than
## a negative margin — can be checked against made-up screens.
static func screen_insets(safe_area: Rect2i, screen_size: Vector2i) -> Vector4:
	if safe_area.size.x <= 0 or safe_area.size.y <= 0:
		return Vector4.ZERO
	if screen_size.x <= 0 or screen_size.y <= 0:
		return Vector4.ZERO

	return Vector4(
		maxf(0.0, safe_area.position.x),
		maxf(0.0, safe_area.position.y),
		maxf(0.0, screen_size.x - safe_area.end.x),
		maxf(0.0, screen_size.y - safe_area.end.y)
	)


func _margin(inset: float) -> int:
	return maxi(minimum_margin, ceili(inset))


func _screen_size() -> Vector2i:
	var size := DisplayServer.screen_get_size()
	# Headless, and on some web configurations, the display server reports
	# nothing; the window is the best stand-in.
	return size if size.x > 0 and size.y > 0 else get_window().size


## Canvas units per screen pixel.
##
## The safe area is measured in screen pixels while a margin constant is in
## canvas units, and a [code]canvas_items[/code] stretch mode makes those two
## different sizes. This assumes the window covers the screen, which is the
## only situation where a notch exists to avoid.
func _canvas_units_per_screen_pixel() -> Vector2:
	var window_size := Vector2(get_window().size)
	if window_size.x <= 0.0 or window_size.y <= 0.0:
		return Vector2.ONE
	return get_viewport().get_visible_rect().size / window_size
