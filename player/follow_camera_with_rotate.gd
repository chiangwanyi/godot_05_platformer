extends Camera3D

# 摄像头旋转速度
var mouse_sensitivity = 0.1

# 摄像机与目标点（玩家）之间的距离
var distance_to_target = 5.0

# 旋转角度（偏航角）
var yaw = 0.0
# 旋转角度（俯仰角）
var pitch = 0.0

func _ready():
	set_physics_process(true)

	# 隐藏鼠标并锁定其位置
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# 处理鼠标输入
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * mouse_sensitivity
		pitch += -event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -90, 10) # 防止过度旋转
	
	if Input.is_action_pressed("exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# 确定摄像机位置和旋转
	var target = (get_parent() as Node3D).global_transform.origin
	var rotation_dir = Vector3(sin(deg_to_rad(yaw)), -sin(deg_to_rad(pitch)), cos(deg_to_rad(yaw)) * cos(deg_to_rad(pitch)))
	global_transform.origin = target + rotation_dir.normalized() * distance_to_target

	# 始终面向目标点
	look_at(target, Vector3.UP)
