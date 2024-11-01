extends Label

func _ready():
	pass

func _process(delta: float):
	var parent = get_parent()
	if parent:
		text = str(round((parent as Node3D).global_position))
	else:
		text = "No parent"
	
	text += "\n"
	
	var vessel = get_node_or_null("%Vessel")
	if vessel:
		text += str(round((vessel as Vessel).global_position))
	else:
		text += "No vessel found"
	
	text += "\n"
	text += str(round(1.0 / delta))
	text += "\n"
	text += str(Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).limit_length(1.0))
