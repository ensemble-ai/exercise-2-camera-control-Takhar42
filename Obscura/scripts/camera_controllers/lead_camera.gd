class_name LeadCamera
extends CameraControllerBase

@export var lead_speed: float = 15.0
@export var catchup_delay_duration: float = 0.5
@export var catchup_speed: float = 5.0
@export var leash_distance: float = 10.0

var canvas: CanvasLayer
var display: ColorRect
var vertical_line: ColorRect
var time_since_movement: float = 0.0

func _ready() -> void:
	if !target:
		return
		
	canvas = CanvasLayer.new()
	add_child(canvas)
	
	display = ColorRect.new()
	display.color = Color.WHITE
	display.size = Vector2(100, 4)  
	display.position = Vector2(
		get_viewport().get_visible_rect().size.x / 2 - 50,  
		get_viewport().get_visible_rect().size.y / 2 - 2     
	)
	canvas.add_child(display)
	
	vertical_line = ColorRect.new()
	vertical_line.color = Color.WHITE
	vertical_line.size = Vector2(4, 100)  
	vertical_line.position = Vector2(
		get_viewport().get_visible_rect().size.x / 2 - 2,    
		get_viewport().get_visible_rect().size.y / 2 - 50    
	)
	canvas.add_child(vertical_line)
	
	rotation.x = -PI/2

func _process(delta: float) -> void:
	if !target:
		return
		
	display.visible = current
	vertical_line.visible = current
	
	var input_dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	if input_dir.length() > 0:
		time_since_movement = 0
		var lead_offset = Vector3(input_dir.x, 0, input_dir.y) * leash_distance
		var desired_position = target.global_position
		var direction = desired_position - global_position
		direction.y = 0
		
		if direction.length() > leash_distance:
			direction = direction.normalized() * leash_distance
		
		global_position += direction * (lead_speed * delta)
	else:
		time_since_movement += delta
		if time_since_movement >= catchup_delay_duration:
			var direction = target.global_position - global_position
			direction.y = 0
			global_position += direction * (catchup_speed * delta)
	
	global_position.y = target.global_position.y + dist_above_target

func draw_logic() -> void:
	pass
