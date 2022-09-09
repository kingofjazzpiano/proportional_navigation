extends Sprite

onready var debug_line_1 = get_node("/root/Main/DebugPanel/VBoxContainer/Label1")
onready var debug_line_2 = get_node("/root/Main/DebugPanel/VBoxContainer/Label2")
onready var debug_line_3 = get_node("/root/Main/DebugPanel/VBoxContainer/Label3")
onready var debug_line_4 = get_node("/root/Main/DebugPanel/VBoxContainer/Label4")
onready var debug_line_5 = get_node("/root/Main/DebugPanel/VBoxContainer/Label5")
onready var debug_line_6 = get_node("/root/Main/DebugPanel/VBoxContainer/Label6")
onready var debug_line_7 = get_node("/root/Main/DebugPanel/VBoxContainer/Label7")
onready var debug_line_8 = get_node("/root/Main/DebugPanel/VBoxContainer/Label8")
onready var fps_label = get_node("/root/Main/DebugPanel/FPS")

onready var navigation = get_node("/root/Main").find_node("Navigation2D")
onready var player = get_node("/root/Main/Player")
onready var cross = get_node("/root/Main/Cross")
onready var timer = $Timer
onready var ray = $RayCast2D

const RAY_LENGTH = 300.0
const REACTION_TIME = 0

var velocity: Vector2 = Vector2.ZERO
var max_speed: float = 120.0  # Pixels per seond
var current_speed: float = max_speed  # Pixels per seond
var acceleration: float = 0.25
var max_rotation_speed: float = 0.4  # Radians per second
var current_rotation_speed: float = max_rotation_speed  # Radians per second

var path: PoolVector2Array = []
var target_position: PoolVector2Array = []
var target_velocity: PoolVector2Array = []
var target_speed: PoolRealArray = []


func _ready() -> void:
	ray.set_cast_to(Vector2(RAY_LENGTH, 0))
	if REACTION_TIME:
		timer.start(REACTION_TIME)


func _physics_process(delta: float) -> void:
	fps_label.text = str(round(1.0 / delta))
	if timer.is_stopped() and target_speed.size():
		target_position.remove(0)
		target_velocity.remove(0)
		target_speed.remove(0)
	target_position.append(player.position)
	target_velocity.append(player.velocity)
	target_speed.append(player.speed)
	var sight_line: Vector2 = position.direction_to(target_position[0])
	var alpha: float = target_velocity[0].angle_to(-sight_line)
	
	var beta: float
	var tmp: float = 0
	if current_speed:
		tmp = sin(alpha) * target_speed[0] / current_speed
	
	if current_speed > target_speed[0] or abs(alpha) < PI * 0.5 and abs(tmp) <= 1.0:
		beta = asin(tmp)
	else:
		beta = asin(sin(alpha))

	var gamma: float =  PI - alpha - beta
	var l: float = 0
	if alpha:
		l = current_speed * sin(gamma) / sin(alpha)
	var proportional_coefficient: float = 0
	if l:
		proportional_coefficient = position.distance_to(target_position[0]) / l
	if target_velocity[0] != Vector2.ZERO:
		if abs(current_speed * proportional_coefficient) > 1000 or proportional_coefficient == 0:
			cross.position = position + Vector2.RIGHT.rotated(sight_line.angle() + beta) * 1000
		else:
			cross.position = position + Vector2.RIGHT.rotated(sight_line.angle() + beta) * current_speed * proportional_coefficient
	else:
		cross.position = target_position[0]

	update_navigation_path(position, cross.position)
	
	var desired_rotation = 0
	if path.size():
		desired_rotation = Vector2.RIGHT.rotated(rotation).angle_to(position.direction_to(path[0]))
	if desired_rotation:
		rotation = lerp_angle(rotation,
			position.direction_to(path[0]).angle(),
			abs((current_rotation_speed * delta) / desired_rotation))
	position += Vector2.RIGHT.rotated(rotation) * current_speed * delta
	
	
	if ray.is_colliding():
		var estimated_speed: float = position.distance_to(ray.get_collision_point()) * max_speed / RAY_LENGTH
		if estimated_speed and estimated_speed < current_speed:
			current_speed = estimated_speed
		else:
			current_speed += acceleration
	else:
		current_speed += acceleration * sign(sight_line.dot(Vector2.RIGHT.rotated(rotation)))
	current_speed = clamp(current_speed, 0, max_speed)
	
	debug_line_1.text = "alpha: " + str(rad2deg(alpha))
	debug_line_2.text = "beta: " + str(rad2deg(beta))
	debug_line_3.text = "cross.position: " + str(cross.position)
	debug_line_4.text = "ray.is_colliding(): " + str(ray.is_colliding())
	debug_line_5.text = "current_speed: " + str(current_speed)
	debug_line_6.text = "sign(sight_line.dot(Vector2.RIGHT.rotated(rotation))): " + str(sign(sight_line.dot(Vector2.RIGHT.rotated(rotation))))


func update_navigation_path(start_position, end_position):
	path = navigation.get_simple_path(start_position, end_position, true)
	if path.size():
		path.remove(0)
