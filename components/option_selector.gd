extends Node

## Provides "Previous" and "Next" buttons to cycle through options in [OptionButton]s.
##
## This component is only provides the functionality.
## The [member option] [OptionButton], the [member previous], and [member next] [Button]s must be provided to it.

## The OptionButton that the Previous and Next buttons are added to
@export var option: OptionButton

## The Previous button, which will select the previous option before the currently selected one.
@export var previous: Button

## The Next button, which will select the next option after the currently selected one.
@export var next: Button


func _ready():
	if owner:
		# Waiting for the scene owner to be ready means the entire scene will be ready.
		await owner.ready
	
	# Connect the previous/next buttons
	if previous:
		previous.pressed.connect(_on_previous_pressed)
	if next:
		next.pressed.connect(_on_next_pressed)

	if option:
		option.item_selected.connect(_on_item_selected)
		# trigger the callback for the initial button states, without emitting the signal
		_on_item_selected(option.selected)


## If an option has been selected, we might have to enable/disable
## the previous/next buttons.
func _on_item_selected(index: int) -> void:
	if previous:
		previous.disabled = index == 0
	if next:
		next.disabled = index == option.item_count - 1


## Selects the previous option, if possible.
func _on_previous_pressed():
	if not option:
		return
	if option.selected > 0:
		option.select(option.selected - 1)
		option.item_selected.emit(option.selected)


## Selects the next option, if possible.
func _on_next_pressed():
	if not option:
		return
	if option.selected < option.item_count - 1:
		option.select(option.selected + 1)
		option.item_selected.emit(option.selected)
