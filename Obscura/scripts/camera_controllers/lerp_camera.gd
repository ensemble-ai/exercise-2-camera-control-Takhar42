class_name LerpCamera
extends CameraControllerBase

@export var follow_speed: float = 5.0
@export var catchup_speed: float = 10.0
@export var leash_distance: float = 10.0

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
	
	display.visible = false
	vertical_line.visible = false

func _process(delta: float) -> void:
	if !target or !current:
		return

	display.visible = draw_camera_logic
	vertical_line.visible = draw_camera_logic
	
	var target_velocity = target.velocity.length()
	var current_speed = follow_speed if target_velocity > 0 else catchup_speed
	
	var direction = target.position - position
	direction.y = 0
	
	if direction.length() > leash_distance:
		position += direction.normalized() * (direction.length() - leash_distance)
	else:
		position += direction * (current_speed * delta)
	
	position.y = target.position.y + dist_above_target

func draw_logic() -> void:
	if display and vertical_line:
		display.visible = draw_camera_logic
		vertical_line.visible = draw_camera_logic
