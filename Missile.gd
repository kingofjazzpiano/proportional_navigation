extends Sprite

onready var debug_line_1 = get_node("/root/Main/DebugPanel/VBoxContainer/Label1")
onready var debug_line_2 = get_node("/root/Main/DebugPanel/VBoxContainer/Label2")
onready var debug_line_3 = get_node("/root/Main/DebugPanel/VBoxContainer/Label3")
onready var debug_line_4 = get_node("/root/Main/DebugPanel/VBoxContainer/Label4")
onready var debug_line_5 = get_node("/root/Main/DebugPanel/VBoxContainer/Label5")
onready var debug_line_6 = get_node("/root/Main/DebugPanel/VBoxContainer/Label6")
onready var debug_line_7 = get_node("/root/Main/DebugPanel/VBoxContainer/Label7")
onready var debug_line_8 = get_node("/root/Main/DebugPanel/VBoxContainer/Label8")
onready var debug_line_9 = get_node("/root/Main/DebugPanel/VBoxContainer/Label9")
onready var debug_line_10 = get_node("/root/Main/DebugPanel/VBoxContainer/Label10")
onready var fps_label = get_node("/root/Main/DebugPanel/FPS")

onready var navigation: Node = get_node("/root/Main").find_node("Navigation2D")
onready var player: Node = get_node("/root/Main/Player")
onready var phantom: Node = get_node("/root/Main/Phantom")
onready var cross: Node = get_node("/root/Main/Cross")
onready var front_ray: Node = $RayCast2D
onready var probe: Node = preload("res://Probe.tscn").instance()

onready var left: Node = preload("res://Probe.tscn").instance()
onready var right: Node = preload("res://Probe.tscn").instance()

const RAY_LENGTH = 300.0
const ROTATION_ACCELERATION_FACTOR = 1.4

var direction: Vector2 = Vector2.ZERO
var min_speed: float = 5.0
var max_speed: float = 150.0  # Pixels per seond
var current_speed: float = max_speed  # Pixels per seond
var acceleration: float = 0.25
var max_rotation_speed: float = 0.3  # Radians per second
var current_rotation_speed: float = max_rotation_speed  # Radians per second

var path: PoolVector2Array = []
var target_position: Vector2
var target_direction: Vector2
var target_speed: float

var last_target: Vector2 = Vector2.ZERO
var old_path: PoolVector2Array = []

var flag: bool = false

func _ready() -> void:
	get_parent().call_deferred("add_child", probe)
	get_parent().call_deferred("add_child", left)
	get_parent().call_deferred("add_child", right)
	front_ray.set_cast_to(Vector2(RAY_LENGTH, 0))


func _physics_process(delta: float) -> void:
	fps_label.text = str(round(1.0 / delta))

#	target_position = player.position
	target_direction = player.direction
	target_speed = player.speed
	
	if position.distance_to(player.get_node("Left").global_position) < position.distance_to(player.get_node("Right").global_position):
		target_position = player.get_node("Left").global_position
	else:
		target_position = player.get_node("Right").global_position
	
#	target_position = phantom.position
#	target_direction = phantom.direction
#	target_speed = phantom.speed
	
	var sight_line: Vector2 = position.direction_to(target_position)
	var alpha: float = target_direction.angle_to(-sight_line)
	
	var beta: float
	var tmp: float = 0
	if current_speed:
		tmp = sin(alpha) * target_speed / current_speed
	
	if current_speed > target_speed or abs(alpha) < PI * 0.5 and abs(tmp) <= 1.0:
		beta = asin(tmp)
	else:
		beta = asin(sin(alpha))

	var gamma: float =  PI - alpha - beta
	var l: float = 0
	if alpha:
		l = current_speed * sin(gamma) / sin(alpha)
	var proportional_coefficient: float = 0
	if l:
		proportional_coefficient = position.distance_to(target_position) / l
	if target_direction != Vector2.ZERO:
		if abs(current_speed * proportional_coefficient) > 1000 or proportional_coefficient == 0:
			cross.position = position + Vector2.RIGHT.rotated(sight_line.angle() + beta) * 1000
			flag = false
		else:
			cross.position = position + Vector2.RIGHT.rotated(sight_line.angle() + beta) * current_speed * proportional_coefficient
			flag = true
	else:
		cross.position = target_position
		flag = true
	
#	update_navigation_path(position, cross.position)

	probe.global_position = global_position
	probe.cast_to.x = global_position.distance_to(cross.position)
	probe.rotation = position.direction_to(cross.position).angle()
	
	left.global_position = cross.position
	right.global_position = cross.position
	
	left.cast_to.x = 500  # 200 + 50
	right.cast_to.x = 500  # 200 + 50
	
	left.rotation = probe.rotation - PI * 0.5
	right.rotation = probe.rotation + PI * 0.5
	
	debug_line_7.text = "position.direction_to(cross.position).angle_to(player.position): " + str(rad2deg((cross.position - position).angle_to(player.position - position)))
#	var left_cross_position: Vector2 = cross.position + Vector2(500, 0).rotated(probe.rotation - PI * 0.5)
#	var right_cross_position: Vector2 = cross.position + Vector2(500, 0).rotated(probe.rotation + PI * 0.5)
#	if flag:
#		if abs((left_cross_position - position).angle_to(player.position - position)) \
#				< abs((right_cross_position - position).angle_to(player.position - position)):
#			cross.position = right_cross_position
#		else:
#			cross.position = left_cross_position
			
		
	
	if Input.is_action_just_pressed("F4"):
		pass  # Debug

	if path.size() > 1 and is_straight_line():
		path = [path[-1]]

	if path.size() > 1 and position.distance_to(path[0]) < 50.0:
		path.remove(0)

	if path.size() > 1:
		last_target = path[0]
		old_path = PoolVector2Array() + path
	else:
		last_target = Vector2.ZERO

	if path.size() < 2 or Input.is_action_pressed("x") \
			or not probe.is_colliding() \
			or abs(Vector2.RIGHT.rotated(rotation).angle_to(position.direction_to(path[0]))) > PI * 0.5:
		update_navigation_path(position, cross.position)
	elif path.size() > 1 and last_target and last_target != path[0]:
		path = PoolVector2Array() + old_path
	
	var desired_rotation = 0
	if path.size():
		desired_rotation = Vector2.RIGHT.rotated(rotation).angle_to(position.direction_to(path[0]))
	if desired_rotation:
		rotation = lerp_angle(rotation,
			position.direction_to(path[0]).angle(),
			abs((current_rotation_speed * delta) / desired_rotation))
	position += Vector2.RIGHT.rotated(rotation) * current_speed * delta
	
	if front_ray.is_colliding():
		var estimated_speed: float = position.distance_to(front_ray.get_collision_point()) * max_speed / RAY_LENGTH
		if estimated_speed and estimated_speed < current_speed:
			current_speed = estimated_speed
		else:
			current_speed += acceleration
	else:
		current_speed += acceleration
	current_speed = clamp(current_speed, min_speed, max_speed)
	
	if front_ray.is_colliding() or sight_line.dot(Vector2.RIGHT.rotated(rotation)) < 0:
		current_rotation_speed = max_rotation_speed * ROTATION_ACCELERATION_FACTOR
	else:
		current_rotation_speed = max_rotation_speed

#	debug_line_1.text = "alpha: " + str(rad2deg(alpha))
#	debug_line_2.text = "beta: " + str(rad2deg(beta))
#	debug_line_3.text = "cross.position: " + str(cross.position)
#	debug_line_4.text = "ray.is_colliding(): " + str(ray.is_colliding())
	debug_line_5.text = "current_speed: " + str(current_speed)
	debug_line_6.text = "player.speed: " + str(player.speed)



func update_navigation_path(start_position, end_position):
	path = navigation.get_simple_path(start_position, end_position, true)
	if path.size():
		path.remove(0)


func is_straight_line() -> bool:
	var angle: float = abs((path[0] - global_position).angle_to(path[1] - path[0]))
	if angle > deg2rad(20.0):
		return false
	for i in range(path.size() - 2):
		angle = abs((path[i + 1] - path[i]).angle_to(path[i + 2] - path[i + 1]))
		if angle > deg2rad(20.0):
			return false
	return true
