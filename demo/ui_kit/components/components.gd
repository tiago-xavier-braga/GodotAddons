extends Control

## Phase 3 demo: the whole component kit on one screen.
##
## Everything here is reachable with `ui_up`/`ui_down`/`ui_left`/`ui_right`,
## which Godot binds to both the arrow keys and a pad's d-pad out of the box.
## The focus order is not written down anywhere — it is computed from node
## positions because every control sits inside a [Container].

@onready var _device: Label = %ActiveDevice


func _ready() -> void:
	UIInput.device_changed.connect(_on_device_changed)
	_on_device_changed(UIInput.get_active_device())

	# Something has to hold focus for keyboard and pad navigation to have a
	# starting point — and for the focus prompt to have anything to point at.
	%PlayButton.grab_focus()


func _on_device_changed(device: UIInputDevice.Kind) -> void:
	_device.text = "active device: %s" % UIInputDevice.name_of(device)
