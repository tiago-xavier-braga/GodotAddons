extends Control

## Phase 4 demo: three rows of the same four buttons, at three screen sizes.
##
## The first row is a plain [HBoxContainer] with fixed minimum widths — the
## layout you write before thinking about phones. Shrink the window and it
## simply runs off the edge, because a stretch mode scales a layout and never
## rearranges it.
##
## The second row is an [HFlowContainer] and wraps by itself. It needs no
## breakpoint at all, and that is the point: reach for a native container
## first.
##
## The third row is the case a container cannot cover on its own — a row that
## has to become a column. One line in [method _apply] does it, driven by
## [signal UIBreakpoints.breakpoint_changed].

## Window sizes the preset buttons jump to, so the switch can be seen without
## dragging a window edge.
@export var previews: Array[Vector2i] = [
	Vector2i(400, 800),
	Vector2i(800, 400),
	Vector2i(1280, 720),
]

@onready var _readout: Label = %Readout
@onready var _toggling_row: BoxContainer = %TogglingRow
@onready var _presets: HBoxContainer = %Presets


func _ready() -> void:
	for size: Vector2i in previews:
		var button := UIButton.new()
		button.variation = UIButton.Variation.SECONDARY
		button.text = "%d x %d" % [size.x, size.y]
		button.pressed.connect(_on_preview_pressed.bind(size))
		_presets.add_child(button)

	UIBreakpoints.breakpoint_changed.connect(_apply)
	_apply(UIBreakpoints.get_active_breakpoint())


func _on_preview_pressed(size: Vector2i) -> void:
	get_window().size = size


func _apply(size_class: StringName) -> void:
	# The whole responsive behaviour: a row becomes a column when there is no
	# width to spare. BoxContainer.vertical is Godot's, not ours — but note the
	# node is a plain BoxContainer: HBoxContainer and VBoxContainer exist only
	# to lock the orientation, and refuse to be flipped.
	_toggling_row.vertical = size_class == UIBreakpoint.MOBILE_PORTRAIT

	var size := UIBreakpoints.get_screen_size()
	_readout.text = "%s   —   %d x %d dip, scale %.2f" % [
		size_class, roundi(size.x), roundi(size.y), UIBreakpoints.get_screen_scale()
	]
