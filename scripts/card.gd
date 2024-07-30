extends Sprite2D

var clicked: bool = false
var clickable: bool = false
var value: int = 0

func _on_area_2d_input_event(viewport, event, shape_idx):
	if clickable and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked = !clicked
		if clicked:
			$clickedSFX.play()
			frame = 55
		else:
			$unclickedSFX.play()
			frame = 54
