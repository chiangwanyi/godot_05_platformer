extends Camera3D

# 初始化参数
@export var min_radius = 1.0
@export var shrink_speed = 10
@export var grow_speed = shrink_speed
@export var max_radius = 5.0
@export var radius = max_radius  # 圆周运动的半径
@export var mouse_sensitivity = 0.0025  # 鼠标灵敏度

@export var character : CharacterBody3D

var horizontal_angle = 0.0  # 水平方向的初始角度
var vertical_angle = 0.0    # 垂直方向的初始角度

@export var autoturn_ray_aperture := 25.0

func _ready():
	set_process_input(true)

	# 隐藏鼠标并锁定其位置
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		# 根据鼠标移动更新角度
		horizontal_angle -= event.relative.x * mouse_sensitivity
		vertical_angle += event.relative.y * mouse_sensitivity
		vertical_angle = clamp(vertical_angle, -PI/2 + 0.01, PI/2 - 0.01)  # 限制垂直角度
	
	if Input.is_action_pressed("exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	var target := (get_parent() as Node3D).global_transform.origin
	var pos := get_global_transform().origin
	
	var difference := pos - target
	
	var root = get_tree().get_root()
	
	var line = MeshInstance3D.new()
	var mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	
	line.mesh = mesh
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	mesh.surface_add_vertex(target)
	mesh.surface_add_vertex(pos)
	mesh.surface_end()
	
	root.add_child(line)

	#line.mesh.surface_add_vertex(target + Basis(Vector3.UP, deg_to_rad(autoturn_ray_aperture)) * Vector3(1, 1, 1))
	#line.mesh.surface_add_vertex(pos)
	#line.mesh.surface_end()

 
	# 创建 PhysicsRayQueryParameters3D 对象
	#var ray_query = PhysicsRayQueryParameters3D.new()
	#ray_query.from = global_transform.origin
	#ray_query.to = target
#
	## 使用 PhysicsRayQueryParameters3D 对象进行射线检测
	#var space_state = get_world_3d().direct_space_state
	#var result = space_state.intersect_ray(ray_query)
	
	#if (result.collider == character):
		#radius = max_radius
	#else:
		#radius -= delta * shrink_speed

	# 确保 radius 在合理范围内
	#radius = clamp(radius, min_radius, max_radius)

	# 根据新的 radius 计算摄像机位置
	var x = radius * cos(vertical_angle) * sin(horizontal_angle)
	var y = radius * sin(vertical_angle)
	var z = radius * cos(vertical_angle) * cos(horizontal_angle)

	global_transform.origin = Vector3(x, y, z) + target
	look_at(target, Vector3.UP)
