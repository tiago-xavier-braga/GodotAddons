extends UIKitTestCase

## Tests for [UIButton] and [UIFocusPrompt].

const PROMPT_SCENE := "res://addons/ui_kit/components/focus_prompt/ui_focus_prompt.tscn"
const THEME := "res://addons/ui_kit/theme/default_theme.tres"

var _stage: Control
var _button: Button
var _prompt: UIFocusPrompt


func run() -> void:
	_test_button_variation_picks_the_variation()
	_test_button_keeps_a_touch_sized_target()
	await _test_prompt_follows_focus()
	await _test_prompt_follows_the_active_device()
	await _test_prompt_flips_at_the_screen_edge()
	await _test_prompt_hides_without_a_glyph()
	await _test_prompt_hides_without_focus()
	_teardown()


func _test_button_variation_picks_the_variation() -> void:
	var button := UIButton.new()
	add_child(button)

	button.variation = UIButton.Variation.PRIMARY
	check_equal(
		button.theme_type_variation, UIVariants.PRIMARY_BUTTON, "PRIMARY selects UIPrimaryButton"
	)
	button.variation = UIButton.Variation.SECONDARY
	check_equal(
		button.theme_type_variation,
		UIVariants.SECONDARY_BUTTON,
		"SECONDARY selects UISecondaryButton"
	)
	button.variation = UIButton.Variation.ICON
	check_equal(button.theme_type_variation, UIVariants.ICON_BUTTON, "ICON selects UIIconButton")

	button.queue_free()


func _test_button_keeps_a_touch_sized_target() -> void:
	var button := UIButton.new()
	add_child(button)

	button.variation = UIButton.Variation.PRIMARY
	check(
		button.custom_minimum_size.y >= UIMetrics.MIN_TOUCH_TARGET,
		"a button is at least one touch target tall"
	)
	check(
		button.custom_minimum_size.x < UIMetrics.MIN_TOUCH_TARGET,
		"a labelled button does not get a width floor, so it can still hug its text"
	)

	button.variation = UIButton.Variation.ICON
	check(
		button.custom_minimum_size.x >= UIMetrics.MIN_TOUCH_TARGET,
		"an icon button is square and at least one touch target wide"
	)

	# A scene asking for something bigger has to win.
	button.custom_minimum_size = Vector2(200, 90)
	button.variation = UIButton.Variation.PRIMARY
	check_equal(
		button.custom_minimum_size, Vector2(200, 90), "a larger explicit minimum size is kept"
	)

	button.queue_free()


func _test_prompt_follows_focus() -> void:
	await _setup()
	_button.grab_focus()
	await next_frame()

	var glyph := _glyph()
	check(glyph.visible, "the prompt shows once something has focus")
	check(glyph.texture != null, "the prompt has a glyph for the active device")

	var rect := _button.get_global_rect()
	check_equal(
		glyph.position.x, rect.end.x + _prompt.gap, "the glyph sits just past the control's right edge"
	)
	check_equal(
		glyph.position.y,
		rect.position.y + (rect.size.y - _prompt.glyph_size) * 0.5,
		"the glyph is centred on the control"
	)
	check_equal(
		glyph.modulate,
		_button.get_theme_color(&"font_color"),
		"the glyph borrows the focused control's text colour, so it tracks the palette"
	)

	# Moving the control has to move the glyph — a breakpoint change or a
	# scroll must not leave it stranded.
	_button.position += Vector2(40, 30)
	await next_frame()
	check_equal(
		glyph.position.x,
		_button.get_global_rect().end.x + _prompt.gap,
		"the glyph follows a control that moves"
	)


func _test_prompt_follows_the_active_device() -> void:
	await _setup()
	_button.grab_focus()
	await next_frame()

	var glyph := _glyph()
	check_equal(
		glyph.texture, _prompt.prompts.keyboard_mouse, "on keyboard, the keyboard glyph is drawn"
	)

	var pad := InputEventJoypadButton.new()
	pad.button_index = JOY_BUTTON_A
	pad.pressed = true
	Input.parse_input_event(pad)
	await next_frame()
	check_equal(glyph.texture, _prompt.prompts.gamepad, "the glyph swaps when the device changes")

	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	Input.parse_input_event(touch)
	await next_frame()
	check_equal(glyph.texture, _prompt.prompts.touch, "and again for touch")


## A menu anchored to the right edge would push the glyph off screen.
func _test_prompt_flips_at_the_screen_edge() -> void:
	await _setup()
	var viewport_width := _prompt.get_viewport().get_visible_rect().size.x
	_button.position = Vector2(viewport_width - _button.size.x, 100.0)
	_button.grab_focus()
	await next_frame()

	var glyph := _glyph()
	var rect := _button.get_global_rect()
	check_equal(
		glyph.position.x,
		rect.position.x - _prompt.gap - _prompt.glyph_size,
		"a control at the right edge gets its glyph on the left instead"
	)
	check(glyph.position.x >= 0.0, "the flipped glyph is still on screen")


## An empty slot in the prompt set is how a project says "no prompt for this
## device" — most often for mouse players.
func _test_prompt_hides_without_a_glyph() -> void:
	await _setup()
	_prompt.prompts.keyboard_mouse = null
	var key := InputEventKey.new()
	key.keycode = KEY_SPACE
	key.pressed = true
	Input.parse_input_event(key)
	_button.grab_focus()
	await next_frame()

	check(not _glyph().visible, "an empty glyph slot hides the prompt for that device")


func _test_prompt_hides_without_focus() -> void:
	await _setup()
	_button.grab_focus()
	await next_frame()
	check(_glyph().visible, "visible while focused")

	# Nothing is emitted when focus is dropped, which is why the overlay
	# re-reads the focus owner every frame rather than trusting the signal.
	_button.release_focus()
	await next_frame()
	check(not _glyph().visible, "the prompt hides when nothing has focus")

	_button.grab_focus()
	await next_frame()
	_button.hide()
	await next_frame()
	check(not _glyph().visible, "the prompt hides when the focused control is hidden")
	_button.show()


# --- fixture ---


func _setup() -> void:
	_teardown()

	_stage = Control.new()
	_stage.theme = load(THEME)
	_stage.size = Vector2(1000, 700)
	add_child(_stage)

	_button = Button.new()
	_button.text = "Focus me"
	_button.position = Vector2(100, 100)
	_button.size = Vector2(200, 50)
	_stage.add_child(_button)

	_prompt = (load(PROMPT_SCENE) as PackedScene).instantiate() as UIFocusPrompt
	# Duplicated, because a test that clears a slot must not scribble on the
	# resource the addon ships.
	_prompt.prompts = _prompt.prompts.duplicate() as UIPromptSet
	add_child(_prompt)

	await next_frame()


func _teardown() -> void:
	for node: Node in [_prompt, _stage]:
		if node != null and node.is_inside_tree():
			remove_child(node)
			node.free()
	_prompt = null
	_stage = null
	_button = null


func _glyph() -> TextureRect:
	return _prompt.get_node("Glyph") as TextureRect
