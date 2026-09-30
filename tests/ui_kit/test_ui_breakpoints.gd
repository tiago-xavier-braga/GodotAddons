extends UIKitTestCase

## Tests for the [code]UIBreakpoints[/code] autoload.

var _seen: Array[StringName] = []
var _original_threshold: int
var _original_window_size: Vector2i


func run() -> void:
	_original_threshold = UIBreakpoints.get_desktop_min_short_side()
	_original_window_size = UIBreakpoints.get_window().size
	UIBreakpoints.breakpoint_changed.connect(_record)

	_test_classification()
	_test_the_boundary()
	_test_orientation_of_a_square_screen()
	_test_threshold_is_configurable()
	_test_is_mobile_helper()
	_test_screen_scale_override()
	await _test_a_real_resize_emits_once()

	UIBreakpoints.breakpoint_changed.disconnect(_record)
	UIBreakpoints.set_desktop_min_short_side(_original_threshold)
	UIBreakpoints.set_screen_scale_override(0.0)
	UIBreakpoints.get_window().size = _original_window_size
	await next_frame()


func _test_classification() -> void:
	check_equal(
		UIBreakpoints.classify(Vector2(400, 800)),
		UIBreakpoint.MOBILE_PORTRAIT,
		"a tall phone is mobile_portrait"
	)
	check_equal(
		UIBreakpoints.classify(Vector2(800, 400)),
		UIBreakpoint.MOBILE_LANDSCAPE,
		"a phone on its side is mobile_landscape"
	)
	check_equal(
		UIBreakpoints.classify(Vector2(1280, 720)),
		UIBreakpoint.DESKTOP,
		"a 720p window is desktop"
	)

	# The short side is what is measured, so a desktop window shrunk to phone
	# proportions is treated like the phone it now resembles.
	check_equal(
		UIBreakpoints.classify(Vector2(960, 540)),
		UIBreakpoint.MOBILE_LANDSCAPE,
		"a wide but short window is mobile_landscape, not desktop"
	)


func _test_the_boundary() -> void:
	var threshold := UIBreakpoints.get_desktop_min_short_side()
	check_equal(
		UIBreakpoints.classify(Vector2(2000, threshold)),
		UIBreakpoint.DESKTOP,
		"exactly at the threshold is already desktop"
	)
	check_equal(
		UIBreakpoints.classify(Vector2(2000, threshold - 1)),
		UIBreakpoint.MOBILE_LANDSCAPE,
		"one pixel under the threshold is mobile"
	)


func _test_orientation_of_a_square_screen() -> void:
	check_equal(
		UIBreakpoints.classify(Vector2(300, 300)),
		UIBreakpoint.MOBILE_PORTRAIT,
		"a square screen counts as portrait, so the rule has no gap"
	)


## The threshold is a project setting, not a constant, so a project can retune
## it without editing the addon.
func _test_threshold_is_configurable() -> void:
	UIBreakpoints.set_desktop_min_short_side(300)
	check_equal(
		UIBreakpoints.classify(Vector2(400, 800)),
		UIBreakpoint.DESKTOP,
		"raising the bar reclassifies the same size"
	)

	UIBreakpoints.set_desktop_min_short_side(0)
	check(UIBreakpoints.get_desktop_min_short_side() >= 1, "the threshold cannot be set to zero")

	UIBreakpoints.set_desktop_min_short_side(_original_threshold)


func _test_is_mobile_helper() -> void:
	check(UIBreakpoint.is_mobile(UIBreakpoint.MOBILE_PORTRAIT), "portrait is mobile")
	check(UIBreakpoint.is_mobile(UIBreakpoint.MOBILE_LANDSCAPE), "landscape is mobile")
	check(not UIBreakpoint.is_mobile(UIBreakpoint.DESKTOP), "desktop is not mobile")
	check_equal(UIBreakpoint.ALL.size(), 3, "there are three built-in size classes")


## A phone reports its size in device pixels, which is two to three times the
## number a layout is authored in. Without the scale divisor, every modern
## phone would classify as a desktop.
func _test_screen_scale_override() -> void:
	UIBreakpoints.get_window().size = Vector2i(1080, 2400)
	UIBreakpoints.set_screen_scale_override(1.0)
	check_equal(
		UIBreakpoints.classify(UIBreakpoints.get_screen_size()),
		UIBreakpoint.DESKTOP,
		"1080x2400 raw device pixels would look like a desktop"
	)

	UIBreakpoints.set_screen_scale_override(2.75)
	check_approx(
		UIBreakpoints.get_screen_size().x,
		1080.0 / 2.75,
		"the scale divides the window size into density-independent pixels"
	)
	check_equal(
		UIBreakpoints.classify(UIBreakpoints.get_screen_size()),
		UIBreakpoint.MOBILE_PORTRAIT,
		"at the phone's real scale it is mobile_portrait"
	)

	UIBreakpoints.set_screen_scale_override(0.0)
	check(UIBreakpoints.get_screen_scale() > 0.0, "clearing the override falls back to the display")


## Everything above calls classify() directly; this proves the autoload is
## wired to the window and emits on the way through.
func _test_a_real_resize_emits_once() -> void:
	UIBreakpoints.set_screen_scale_override(1.0)
	UIBreakpoints.get_window().size = Vector2i(1280, 720)
	await next_frame()
	_seen.clear()

	UIBreakpoints.get_window().size = Vector2i(400, 800)
	await next_frame()
	check_equal(
		UIBreakpoints.get_active_breakpoint(),
		UIBreakpoint.MOBILE_PORTRAIT,
		"resizing the window updates the active breakpoint"
	)
	check_equal(_seen, [UIBreakpoint.MOBILE_PORTRAIT] as Array[StringName], "the resize emits once")

	# Still portrait, just smaller: a listener rebuilding a layout must not be
	# woken for every pixel of a window drag.
	UIBreakpoints.get_window().size = Vector2i(380, 760)
	await next_frame()
	check_equal(
		_seen, [UIBreakpoint.MOBILE_PORTRAIT] as Array[StringName], "a resize within one class is silent"
	)


func _record(size_class: StringName) -> void:
	_seen.append(size_class)
