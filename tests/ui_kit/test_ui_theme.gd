extends UIKitTestCase

## Tests for the token pipeline: [UIPalette]/[UITypography] into a [UITheme]
## via [UIThemeBuilder].

const DEFAULT_THEME_PATH := "res://addons/ui_kit/theme/default_theme.tres"


func run() -> void:
	_test_default_theme_is_generated()
	_test_variations_exist()
	_test_editing_a_token_rebuilds()
	_test_swapping_the_palette_rebuilds()
	_test_apply_is_idempotent()
	_test_apply_survives_missing_tokens()
	await _test_controls_follow_the_theme()


func _test_default_theme_is_generated() -> void:
	var theme := _fresh_theme()
	check(theme != null, "default_theme.tres loads as a UITheme")
	check(theme.palette != null, "the shipped theme carries a palette")
	check(theme.typography != null, "the shipped theme carries a typography")
	check(theme.default_font != null, "the bundled font reaches Theme.default_font")
	check_equal(
		theme.default_font_size,
		theme.typography.size_body,
		"Theme.default_font_size comes from the tokens"
	)


func _test_variations_exist() -> void:
	var theme := _fresh_theme()
	var expected := {
		UIVariants.PRIMARY_BUTTON: &"Button",
		UIVariants.SECONDARY_BUTTON: &"Button",
		UIVariants.ICON_BUTTON: &"Button",
		UIVariants.PANEL: &"Panel",
		UIVariants.HEADING: &"Label",
		UIVariants.BODY: &"Label",
		UIVariants.CAPTION: &"Label",
	}
	for variation: StringName in expected:
		check_equal(
			theme.get_type_variation_base(variation),
			expected[variation],
			"%s is a variation of %s" % [variation, expected[variation]]
		)

	check_equal(
		(theme.get_stylebox(&"normal", UIVariants.PRIMARY_BUTTON) as StyleBoxFlat).bg_color,
		theme.palette.accent,
		"the primary button is filled with the accent token"
	)
	check_equal(
		theme.get_font_size(&"font_size", UIVariants.HEADING),
		theme.typography.size_heading,
		"the heading label uses the heading size token"
	)


## Editing one field inside the palette has to rebuild the theme — not just
## assigning a whole new palette resource.
func _test_editing_a_token_rebuilds() -> void:
	var theme := _fresh_theme()
	theme.palette.accent = Color.MAGENTA
	check_equal(
		(theme.get_stylebox(&"normal", UIVariants.PRIMARY_BUTTON) as StyleBoxFlat).bg_color,
		Color.MAGENTA,
		"changing palette.accent re-derives the primary button fill"
	)

	theme.typography.size_heading = 99
	check_equal(
		theme.get_font_size(&"font_size", UIVariants.HEADING),
		99,
		"changing a typography size re-derives the heading"
	)


func _test_swapping_the_palette_rebuilds() -> void:
	var theme := _fresh_theme()
	var replacement := UIPalette.new()
	replacement.accent = Color.LIME_GREEN
	theme.palette = replacement

	check_equal(
		(theme.get_stylebox(&"normal", UIVariants.PRIMARY_BUTTON) as StyleBoxFlat).bg_color,
		Color.LIME_GREEN,
		"a whole-palette swap re-derives the theme"
	)

	# The theme must stop listening to the palette it no longer holds, or a
	# settings screen that keeps old palettes around rebuilds on every edit to
	# any of them.
	var abandoned := _fresh_theme().palette
	theme.palette = abandoned
	theme.palette = replacement
	abandoned.accent = Color.RED
	check_equal(
		(theme.get_stylebox(&"normal", UIVariants.PRIMARY_BUTTON) as StyleBoxFlat).bg_color,
		Color.LIME_GREEN,
		"a palette that was swapped out no longer rebuilds the theme"
	)


func _test_apply_is_idempotent() -> void:
	var theme := _fresh_theme()
	var types_before := theme.get_type_list()
	types_before.sort()

	UIThemeBuilder.apply(theme, theme.palette, theme.typography)
	UIThemeBuilder.apply(theme, theme.palette, theme.typography)

	var types_after := theme.get_type_list()
	types_after.sort()
	check_equal(types_after, types_before, "applying twice leaves the same set of types")


## A project that has not filled in its tokens yet must not crash on load.
func _test_apply_survives_missing_tokens() -> void:
	var bare := Theme.new()
	UIThemeBuilder.apply(bare, null, null)
	check_equal(bare.get_type_list().size(), 0, "apply() with no tokens is a no-op")

	var typography := UITypography.new()
	var theme := Theme.new()
	UIThemeBuilder.apply(theme, UIPalette.new(), typography)
	check(theme.get_type_list().size() > 0, "apply() works with no fonts assigned")
	check(
		not theme.has_font(&"font", UIVariants.PRIMARY_BUTTON),
		"a typography with no font sets no font item, rather than a null one"
	)


## Godot propagates a theme change to Controls on the following frame, so a
## re-skin is visible one frame after the token edit, not in the same one.
func _test_controls_follow_the_theme() -> void:
	var theme := _fresh_theme()
	var button := Button.new()
	button.theme = theme
	button.theme_type_variation = UIVariants.PRIMARY_BUTTON
	add_child(button)
	await next_frame()

	check_equal(
		(button.get_theme_stylebox(&"normal") as StyleBoxFlat).bg_color,
		theme.palette.accent,
		"a Button resolves the generated variation"
	)

	theme.palette.accent = Color.CYAN
	await next_frame()
	check_equal(
		(button.get_theme_stylebox(&"normal") as StyleBoxFlat).bg_color,
		Color.CYAN,
		"the Button picks up a token edit on the next frame"
	)

	button.queue_free()


## A private copy per test, so mutating tokens cannot leak into the next one
## through the resource cache.
func _fresh_theme() -> UITheme:
	var theme := load(DEFAULT_THEME_PATH) as UITheme
	var copy := UITheme.new()
	copy.palette = theme.palette.duplicate() as UIPalette
	copy.typography = theme.typography.duplicate() as UITypography
	return copy
