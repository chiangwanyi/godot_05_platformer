extends Camera3D

# 初始化参数
@export var radius = 5.0  # 圆周运动的半径
@export var mouse_sensitivity = 0.0025  # 鼠标灵敏度
var horizontal_angle = 0.0  # 水平方向的初始角度
var vertical_angle = 0.0    # 垂直方向的初始角度

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
	# 计算新位置
	var x = radius * cos(vertical_angle) * sin(horizontal_angle)
	var y = radius * sin(vertical_angle)
	var z = radius * cos(vertical_angle) * cos(horizontal_angle)
	
	# 确定摄像机位置和旋转
	var target = (get_parent() as Node3D).global_transform.origin
	
	# 设置摄像机位置
	global_transform.origin = Vector3(x, y, z) + target

	# 始终面向目标点
	look_at(target, Vector3.UP)
