class_name SpeedupCamera
extends CameraControllerBase

@export var push_ratio: float = 1.5
@export var pushbox_top_left: Vector2
@export var pushbox_bottom_right: Vector2
@export var speedup_zone_top_left: Vector2
@export var speedup_zone_bottom_right: Vector2
@export var camera_height: float = 40.0

var canvas: CanvasLayer
var display: ColorRect
var vertical_line: ColorRect

func _ready() -> void:
	super()
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
	
	rotation.x = deg_to_rad(-90)
	position = target.position + Vector3(0, camera_height, 0)

func _physics_process(delta: float) -> void:
	if !target or !current:
		return
	
	display.visible = draw_camera_logic
	vertical_line.visible = draw_camera_logic

	var target_position = target.global_position
	var target_pos_2d = Vector2(target_position.x, target_position.z)
	var target_velocity = target.velocity.length()

	if target_velocity == 0:
		position = target_position + Vector3(0, camera_height, 0)
		return

	if is_in_speedup_zone(target_pos_2d):
		position = target_position + Vector3(0, camera_height, 0)
		return

	update_camera_movement(target_pos_2d, delta)

func update_camera_movement(target_pos_2d: Vector2, delta: float) -> void:
	var edges = get_touching_edges(target_pos_2d)
	
	if edges.size() == 2:
		position.x += target.velocity.x * delta
		position.z += target.velocity.z * delta
	elif edges.size() == 1:
		if "left" in edges or "right" in edges:
			position.x += target.velocity.x * delta
			position.z += target.velocity.z * push_ratio * delta
		else:
			position.x += target.velocity.x * push_ratio * delta
			position.z += target.velocity.z * delta
	elif not is_in_speedup_zone(target_pos_2d):
		position.x += target.velocity.x * push_ratio * delta
		position.z += target.velocity.z * push_ratio * delta

	position.y = target.global_position.y + camera_height
	rotation.x = deg_to_rad(-90)

func is_in_speedup_zone(pos: Vector2) -> bool:
	return (pos.x >= speedup_zone_top_left.x and 
			pos.x <= speedup_zone_bottom_right.x and
			pos.y >= speedup_zone_top_left.y and 
			pos.y <= speedup_zone_bottom_right.y)

func get_touching_edges(pos: Vector2) -> Array:
	var edges = []
	if pos.x <= pushbox_top_left.x:
		edges.append("left")
	if pos.x >= pushbox_bottom_right.x:
		edges.append("right")
	if pos.y <= pushbox_top_left.y:
		edges.append("top")
	if pos.y >= pushbox_bottom_right.y:
		edges.append("bottom")
	return edges

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	draw_box(immediate_mesh, pushbox_top_left, pushbox_bottom_right)
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	draw_box(immediate_mesh, speedup_zone_top_left, speedup_zone_bottom_right)
	
	immediate_mesh.surface_end()
	
	add_child(mesh_instance)
	await get_tree().process_frame
	mesh_instance.queue_free()

func draw_box(immediate_mesh: ImmediateMesh, top_left: Vector2, bottom_right: Vector2) -> void:
	var bl = Vector3(top_left.x, 0, bottom_right.y)
	var br = Vector3(bottom_right.x, 0, bottom_right.y)
	var tl = Vector3(top_left.x, 0, top_left.y)
	var tr = Vector3(bottom_right.x, 0, top_left.y)
	
	immediate_mesh.surface_add_vertex(bl)
	immediate_mesh.surface_add_vertex(br)
	immediate_mesh.surface_add_vertex(br)
	immediate_mesh.surface_add_vertex(tr)
	immediate_mesh.surface_add_vertex(tr)
	immediate_mesh.surface_add_vertex(tl)
	immediate_mesh.surface_add_vertex(tl)
	immediate_mesh.surface_add_vertex(bl)
