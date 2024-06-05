extends Label


@export var slider: HSlider:
	set(value):
		slider = value
		slider.value_changed.connect(_on_slider_value_changed)


func _ready():
	_set_label()


func _on_slider_value_changed(_value):
	_set_label()


func _set_label():
	text = "%s" % [slider.value]
