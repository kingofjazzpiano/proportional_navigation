extends KinematicBody2D

onready var debug_line_1 = get_node("/root/Main/DebugPanel/VBoxContainer/Label1")
onready var debug_line_2 = get_node("/root/Main/DebugPanel/VBoxContainer/Label2")
onready var debug_line_3 = get_node("/root/Main/DebugPanel/VBoxContainer/Label3")
onready var debug_line_4 = get_node("/root/Main/DebugPanel/VBoxContainer/Label4")
onready var debug_line_5 = get_node("/root/Main/DebugPanel/VBoxContainer/Label5")
onready var debug_line_6 = get_node("/root/Main/DebugPanel/VBoxContainer/Label6")
onready var debug_line_7 = get_node("/root/Main/DebugPanel/VBoxContainer/Label7")
onready var debug_line_8 = get_node("/root/Main/DebugPanel/VBoxContainer/Label8")
onready var fps_label = get_node("/root/Main/DebugPanel/FPS")

onready var player = get_node("/root/Main/Player")
onready var cross = get_node("/root/Main/Cross")
onready var _min: Vector2 = Vector2.ZERO
onready var _max: Vector2 = Vector2.ZERO

var velocity: Vector2 = Vector2.ZERO
var speed: float = 120.0  # Pixels per seond
var rotation_speed: float = 0.5  # Radians per second


func _physics_process(delta: float) -> void:
	fps_label.text = str(round(1.0 / delta))
	var sight_line: Vector2 = position.direction_to(player.position)
	var alpha: float = player.velocity.angle_to(-sight_line)
	
	var beta: float
	var tmp: float = 0
	if speed:
		tmp = sin(alpha) * player.speed / speed

#	if abs(alpha) < PI * 0.5:
#		if abs(tmp) > 1.0:
#			beta = asin(sin(alpha))
#		else:
#			beta = asin(tmp)
#	elif speed < player.speed:
#		beta = asin(sin(alpha))
#	else:
#		beta = asin(tmp)
	
	if speed > player.speed or abs(alpha) < PI * 0.5 and abs(tmp) <= 1.0:
		beta = asin(tmp)
		cross.visible = true
	else:
		beta = asin(sin(alpha))
		cross.visible = false

	if fmod(abs(sight_line.angle() + beta - rotation), PI) >= rotation_speed * delta:
		rotation = lerp_angle(rotation,
			sight_line.angle() + beta,
			abs((rotation_speed * delta) /
			(Vector2.UP.rotated(rotation).angle_to(Vector2.UP.rotated(sight_line.angle() + beta)))))

#	rotation = sight_line.angle() + beta
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
#	velocity = Vector2.RIGHT.rotated(rotation) * speed
#	velocity = move_and_slide(velocity, Vector2( 0, 0 ), false, 400)
	
	# Set cross
	var gamma: float =  PI - alpha - beta
	var l: float = 0
	if alpha:
		l = speed * sin(gamma) / sin(alpha)
	var proportional_coefficient: float = 0
	if l:
		proportional_coefficient = position.distance_to(player.position) / l
	if player.velocity != Vector2.ZERO:
		cross.position = position + speed * Vector2.RIGHT.rotated(rotation) * proportional_coefficient
	else:
		cross.position = player.position

	debug_line_1.text = "alpha: " + str(rad2deg(alpha))
	debug_line_2.text = "beta: " + str(rad2deg(beta))
	debug_line_3.text = "cross.position: " + str(cross.position)
	if cross.position.x < _min.x:
		_min.x = cross.position.x
	if cross.position.y < _min.y:
		_min.y = cross.position.y
	if cross.position.x > _max.x:
		_max.x = cross.position.x
	if cross.position.y > _max.y:
		_max.y = cross.position.y
	debug_line_4.text = "_min: " + str(_min)
	debug_line_5.text = "_max: " + str(_max)
