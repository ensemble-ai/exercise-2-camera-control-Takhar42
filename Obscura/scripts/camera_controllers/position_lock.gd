class_name PositionLock
extends CameraControllerBase

var canvas: CanvasLayer
var display: ColorRect
var vertical_line: ColorRect

func _ready() -> void:
	super()
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
	set_camera_position()

func set_camera_position() -> void:
	if target:
		global_position.x = target.global_position.x
		global_position.z = target.global_position.z
		global_position.y = target.global_position.y + dist_above_target

func _physics_process(delta: float) -> void:
	if !target:
		return
		
	display.visible = draw_camera_logic and current
	vertical_line.visible = draw_camera_logic and current
	
	if Input.is_action_pressed("zoom_in"):
		dist_above_target = clampf(dist_above_target - zoom_speed * delta, min_zoom, max_zoom)
	if Input.is_action_pressed("zoom_out"):
		dist_above_target = clampf(dist_above_target + zoom_speed * delta, min_zoom, max_zoom)
		
	set_camera_position()

func draw_logic() -> void:
	if display and vertical_line:
		display.visible = draw_camera_logic and current
		vertical_line.visible = draw_camera_logic and current
