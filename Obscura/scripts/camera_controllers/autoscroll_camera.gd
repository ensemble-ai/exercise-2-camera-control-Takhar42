class_name AutoscrollCamera
extends CameraControllerBase

@export var top_left: Vector2
@export var bottom_right: Vector2
@export var autoscroll_speed: Vector3

var box_position: Vector3

func _ready() -> void:
	super()
	if target:
		box_position = target.global_position
		global_position = box_position
		global_position.y += dist_above_target
	
	rotation.x = deg_to_rad(-90)

func _process(delta: float) -> void:
	if !target or !current:
		return
	
	box_position += autoscroll_speed * delta
	global_position = box_position
	global_position.y = target.global_position.y + dist_above_target
	
	var target_local_pos = Vector2(
		target.global_position.x - box_position.x,
		target.global_position.z - box_position.z
	)
	
	var constrained_pos = target.global_position
	
	if target_local_pos.x < top_left.x:
		constrained_pos.x = box_position.x + top_left.x
		target.velocity.x = max(target.velocity.x, autoscroll_speed.x)
	
	if target_local_pos.x > bottom_right.x:
		constrained_pos.x = box_position.x + bottom_right.x
	if target_local_pos.y < top_left.y:
		constrained_pos.z = box_position.z + top_left.y
	if target_local_pos.y > bottom_right.y:
		constrained_pos.z = box_position.z + bottom_right.y
	
	target.global_position = constrained_pos
	
	if draw_camera_logic:
		draw_logic()

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	var bl = Vector3(top_left.x, 0, bottom_right.y)
	var br = Vector3(bottom_right.x, 0, bottom_right.y)
	var tl = Vector3(top_left.x, 0, top_left.y)
	var tr = Vector3(bottom_right.x, 0, top_left.y)
	
	immediate_mesh.surface_add_vertex(box_position + bl)
	immediate_mesh.surface_add_vertex(box_position + br)
	immediate_mesh.surface_add_vertex(box_position + br)
	immediate_mesh.surface_add_vertex(box_position + tr)
	immediate_mesh.surface_add_vertex(box_position + tr)
	immediate_mesh.surface_add_vertex(box_position + tl)
	immediate_mesh.surface_add_vertex(box_position + tl)
	immediate_mesh.surface_add_vertex(box_position + bl)
	
	immediate_mesh.surface_end()
	
	add_child(mesh_instance)
	await get_tree().process_frame
	mesh_instance.queue_free()
