extends Camera3D

# 定义最大和最小高度常量。
const MAX_HEIGHT = 2.0
const MIN_HEIGHT = 0.0

# 导出的变量，允许在编辑器中自定义。
@export var min_distance := 0.5  # 摄像机与目标之间的最小距离。
@export var max_distance := 3.5  # 摄像机与目标之间的最大距离。
@export var angle_v_adjust := 0.0  # 垂直角度调整。
@export var autoturn_ray_aperture := 25.0  # 自动旋转时射线的开口角度。
@export var autoturn_speed := 50.0  # 自动旋转速度。

# 存储可能需要忽略的碰撞体的数组。
var collision_exception: Array[RID] = []

func _ready():
	# 初始化，寻找碰撞例外。
	var node: Node = self
	while is_instance_valid(node):
		if node is RigidBody3D:
			collision_exception.append(node.get_rid())
			break
		else:
			node = node.get_parent()
	set_physics_process(true)
	# 将摄像机从父空间节点中分离。
	set_as_top_level(true)

func _physics_process(delta: float):
	# 物理处理函数，用于每帧更新摄像机位置。
	var target := (get_parent() as Node3D).get_global_transform().origin
	var pos := get_global_transform().origin

	var difference := pos - target

	# 确保摄像机跟随在规定的距离范围内。
	if difference.length() < min_distance:
		difference = difference.normalized() * min_distance
	elif  difference.length() > max_distance:
		difference = difference.normalized() * max_distance

	# 限制摄像机在最大和最小高度之间。
	difference.y = clamp(difference.y, MIN_HEIGHT, MAX_HEIGHT)

	# 自动旋转逻辑，使用射线检测来避免遮挡。
	var ds := PhysicsServer3D.space_get_direct_state(get_world_3d().get_space())
	# 左侧、中心和右侧射线检测。
	var col_left = ds.intersect_ray(PhysicsRayQueryParameters3D.create(
			target,
			target + Basis(Vector3.UP, deg_to_rad(autoturn_ray_aperture)) * (difference),
			0xFFFFFFFF,
			collision_exception
	))
	var col = ds.intersect_ray(PhysicsRayQueryParameters3D.create(
			target,
			target + difference,
			0xFFFFFFFF,
			collision_exception
	))
	var col_right = ds.intersect_ray(PhysicsRayQueryParameters3D.create(
			target,
			target + Basis(Vector3.UP, deg_to_rad(-autoturn_ray_aperture)) * (difference),
			0xFFFFFFFF,
			collision_exception
	))

	# 根据射线检测结果调整摄像机位置和方向。
	if not col.is_empty():
		# 如果中心射线被遮挡，摄像机靠近目标。
		difference = col.position - target
	elif not col_left.is_empty() and col_right.is_empty():
		# 如果只有左侧射线被遮挡，向右旋转摄像机。
		difference = Basis(Vector3.UP, deg_to_rad(-delta * (autoturn_speed))) * difference
	elif col_left.is_empty() and not col_right.is_empty():
		# 如果只有右侧射线被遮挡，向左旋转摄像机。
		difference = Basis(Vector3.UP, deg_to_rad(delta * autoturn_speed)) * difference
	# 如果左右射线都被遮挡，但中心不被遮挡，保持不动。

	# 更新摄像机的看向位置。
	if difference.is_zero_approx():
		difference = (pos - target).normalized() * 0.0001

	pos = target + difference

	look_at_from_position(pos, target, Vector3.UP)

	# 基于角度调整上下偏转。
	transform.basis = Basis(transform.basis[0], deg_to_rad(angle_v_adjust)) * transform.basis
