extends Node

## Reports which size class the screen is in, and nothing else.
##
## Registered as the [code]UIBreakpoints[/code] autoload when the plugin is
## enabled.
##
## Godot's stretch modes scale a layout but never rearrange it: a row of
## buttons that fits a Steam window still overflows a phone held upright.
## Godot does have containers that rearrange — [HFlowContainer] wraps,
## [member BoxContainer.vertical] flips at runtime — it just has no idea how
## big the screen is. This fills in that one missing fact. It deliberately
## restructures nothing itself: a scene listens to
## [signal breakpoint_changed] and flips a native container, which is both less
## code and better behaved than a custom [Container] would be.
##
## See [UIBreakpoint] for the size classes.

## Emitted when the size class changes — not on every resize.
##
## The parameter is not called [code]breakpoint[/code] because that is a
## GDScript keyword.
signal breakpoint_changed(size_class: StringName)

## Project setting holding the threshold, so a consumer can retune it under
## [code]Project Settings[/code] without editing the addon.
const SETTING_DESKTOP_MIN_SHORT_SIDE := "ui_kit/breakpoints/desktop_min_short_side"

## Below this many density-independent pixels on the *shorter* side, the screen
## counts as mobile. One threshold covers three classes, because orientation
## decides which of the two mobile classes applies — and it means a small
## desktop window behaves like the phone it is the same size as, which is
## what you want.
const DEFAULT_DESKTOP_MIN_SHORT_SIDE := 600

var _active: StringName = UIBreakpoint.DESKTOP
var _desktop_min_short_side: int = DEFAULT_DESKTOP_MIN_SHORT_SIDE
var _screen_scale_override: float = 0.0


func _ready() -> void:
	# A pause menu is resized like anything else while the tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_desktop_min_short_side = int(
		ProjectSettings.get_setting(
			SETTING_DESKTOP_MIN_SHORT_SIDE, DEFAULT_DESKTOP_MIN_SHORT_SIDE
		)
	)
	get_window().size_changed.connect(refresh)
	_active = classify(get_screen_size())


## The current size class.
func get_active_breakpoint() -> StringName:
	return _active


## Re-reads the screen and emits [signal breakpoint_changed] if the class moved.
##
## Called for you on every window resize. Call it by hand after the one thing
## no signal covers: dragging the window onto a monitor with a different scale.
func refresh() -> void:
	var next := classify(get_screen_size())
	if next == _active:
		return
	_active = next
	breakpoint_changed.emit(_active)


## Which size class [param size] falls into. Public because it is the whole
## rule, and because it can be checked without resizing a real window.
func classify(size: Vector2) -> StringName:
	if minf(size.x, size.y) >= float(_desktop_min_short_side):
		return UIBreakpoint.DESKTOP
	return UIBreakpoint.MOBILE_PORTRAIT if size.y >= size.x else UIBreakpoint.MOBILE_LANDSCAPE


## The window's size in density-independent pixels — the number the threshold
## is compared against.
##
## Not the viewport's visible rect, which is the obvious first guess and does
## not work: under a [code]canvas_items[/code] stretch mode with an
## [code]expand[/code] aspect, the canvas keeps the project's base width and
## grows only in the other direction, so its shorter side is very nearly
## constant no matter what the screen does. The window is the only thing that
## actually reflects the device.
func get_screen_size() -> Vector2:
	return Vector2(get_window().size) / get_screen_scale()


## The display's scale factor, used to turn window pixels into
## density-independent ones.
##
## [method DisplayServer.screen_get_scale] reports this on the platforms where
## it differs from 1 — Android, iOS, macOS, Wayland, and the web, where it is
## [code]devicePixelRatio[/code]. X11 and Windows report 1.0, which is correct
## while the desktop is at 100% and wrong above it; a project that cares can
## pin the value with [method set_screen_scale_override].
func get_screen_scale() -> float:
	if _screen_scale_override > 0.0:
		return _screen_scale_override
	var scale := DisplayServer.screen_get_scale()
	return scale if scale > 0.0 else 1.0


## Forces the scale factor used by [method get_screen_size]. Pass 0 to go back
## to asking the display server.
func set_screen_scale_override(scale: float) -> void:
	_screen_scale_override = maxf(0.0, scale)
	refresh()


func get_desktop_min_short_side() -> int:
	return _desktop_min_short_side


func set_desktop_min_short_side(pixels: int) -> void:
	_desktop_min_short_side = maxi(1, pixels)
	refresh()
