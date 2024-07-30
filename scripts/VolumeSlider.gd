extends HSlider

func _ready() -> void:
	value_changed.connect(_on_value_changed)
	value = db_to_linear(AudioServer.get_bus_volume_db(0))

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	print(db_to_linear(AudioServer.get_bus_volume_db(0)))
	$samplesound.play()
