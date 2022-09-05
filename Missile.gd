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

onready var player = get_node("/root/Main/Player")
onready var cross = get_node("/root/Main/Cross")


var velocity: Vector2 = Vector2.ZERO
var speed: float = 30.0
var rotation_speed: float = 0.005


func _ready() -> void:
#	print(rad2deg( normalize_angle(deg2rad(-190)) ))
#	get_tree().quit()
	pass

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
	
	if rotation != sight_line.angle() + beta:
		rotation = lerp_angle(rotation,
			sight_line.angle() + beta,
			abs(rotation_speed / fmod((sight_line.angle() + beta - rotation), PI)))

	
#	if fmod(rotation, 2 * PI) != fmod(sight_line.angle() + beta, 2 * PI):
#		rotation -= rotation_speed
#	rotation = sight_line.angle() + beta
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
	debug_line_5.text = "sight_line.angle() + beta: " + str(sight_line.angle() + beta)
#	debug_line_5.text = "fmod(sight_line.angle() + beta, 2 * PI) + PI: " + str(fmod(sight_line.angle() + beta, 2 * PI) + PI)
#	debug_line_6.text = "fmod(rotation, 2 * PI): " + str(fmod(rotation, 2 * PI))
	debug_line_6.text = "rotation: " + str(rotation)
	debug_line_7.text = "sight_line.angle() + beta - rotation: " + str(sight_line.angle() + beta - rotation)
	debug_line_8.text = "lerp_angle"
	
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
	debug_line_3.text = "player.rotation: " + str(rad2deg(player.rotation))
	debug_line_4.text = "abs(tmp): " + str(abs(tmp))


func normalize_angle(theta: float) -> float:
	"Limits the angle theta from 0 to PI radians."
	var result = fmod(theta, PI)
#	if result > PI:
#		result = 2 * PI - result
	return result
	
