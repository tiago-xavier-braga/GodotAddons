extends UIKitTestCase

## Tests for [UISafeArea].
##
## The inset arithmetic is checked against made-up screens, because the one
## machine this suite runs on has no notch — and the platforms that do are
## exactly the ones a desktop test run cannot reach.

const TEMPLATES: PackedStringArray = [
	"res://addons/ui_kit/templates/main_menu/main_menu.tscn",
	"res://addons/ui_kit/templates/pause_menu/pause_menu.tscn",
	"res://addons/ui_kit/templates/settings_menu/settings_menu.tscn",
]


func run() -> void:
	_test_a_notch_at_the_top()
	_test_a_notch_in_landscape()
	_test_a_screen_with_nothing_in_the_way()
	_test_nonsense_input_yields_no_insets()
	await _test_minimum_margin_is_a_floor()
	await _test_every_template_uses_it()


## A phone held upright: cut-out above, gesture bar below.
func _test_a_notch_at_the_top() -> void:
	var insets := UISafeArea.screen_insets(Rect2i(0, 90, 1080, 2250), Vector2i(1080, 2400))
	check_equal(insets.x, 0.0, "nothing on the left")
	check_equal(insets.y, 90.0, "the cut-out becomes a top inset")
	check_equal(insets.z, 0.0, "nothing on the right")
	check_equal(insets.w, 60.0, "the gesture bar becomes a bottom inset")


## The same phone turned sideways: both obstructions move to the short edges.
func _test_a_notch_in_landscape() -> void:
	var insets := UISafeArea.screen_insets(Rect2i(90, 0, 2250, 1080), Vector2i(2400, 1080))
	check_equal(insets.x, 90.0, "the cut-out becomes a left inset")
	check_equal(insets.z, 60.0, "the gesture bar becomes a right inset")
	check_equal(insets.y, 0.0, "nothing above")
	check_equal(insets.w, 0.0, "nothing below")


func _test_a_screen_with_nothing_in_the_way() -> void:
	var insets := UISafeArea.screen_insets(Rect2i(0, 0, 1920, 1080), Vector2i(1920, 1080))
	check_equal(insets, Vector4.ZERO, "a desktop screen produces no insets")


## Every platform that cannot answer reports something unusable here, and a
## negative margin would push content off screen rather than away from an edge.
func _test_nonsense_input_yields_no_insets() -> void:
	check_equal(
		UISafeArea.screen_insets(Rect2i(0, 0, 0, 0), Vector2i(1080, 2400)),
		Vector4.ZERO,
		"an empty safe area means no insets, not full-screen margins"
	)
	check_equal(
		UISafeArea.screen_insets(Rect2i(0, 0, 1080, 2400), Vector2i(0, 0)),
		Vector4.ZERO,
		"an unknown screen size means no insets"
	)
	var oversized := UISafeArea.screen_insets(
		Rect2i(-20, -20, 2000, 3000), Vector2i(1080, 2400)
	)
	check_equal(oversized, Vector4.ZERO, "a safe area larger than the screen clamps to zero")


func _test_minimum_margin_is_a_floor() -> void:
	var area := UISafeArea.new()
	add_child(area)
	await next_frame()

	check_equal(
		area.get_theme_constant(&"margin_left"),
		area.minimum_margin,
		"with no notch, the margin is the configured minimum"
	)

	area.minimum_margin = 64
	await next_frame()
	check_equal(area.get_theme_constant(&"margin_top"), 64, "raising the minimum reapplies it")
	check_equal(area.get_theme_constant(&"margin_bottom"), 64, "on every side")

	area.queue_free()


## The point of the class is that the templates actually use it.
func _test_every_template_uses_it() -> void:
	for path: String in TEMPLATES:
		var menu := (load(path) as PackedScene).instantiate()
		add_child(menu)
		await next_frame()

		var areas := _safe_areas(menu)
		check_equal(
			areas.size(), 1, "%s wraps its content in exactly one UISafeArea" % path.get_file()
		)
		if not areas.is_empty():
			check(
				areas[0].get_theme_constant(&"margin_left") > 0,
				"%s: the safe area has a real margin" % path.get_file()
			)

		menu.queue_free()
		await next_frame()


func _safe_areas(root: Node) -> Array[UISafeArea]:
	var found: Array[UISafeArea] = []
	if root is UISafeArea:
		found.append(root as UISafeArea)
	for child: Node in root.get_children():
		found.append_array(_safe_areas(child))
	return found
